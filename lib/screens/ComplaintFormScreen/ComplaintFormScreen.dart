import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

// Extremely simplified screen to avoid crashes
class ComplaintFormScreen extends StatelessWidget {
  const ComplaintFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complaint Form'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SafeArea(
        child: _ComplaintFormContent(),
      ),
    );
  }
}

// Separate stateful widget to isolate state management
class _ComplaintFormContent extends StatefulWidget {
  @override
  _ComplaintFormContentState createState() => _ComplaintFormContentState();
}

class _ComplaintFormContentState extends State<_ComplaintFormContent> {
  // Basic controllers
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _serviceController = TextEditingController();
  final _detailsController = TextEditingController();

  // Simple loading state
  bool _isLoading = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Safe disposal guard
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _phoneController.dispose();
    _websiteController.dispose();
    _serviceController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  // Safe setState to prevent setting state after disposal
  void _safeSetState(void Function() fn) {
    if (_disposed || !mounted) return;
    setState(fn);
  }

  // Show a simple message
  void _showMessage(String message, bool isError) {
    if (_disposed || !mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      // Ignore any errors from showing the message
      print('Error showing message: $e');
    }
  }

  // Submit data with error handling
  Future<void> _submitData() async {
    if (_disposed || !mounted) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _safeSetState(() => _isLoading = true);

    try {
      // Get token
      String? token;
      try {
        token = await UserSession.getToken();
      } catch (e) {
        print('Error getting token: $e');
      }

      if (_disposed || !mounted) return;

      // Check token
      if (token == null) {
        _showMessage('Please log in again.', true);
        _safeSetState(() => _isLoading = false);
        return;
      }

      // Make API request with timeout
      try {
        final response = await http
            .post(
              Uri.parse(ApiEndpoints.complaint),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'phone_number': _phoneController.text,
                'website': _websiteController.text,
                'service': _serviceController.text,
                'loss_detail': _detailsController.text,
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (_disposed || !mounted) return;

        if (response.statusCode == 201) {
          _showMessage('Complaint submitted successfully', false);
          _phoneController.clear();
          _websiteController.clear();
          _serviceController.clear();
          _detailsController.clear();
        } else {
          _showMessage('Failed to submit. Please try again.', true);
        }
      } catch (e) {
        if (_disposed || !mounted) return;
        _showMessage('Network error. Please try again.', true);
        print('Network error: $e');
      }
    } catch (e) {
      print('Unhandled error: $e');
      if (_disposed || !mounted) return;
      _showMessage('An error occurred.', true);
    } finally {
      if (_disposed || !mounted) return;
      _safeSetState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ultra-simple UI with minimal styling
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a Complaint',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Phone field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Your Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Website field
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Service field
            TextFormField(
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'Service Provider Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Details field
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Loss Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Complaint'),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Your complaint will be reviewed by our team. We may contact you for more information.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
