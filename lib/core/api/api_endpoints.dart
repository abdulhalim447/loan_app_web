import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Base URL for all endpoints
  static const String _baseUrl = "https://wblloanschema.com/api";

  // Authentication Endpoints
  static String get login => "$_baseUrl/login";
  static String get register => "$_baseUrl/register";
  static String get changePassword => "$_baseUrl/change-password";

  // User Profile Endpoints
  static String get index => "$_baseUrl/index";
  static String get profile => "$_baseUrl/index";

  //notification
  static String get notification => "$_baseUrl/notifications";

  //personal info  verify
  static String get personalInfoVerify => "$_baseUrl/verify";
  static String get getPersonalInfoVerify => "$_baseUrl/getverified";
  // Loan Management Endpoints
  static String get loans => "$_baseUrl/loans";
  static String get certificate => "$_baseUrl/certificate";

  //  Withdraw Endpoints
  static String get withdrawMethods => "$_baseUrl/method";

  //upload screenshot
  static String get uploadScreenshot => "$_baseUrl/recharge";

  static String get withdraw => "$_baseUrl/withdraw";
  static String get getBank => "$_baseUrl/getbank";
  static String get saveBank => "$_baseUrl/savebank";
  static String get card => "$_baseUrl/card";

  // Content Endpoints
  static String get slides => "$_baseUrl/slides";

  // Support & Help Endpoints
  static String get about => "$_baseUrl/about";
  static String get support => "$_baseUrl/support";
  static String get complaint => "$_baseUrl/complaint";

  // Helper method to get full URL with path
  static String getUrl(String path) {
    return "$_baseUrl/$path";
  }

  // Debug method to print all endpoints (useful for development)
  static void printAllEndpoints() {
    if (kDebugMode) {
      print('=== API ENDPOINTS ===');
      print('Base URL: $_baseUrl');
      print('--- Authentication ---');
      print('Login: $login');
      print('Register: $register');
      print('Change Password: $changePassword');
      print('--- Profile ---');
      print('Index: $index');
      print('--- Loan Management ---');
      print('Loans: $loans');
      print('Certificate: $certificate');
      print('--- Banking ---');
      print('Withdraw Methods: $withdrawMethods');
      print('Withdraw: $withdraw');
      print('Get Bank: $getBank');
      print('Save Bank: $saveBank');
      print('Card: $card');
      print('--- Content ---');
      print('Slides: $slides');
      print('--- Support ---');
      print('About: $about');
      print('Support: $support');
      print('Complaint: $complaint');
      print('====================');
    }
  }
}
