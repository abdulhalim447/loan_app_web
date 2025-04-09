import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

enum CardLoadingStatus { initial, loading, loaded, error }

class CardProvider extends ChangeNotifier {
  CardLoadingStatus _status = CardLoadingStatus.initial;
  String _cardHolderName = 'N/A';
  String _cardNumber = 'N/A';
  String _validity = 'N/A';
  String _errorMessage = '';
  bool _imageLoadError = false;

  // Getters
  CardLoadingStatus get status => _status;
  String get cardHolderName => _cardHolderName;
  String get cardNumber => _cardNumber;
  String get validity => _validity;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == CardLoadingStatus.loading;
  bool get hasError => _status == CardLoadingStatus.error;
  bool get imageLoadError => _imageLoadError;

  // Set image load error
  void setImageLoadError(bool value) {
    _imageLoadError = value;
    notifyListeners();
  }

  // Fetch card data from API
  Future<void> fetchCardData() async {
    if (_status == CardLoadingStatus.loading) return;

    _status = CardLoadingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Retrieve the authentication token
      String? token;
      try {
        token = await UserSession.getToken();
      } catch (tokenError) {
        debugPrint("Error getting token: $tokenError");
        _setError('Authentication error');
        notifyListeners();
        return;
      }

      if (token == null) {
        _setError('User not authenticated');
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.card),
        headers: {
          "Authorization": "Bearer $token",
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        try {
          var card = data['card'][0];
          _cardHolderName = card['cardHolderName'] ?? 'N/A';
          _cardNumber = card['cardNumber'] ?? 'N/A';
          _validity = card['validity'] ?? 'N/A';
          _status = CardLoadingStatus.loaded;
        } catch (e) {
          _setError('Failed to parse data: $e');
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

  // Reset data
  void reset() {
    _status = CardLoadingStatus.initial;
    _cardHolderName = 'N/A';
    _cardNumber = 'N/A';
    _validity = 'N/A';
    _errorMessage = '';
    _imageLoadError = false;
    notifyListeners();
  }

  // Set error state
  void _setError(String message) {
    _status = CardLoadingStatus.error;
    _errorMessage = message;
  }
}
