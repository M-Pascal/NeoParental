import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Testing and Debugging Screen
///
/// Use this screen to test Firebase connectivity and verify setup
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final List<Map<String, dynamic>> _testResults = [];
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _testing = true;
      _testResults.clear();
    });

    // Test 1: Firebase Core
    await _testFirebaseCore();

    // Test 2: Firebase Auth
    await _testFirebaseAuth();

    // Test 3: Firestore
    await _testFirestore();

    // Test 4: Storage
    await _testStorage();

    setState(() {
      _testing = false;
    });
  }

  Future<void> _testFirebaseCore() async {
    try {
      final app = Firebase.app();
      _addResult(
        'Firebase Core',
        true,
        'Initialized successfully\nProject: ${app.options.projectId}',
      );
    } catch (e) {
      _addResult('Firebase Core', false, 'Error: $e');
    }
  }

  Future<void> _testFirebaseAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      _addResult(
        'Firebase Auth',
        true,
        currentUser != null
            ? 'User logged in: ${currentUser.email}'
            : 'No user logged in (Auth working)',
      );
    } catch (e) {
      _addResult('Firebase Auth', false, 'Error: $e');
    }
  }

  Future<void> _testFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Try to read settings (doesn't require network)
      final settings = firestore.settings;

      _addResult(
        'Cloud Firestore',
        true,
        'Connected\nHost: ${settings.host ?? "default"}',
      );
    } catch (e) {
      _addResult('Cloud Firestore', false, 'Error: $e');
    }
  }

  Future<void> _testStorage() async {
    try {
      final storage = FirebaseStorage.instance;
      final bucket = storage.bucket;

      _addResult('Firebase Storage', true, 'Connected\nBucket: $bucket');
    } catch (e) {
      _addResult('Firebase Storage', false, 'Error: $e');
    }
  }

  void _addResult(String test, bool success, String message) {
    setState(() {
      _testResults.add({'test': test, 'success': success, 'message': message});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: const Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testing ? null : _runTests,
          ),
        ],
      ),
      body: _testing && _testResults.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length + 1,
              itemBuilder: (context, index) {
                if (index == _testResults.length) {
                  return _buildSummary();
                }

                final result = _testResults[index];
                return _buildTestResultCard(
                  result['test'],
                  result['success'],
                  result['message'],
                );
              },
            ),
    );
  }

  Widget _buildTestResultCard(String test, bool success, String message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    test,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                message,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final successCount = _testResults.where((r) => r['success']).length;
    final totalCount = _testResults.length;
    final allPassed = successCount == totalCount;

    return Card(
      color: allPassed ? Colors.green[50] : Colors.orange[50],
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              allPassed ? Icons.check_circle_outline : Icons.warning_amber,
              size: 48,
              color: allPassed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              allPassed ? '🎉 All Tests Passed!' : '⚠️ Some Tests Failed',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$successCount/$totalCount services working',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            if (!allPassed) ...[
              const SizedBox(height: 16),
              const Text(
                'Please check:\n'
                '• google-services.json in android/app/\n'
                '• Firebase services enabled in console\n'
                '• Internet connection',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
