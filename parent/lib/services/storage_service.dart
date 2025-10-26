import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling Firebase Storage operations
/// Manages audio file uploads and history tracking
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload an audio file to Firebase Storage
  ///
  /// Returns the download URL of the uploaded file
  /// Throws [StorageException] if upload fails
  Future<String> uploadAudioFile({
    required String filePath,
    required String userId,
    String? fileName,
  }) async {
    try {
      final File file = File(filePath);

      // Generate a unique filename if not provided
      final String uploadFileName =
          fileName ??
          'audio_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension(filePath)}';

      // Create storage reference
      final Reference storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('audio_files')
          .child(uploadFileName);

      // Upload file with metadata
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(_getFileExtension(filePath)),
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(_getStorageErrorMessage(e.code));
    } catch (e) {
      throw StorageException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Save audio analysis history to Firestore
  ///
  /// Returns the document ID of the saved history item
  Future<String> saveAudioHistory({
    required String userId,
    required String audioUrl,
    required String fileName,
    required Map<String, dynamic> analysisData,
  }) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('audio_history')
          .add({
            'audioUrl': audioUrl,
            'fileName': fileName,
            'analysis': analysisData['analysis'] ?? 'Unknown',
            'confidence': analysisData['confidence'] ?? 0,
            'duration': analysisData['duration'] ?? 0,
            'status': analysisData['status'] ?? 'completed',
            'notes': analysisData['notes'],
            'uploadedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      return docRef.id;
    } on FirebaseException catch (e) {
      throw StorageException(_getStorageErrorMessage(e.code));
    } catch (e) {
      throw StorageException('Failed to save history: ${e.toString()}');
    }
  }

  /// Get audio history for a specific user
  ///
  /// Returns a stream of history items ordered by creation date
  Stream<List<Map<String, dynamic>>> getAudioHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('audio_history')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Delete an audio file from storage
  Future<void> deleteAudioFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException(_getStorageErrorMessage(e.code));
    } catch (e) {
      throw StorageException('Failed to delete file: ${e.toString()}');
    }
  }

  /// Delete a history item from Firestore
  Future<void> deleteHistoryItem({
    required String userId,
    required String historyId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('audio_history')
          .doc(historyId)
          .delete();
    } on FirebaseException catch (e) {
      throw StorageException(_getStorageErrorMessage(e.code));
    } catch (e) {
      throw StorageException('Failed to delete history item: ${e.toString()}');
    }
  }

  /// Update notes for a history item
  Future<void> updateHistoryNotes({
    required String userId,
    required String historyId,
    required String notes,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('audio_history')
          .doc(historyId)
          .update({'notes': notes, 'updatedAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (e) {
      throw StorageException(_getStorageErrorMessage(e.code));
    } catch (e) {
      throw StorageException('Failed to update notes: ${e.toString()}');
    }
  }

  /// Get file extension from path
  String _getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'flac':
        return 'audio/flac';
      case 'ogg':
        return 'audio/ogg';
      case 'wma':
        return 'audio/x-ms-wma';
      default:
        return 'audio/mpeg';
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getStorageErrorMessage(String? code) {
    switch (code) {
      case 'storage/unauthorized':
        return 'You do not have permission to access this file';
      case 'storage/canceled':
        return 'Upload was canceled';
      case 'storage/unknown':
        return 'An unknown error occurred';
      case 'storage/object-not-found':
        return 'File not found';
      case 'storage/bucket-not-found':
        return 'Storage bucket not found';
      case 'storage/project-not-found':
        return 'Project not found';
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded';
      case 'storage/unauthenticated':
        return 'User is not authenticated';
      case 'storage/retry-limit-exceeded':
        return 'Upload retry limit exceeded';
      case 'storage/invalid-checksum':
        return 'File checksum does not match';
      default:
        return 'Storage operation failed';
    }
  }

  /// Get upload progress stream
  Stream<double> uploadWithProgress({
    required String filePath,
    required String userId,
    String? fileName,
  }) {
    final File file = File(filePath);
    final String uploadFileName =
        fileName ??
        'audio_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension(filePath)}';

    final Reference storageRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('audio_files')
        .child(uploadFileName);

    final UploadTask uploadTask = storageRef.putFile(file);

    return uploadTask.snapshotEvents.map((TaskSnapshot snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}
