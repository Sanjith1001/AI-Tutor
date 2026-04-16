import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConnectivityTestWidget extends StatefulWidget {
  const ConnectivityTestWidget({Key? key}) : super(key: key);

  @override
  State<ConnectivityTestWidget> createState() => _ConnectivityTestWidgetState();
}

class _ConnectivityTestWidgetState extends State<ConnectivityTestWidget> {
  List<Map<String, dynamic>> testResults = [];
  bool isLoading = false;
  late final List<String> testUrls;

  @override
  void initState() {
    super.initState();
    final urls = <String>{};
    final envUrl = _normalizeBase(dotenv.env['API_URL']);
    if (envUrl != null) urls.add(envUrl);
    urls.addAll([
      'http://10.0.2.2:3000', // Android Emulator
      'http://localhost:3000', // Desktop
      'http://127.0.0.1:3000',
      'http://192.168.1.100:3000',
    ]);
    testUrls = urls.toList();
  }

  String? _normalizeBase(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return raw.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.network_check, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Network Connectivity Test',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isLoading ? null : _runConnectivityTest,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (testResults.isNotEmpty) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...testResults.map((result) => _buildResultTile(result)),
            ] else
              const Text(
                'Click "Test All" to check connectivity to all possible server URLs.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> result) {
    final bool success = result['success'] ?? false;
    final String url = result['url'] ?? '';
    final String message = result['message'] ?? '';
    final int? statusCode = result['statusCode'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: success ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  url,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  statusCode != null
                      ? 'Status: $statusCode - $message'
                      : message,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        success ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runConnectivityTest() async {
    setState(() {
      isLoading = true;
      testResults.clear();
    });

    for (String baseUrl in testUrls) {
      try {
        print('🔍 Testing: $baseUrl/health');

        final response = await http
            .get(
              Uri.parse('$baseUrl/health'),
            )
            .timeout(const Duration(seconds: 5));

        final result = {
          'url': baseUrl,
          'success': response.statusCode == 200,
          'statusCode': response.statusCode,
          'message': response.statusCode == 200
              ? 'Connected successfully!'
              : 'Server responded with error',
        };

        setState(() {
          testResults.add(result);
        });

        // If we found a working URL, also test login
        if (response.statusCode == 200) {
          await _testLogin(baseUrl);
        }
      } catch (e) {
        final result = {
          'url': baseUrl,
          'success': false,
          'message': 'Connection failed: ${e.toString()}',
        };

        setState(() {
          testResults.add(result);
        });
      }

      // Small delay between tests
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _testLogin(String baseUrl) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': 'admin@aitutor.com',
              'password': 'admin123',
            }),
          )
          .timeout(const Duration(seconds: 5));

      final loginResult = {
        'url': '$baseUrl/api/auth/login',
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 200
            ? 'Login API working!'
            : 'Login API error',
      };

      setState(() {
        testResults.add(loginResult);
      });
    } catch (e) {
      final loginResult = {
        'url': '$baseUrl/api/auth/login',
        'success': false,
        'message': 'Login test failed: ${e.toString()}',
      };

      setState(() {
        testResults.add(loginResult);
      });
    }
  }
}
