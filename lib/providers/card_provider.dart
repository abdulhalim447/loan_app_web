import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

enum CardLoadingStatus { initial, loading, loaded, error }

class CardProvider extends ChangeNotifier {
  CardLoadingStatus _status = CardLoadingStatus.initial;
  String _cardNumber = '';
  String _cardHolderName = '';
  String _validity = '';
  String _cvv = '';
  String _userBankName = '';
  String _userBankNumber = '';
  String? _errorMessage;

  // Getters
  CardLoadingStatus get status => _status;
  String get cardNumber => _cardNumber;
  String get cardHolderName => _cardHolderName;
  String get validity => _validity;
  String get cvv => _cvv;
  String get userBankName => _userBankName;
  String get userBankNumber => _userBankNumber;
  String? get errorMessage => _errorMessage;

  // Fetch card data from the API
  Future<void> fetchCardData() async {
    try {
      _status = CardLoadingStatus.loading;
      notifyListeners();

      final token = await UserSession.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.card),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Get bank information first as it's now the priority
        _userBankName = jsonResponse['userBankName'] ?? '';
        _userBankNumber = jsonResponse['userBankNumber'] ?? '';

        // Even if we have card data, bank name and number are the priority
        if (_userBankName.isNotEmpty || _userBankNumber.isNotEmpty) {
          _status = CardLoadingStatus.loaded;
        }
        
        // Still collect card information if available
        if (jsonResponse['cards'] != null && jsonResponse['cards'].isNotEmpty) {
          final cardData = jsonResponse['cards'][0];

          _cardNumber = cardData['cardNumber'] ?? '';
          _cardHolderName = cardData['cardHolderName'] ?? '';
          _validity = cardData['validity'] ?? '';
          _cvv = cardData['cvv'] ?? '';

          _status = CardLoadingStatus.loaded;
        } else if (_userBankName.isEmpty && _userBankNumber.isEmpty) {
          // Only show error if we have neither bank nor card information
          _errorMessage = 'No banking data found';
          _status = CardLoadingStatus.error;
        }
      } else {
        _errorMessage = 'Failed to load banking data: ${response.statusCode}';
        _status = CardLoadingStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _status = CardLoadingStatus.error;
      if (kDebugMode) {
        print('Error fetching banking data: $e');
      }
    }

    notifyListeners();
  }
}
