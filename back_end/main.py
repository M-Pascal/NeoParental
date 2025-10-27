# main.py
from fastapi import FastAPI, File, UploadFile, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import uvicorn
import librosa
import numpy as np
import tensorflow as tf
import joblib
import os
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime
import logging

# -----------------------------
# LOGGING CONFIGURATION
# -----------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# -----------------------------
# FASTAPI APP SETUP
# -----------------------------
app = FastAPI(
    title="NeoParental Prediction API",
    description="API for predicting audio sound classes using a trained model",
    version="2.1.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Enable CORS (configure properly for production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# DIRECTORIES & PATHS
# -----------------------------
BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "Model" / "saved_model"
MODEL_PATH = MODEL_DIR / "best_model.joblib"
TEMP_DIR = BASE_DIR / "temp"

MODEL_DIR.mkdir(parents=True, exist_ok=True)
TEMP_DIR.mkdir(exist_ok=True)

# -----------------------------
# GLOBAL VARIABLES
# -----------------------------
model = None
model_type = None
model_metadata = {}

# Example labels (optional if regression outputs numeric)
class_labels = {
    0: "belly_pain",
    1: "burping",
    2: "discomfort",
    3: "hungry",
    4: "tired"
}

# -----------------------------
# RESPONSE MODELS
# -----------------------------
class PredictionResponse(BaseModel):
    prediction_value: float
    predicted_label: Optional[str]
    processing_time: float
    timestamp: str

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_type: Optional[str]
    model_metadata: Dict
    timestamp: str

# -----------------------------
# MODEL LOADING
# -----------------------------
def load_model():
    global model, model_type, model_metadata
    try:
        if MODEL_PATH.exists():
            logger.info(f"Loading model from: {MODEL_PATH}")
            model = joblib.load(MODEL_PATH)
            model_type = "DecisionTreeRegressor"
            model_metadata = {
                "type": model_type,
                "path": str(MODEL_PATH),
                "library": "scikit-learn"
            }
            logger.info("Model loaded successfully.")
        else:
            logger.error("No model file found in Model/saved_model/")
            model_metadata = {"error": "Model file not found"}
    except Exception as e:
        logger.error(f"Model loading error: {e}")
        model_metadata = {"error": str(e)}
        raise

# -----------------------------
# AUDIO FEATURE EXTRACTION
# -----------------------------
def extract_audio_features(audio_path: Path, sr: int = 16000) -> np.ndarray:
    """Extract audio features using librosa"""
    try:
        y, sr = librosa.load(audio_path, sr=sr, duration=10)
        if len(y) == 0:
            raise ValueError("Audio file appears empty or unreadable.")

        features = []

        # MFCCs
        mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=40)
        features.extend(np.mean(mfcc, axis=1))
        features.extend(np.std(mfcc, axis=1))

        # Mel Spectrogram
        mel = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=64)
        features.extend(np.mean(mel, axis=1))

        # Chroma
        chroma = librosa.feature.chroma_stft(y=y, sr=sr)
        features.extend(np.mean(chroma, axis=1))

        # Spectral features
        features.append(np.mean(librosa.feature.zero_crossing_rate(y)))
        features.append(np.mean(librosa.feature.spectral_centroid(y=y, sr=sr)))
        features.append(np.mean(librosa.feature.spectral_rolloff(y=y, sr=sr)))

        return np.array(features).reshape(1, -1)
    except Exception as e:
        logger.error(f"Feature extraction error: {e}")
        raise

# -----------------------------
# VALIDATION & CLEANUP
# -----------------------------
def validate_audio_file(file: UploadFile) -> bool:
    allowed_extensions = {'.wav', '.mp3', '.m4a', '.flac', '.ogg', '.aac'}
    return Path(file.filename).suffix.lower() in allowed_extensions

async def cleanup_file(file_path: Path):
    try:
        if file_path.exists():
            file_path.unlink()
            logger.debug(f"Cleaned up file: {file_path}")
    except Exception as e:
        logger.warning(f"Failed to delete {file_path}: {e}")

# -----------------------------
# STARTUP EVENT
# -----------------------------
@app.on_event("startup")
async def startup_event():
    logger.info("Starting Audio Prediction API...")
    load_model()

# -----------------------------
# ENDPOINTS
# -----------------------------
@app.get("/", response_model=HealthResponse)
async def root():
    return HealthResponse(
        status="online",
        model_loaded=model is not None,
        model_type=model_type,
        model_metadata=model_metadata,
        timestamp=datetime.now().isoformat()
    )

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return await root()

@app.post("/predict", response_model=PredictionResponse)
async def predict_audio(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...)
):
    """Predict regression output from uploaded audio"""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")

    if not validate_audio_file(file):
        raise HTTPException(status_code=400, detail="Invalid audio format.")

    temp_file = TEMP_DIR / f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
    start_time = datetime.now()

    try:
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File exceeds 10MB limit.")
        with open(temp_file, "wb") as f:
            f.write(contents)

        features = extract_audio_features(temp_file)

        # For DecisionTreeRegressor
        prediction = float(model.predict(features)[0])

        # Optionally, map prediction to label (if regression approximates class index)
        predicted_label = class_labels.get(round(prediction), None)

        return PredictionResponse(
            prediction_value=prediction,
            predicted_label=predicted_label,
            processing_time=(datetime.now() - start_time).total_seconds(),
            timestamp=datetime.now().isoformat()
        )

    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

    finally:
        background_tasks.add_task(cleanup_file, temp_file)

# -----------------------------
# ERROR HANDLER
# -----------------------------
@app.exception_handler(Exception)
async def general_exception_handler(_, exc: Exception):
    logger.error(f"Unhandled error: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": str(exc),
            "timestamp": datetime.now().isoformat()
        }
    )

# -----------------------------
# RUN SERVER
# -----------------------------
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False, log_level="info")

