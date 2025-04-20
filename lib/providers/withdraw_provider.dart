import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

enum WithdrawLoadingStatus {
  initial,
  loading,
  loaded,
  error,
  uploading,
  success
}

class WithdrawProvider extends ChangeNotifier {
  WithdrawLoadingStatus _loadingStatus = WithdrawLoadingStatus.initial;
  String _balance = "0";
  String _loan = "0";
  String _bankName = "N/A";
  String _account = "N/A";
  String _bankUser = "N/A";
  String _message = "Not provided";
  String _fee = "0";
  String _ifc = "N/A";
  String _adminBankName = "N/A";
  String _adminAccountName = "N/A";
  String _adminAccountNumber = "N/A";
  final String _adminIfc = "N/A";
  final String _adminUpi = "N/A";
  String _bkashNumber = "N/A";
  String _nagadNumber = "N/A";
  File? _image;
  Uint8List? _imageBytes;
  String _errorMessage = '';
  final ImagePicker _picker = ImagePicker();

  // Getters
  WithdrawLoadingStatus get loadingStatus => _loadingStatus;
  String get balance => _balance;
  String get loan => _loan;
  String get bankName => _bankName;
  String get account => _account;
  String get bankUser => _bankUser;
  String get message => _message;
  String get fee => _fee;
  String get ifc => _ifc;
  String get adminBankName => _adminBankName;
  String get adminAccountName => _adminAccountName;
  String get adminAccountNumber => _adminAccountNumber;
  String get adminIfc => _adminIfc;
  String get adminUpi => _adminUpi;
  String get bkashNumber => _bkashNumber;
  String get nagadNumber => _nagadNumber;
  File? get image => _image;
  Uint8List? get imageBytes => _imageBytes;
  bool get hasImage => _image != null || _imageBytes != null;
  String get errorMessage => _errorMessage;
  bool get isLoading => _loadingStatus == WithdrawLoadingStatus.loading;
  bool get hasError => _loadingStatus == WithdrawLoadingStatus.error;
  bool get isUploading => _loadingStatus == WithdrawLoadingStatus.uploading;
  bool get isSuccess => _loadingStatus == WithdrawLoadingStatus.success;

  // Initialize provider
  Future<void> initialize() async {
    await fetchWithdrawDetails();
  }

  // Fetch withdraw details from API
  Future<void> fetchWithdrawDetails() async {
    _loadingStatus = WithdrawLoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        _setError('User not authenticated');
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.withdrawMethods),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        try {
          // User Bank Info
          _balance = (data['userBankInfo']['balance'] ?? "0").toString();
          _loan = (data['userBankInfo']['loanBalance'] ?? "0").toString();
          _fee = (data['userBankInfo']['fee'] ?? "0").toString();
          _message = data['userBankInfo']['message'] ?? "";

          // Mobile payment options from adminBankInfo
          _bkashNumber = data['adminBankInfo']['bkash'] ?? "N/A";
          _nagadNumber = data['adminBankInfo']['nagad'] ?? "N/A";

          // Set dummy values for fields not in the API but used in UI
          _adminBankName = _bkashNumber;
          _adminAccountNumber = _nagadNumber;

          _bankName = data['userBankInfo']['bankName'] ?? "N/A";
          _account = data['userBankInfo']['accountNumber']?.toString() ?? "N/A";
          _bankUser = data['userBankInfo']['bankUserName'] ?? "N/A";
          _ifc = data['userBankInfo']['ifc'] ?? "N/A";

          _adminAccountName =
              data['adminBankInfo']['adminAccountName'] ?? "N/A";

          _loadingStatus = WithdrawLoadingStatus.loaded;
        } catch (e) {
          _setError('Failed to parse data: $e');
        }
      } else if (response.statusCode == 401) {
        _setError('Session expired. Please login again');
      } else if (response.statusCode == 422) {
        // Parse validation errors from the response
        try {
          final data = json.decode(response.body);
          if (data['message'] != null) {
            _setError('Validation error: ${data['message']}');
          } else if (data['errors'] != null) {
            // Extract first error message
            final firstError = data['errors'].values.first;
            if (firstError is List && firstError.isNotEmpty) {
              _setError('Validation error: ${firstError[0]}');
            } else {
              _setError('Validation error: Please check your submission');
            }
          } else {
            _setError('Invalid data submitted. Please check and try again.');
          }
        } catch (e) {
          _setError(
              'Invalid data submitted (422). Please check and try again.');
        }
      } else {
        _setError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Connection error: $e');
    }

    notifyListeners();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      if (kIsWeb) {
        // Web implementation
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

        if (pickedFile != null) {
          // Read as bytes for web
          _imageBytes = await pickedFile.readAsBytes();
          _image = null; // Clear file since we're using bytes
          notifyListeners();
        }
      } else {
        // Mobile implementation
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

        if (pickedFile != null) {
          _image = File(pickedFile.path);
          // Also keep bytes for uniformity
          _imageBytes = await pickedFile.readAsBytes();
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
      notifyListeners();
    }
  }

  // Submit image to server
  Future<void> submitImage() async {
    if (!hasImage) {
      _setError('Please select an image');
      return;
    }

    _loadingStatus = WithdrawLoadingStatus.uploading;
    _errorMessage = '';
    notifyListeners();

    try {
      String? token = await UserSession.getToken();
      if (token == null) {
        _setError('User not authenticated');
        return;
      }

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.uploadScreenshot),
      );

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add file
      if (kIsWeb && _imageBytes != null) {
        // For web, use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageBytes!,
            filename: 'payment_screenshot.jpg',
          ),
        );
      } else if (_image != null) {
        // For mobile, use file
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _image!.path,
          ),
        );
      } else {
        throw Exception('No image selected');
      }

      // Add required form fields
      request.fields['method'] = 'mobile_banking'; // Add payment method
      request.fields['transaction_id'] =
          'MB${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}'; // Generated transaction ID
      request.fields['amount'] = _fee; // Add the fee amount

      // Send the request
      var streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Upload timeout'),
          );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _loadingStatus = WithdrawLoadingStatus.success;
        } else {
          _setError(data['message'] ?? 'Failed to submit payment screenshot');
        }
      } else if (response.statusCode == 401) {
        _setError('Session expired. Please login again');
      } else {
        _setError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Connection error: $e');
    }

    notifyListeners();
  }

  // Reset state
  void reset() {
    _loadingStatus = WithdrawLoadingStatus.initial;
    _image = null;
    _imageBytes = null;
    _errorMessage = '';
    notifyListeners();
  }

  // Set error state
  void _setError(String message) {
    _loadingStatus = WithdrawLoadingStatus.error;
    _errorMessage = message;
  }
}
