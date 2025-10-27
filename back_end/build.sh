#!/usr/bin/env bash
set -o errexit

# Upgrade pip and setuptools first
pip install --upgrade pip setuptools wheel

# Install packages one by one to isolate issues
pip install numpy==1.24.3
pip install setuptools==68.2.2
pip install fastapi==0.104.1
pip install "uvicorn[standard]"==0.24.0
pip install soundfile==0.12.1
pip install librosa==0.10.1
pip install watchfiles==0.19.0
pip install scikit-learn==1.3.2

# Install the rest from requirements
pip install -r requirements.txt