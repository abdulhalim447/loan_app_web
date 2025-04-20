import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_bank_loan/core/api/api_service.dart';
import 'dart:io';
import 'dart:typed_data'; // Add import for Uint8List

enum PersonalInfoStep {
  personalInfo,
  nomineeInfo,
  idVerification,
  bankAccount,
}

class PersonalInfoProvider extends ChangeNotifier {
  // Form controllers for personal information
  final TextEditingController nameController = TextEditingController();
  final TextEditingController currentAddressController =
      TextEditingController();

  final TextEditingController professionController = TextEditingController();
  final TextEditingController monthlyIncomeController = TextEditingController();
  final TextEditingController loanPurposeController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  // Form controllers for nominee information
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nomineeRelationController =
      TextEditingController();
  final TextEditingController nomineePhoneController = TextEditingController();

  // Form controllers for ID verification
  final TextEditingController nidNameController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  // Form controllers for bank account
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifcCodeController = TextEditingController();

  // Image paths
  String? frontIdImagePath;
  String? backIdImagePath;
  String? selfieWithIdImagePath;
  String? signatureImagePath;

  // Image binary data for direct uploads (especially for web)
  Uint8List? frontIdImageBytes;
  Uint8List? backIdImageBytes;
  Uint8List? selfieWithIdImageBytes;
  Uint8List? signatureImageBytes;

  // Image URLs from API
  String? frontIdImageUrl;
  String? backIdImageUrl;
  String? selfieWithIdImageUrl;
  String? signatureImageUrl;

  // Verification status
  bool _isVerified = false;
  bool get isVerified => _isVerified;

  // API service
  final ApiService _apiService = ApiService();

  // Current step and form completion status
  PersonalInfoStep _currentStep = PersonalInfoStep.personalInfo;
  bool _personalInfoCompleted = false;
  bool _nomineeInfoCompleted = false;
  bool _idVerificationCompleted = false;
  bool _bankAccountCompleted = false;

  // Getters
  PersonalInfoStep get currentStep => _currentStep;
  bool get personalInfoCompleted => _personalInfoCompleted;
  bool get nomineeInfoCompleted => _nomineeInfoCompleted;
  bool get idVerificationCompleted => _idVerificationCompleted;
  bool get bankAccountCompleted => _bankAccountCompleted;

  // Calculate progress (0.0 to 1.0)
  double getProgress() {
    switch (_currentStep) {
      case PersonalInfoStep.personalInfo:
        return 0.25;
      case PersonalInfoStep.nomineeInfo:
        return 0.5;
      case PersonalInfoStep.idVerification:
        return 0.75;
      case PersonalInfoStep.bankAccount:
        return 1.0;
    }
  }

  // Initialize provider and load saved data
  Future<void> initialize() async {
    try {
      // First try to fetch from API
      final response = await _apiService.fetchPersonalInfo();

      if (response.success) {
        // Check if status is 1
        _isVerified = response.data?['status'] == 1;

        if (_isVerified && response.data != null) {
          // Fill all form controllers with API data
          _fillFormControllersFromApi(response.data!);

          // Mark all steps as completed
          _personalInfoCompleted = true;
          _nomineeInfoCompleted = true;
          _idVerificationCompleted = true;
          _bankAccountCompleted = true;

          notifyListeners();
          return;
        }
      }

      // If API failed or user is not verified, load from local storage
      await loadSavedData();
    } catch (e) {
      debugPrint("Error initializing PersonalInfoProvider: $e");
      // Continue without the saved data in case of error
      await loadSavedData();
    }
  }

  // Fill form controllers from API data
  void _fillFormControllersFromApi(Map<String, dynamic> data) {
    // Personal info
    nameController.text = data['name'] ?? '';
    currentAddressController.text = data['currentAddress'] ?? '';
    professionController.text = data['profession'] ?? '';
    monthlyIncomeController.text = data['income'] ?? '';
    loanPurposeController.text = data['loanPurpose'] ?? '';
    educationController.text = data['education'] ?? '';

    // Nominee info
    nomineeNameController.text = data['nomineeName'] ?? '';
    nomineeRelationController.text = data['nomineeRelation'] ?? '';
    nomineePhoneController.text = data['nomineePhone'] ?? '';

    // ID verification
    nidNameController.text = data['nidName'] ?? '';
    idController.text = data['nidNumber'] ?? '';

    // Bank info
    accountHolderController.text = data['bankuserName'] ?? '';
    bankNameController.text = data['bankName'] ?? '';
    accountNumberController.text = data['account'] ?? '';
    ifcCodeController.text = data['branchName'] ?? '';

    // Image URLs
    selfieWithIdImageUrl = data['selfie'];
    frontIdImageUrl = data['nidFrontImage'];
    backIdImageUrl = data['nidBackImage'];
    signatureImageUrl = data['signature'];
  }

  // Set current step
  void setStep(PersonalInfoStep step) {
    _currentStep = step;
    notifyListeners();
  }

  // Move to next step
  void nextStep() {
    switch (_currentStep) {
      case PersonalInfoStep.personalInfo:
        _personalInfoCompleted = true;
        _currentStep = PersonalInfoStep.nomineeInfo;
        break;
      case PersonalInfoStep.nomineeInfo:
        _nomineeInfoCompleted = true;
        _currentStep = PersonalInfoStep.idVerification;
        break;
      case PersonalInfoStep.idVerification:
        _idVerificationCompleted = true;
        _currentStep = PersonalInfoStep.bankAccount;
        break;
      case PersonalInfoStep.bankAccount:
        _bankAccountCompleted = true;
        // Form is complete
        break;
    }

    saveData();
    notifyListeners();
  }

  // Move to previous step
  void previousStep() {
    switch (_currentStep) {
      case PersonalInfoStep.personalInfo:
        // Already at first step
        break;
      case PersonalInfoStep.nomineeInfo:
        _currentStep = PersonalInfoStep.personalInfo;
        break;
      case PersonalInfoStep.idVerification:
        _currentStep = PersonalInfoStep.nomineeInfo;
        break;
      case PersonalInfoStep.bankAccount:
        _currentStep = PersonalInfoStep.idVerification;
        break;
    }

    notifyListeners();
  }

  // Save image paths
  void saveImagePath(String type, String path) {
    switch (type) {
      case 'front':
        frontIdImagePath = path;
        // If path is empty, also clear the bytes
        if (path.isEmpty) {
          frontIdImageBytes = null;
        }
        break;
      case 'back':
        backIdImagePath = path;
        // If path is empty, also clear the bytes
        if (path.isEmpty) {
          backIdImageBytes = null;
        }
        break;
      case 'selfie':
        selfieWithIdImagePath = path;
        // If path is empty, also clear the bytes
        if (path.isEmpty) {
          selfieWithIdImageBytes = null;
        }
        break;
      case 'signature':
        signatureImagePath = path;
        // If path is empty, also clear the bytes
        if (path.isEmpty) {
          signatureImageBytes = null;
        }
        break;
    }

    saveData();
    notifyListeners();
  }

  // Save image bytes for direct uploads
  void saveImageBytes(String type, Uint8List bytes) {
    debugPrint("Saving image bytes for type: $type with ${bytes.length} bytes");

    switch (type) {
      case 'front':
        frontIdImageBytes = bytes;
        frontIdImagePath = 'image_selected'; // Set placeholder path for UI
        break;
      case 'back':
        backIdImageBytes = bytes;
        backIdImagePath = 'image_selected'; // Set placeholder path for UI
        break;
      case 'selfie':
        selfieWithIdImageBytes = bytes;
        selfieWithIdImagePath = 'image_selected'; // Set placeholder path for UI
        break;
      case 'signature':
        signatureImageBytes = bytes;
        signatureImagePath = 'image_selected'; // Set placeholder path for UI
        break;
    }

    saveData();
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    // Clear form controllers
    nameController.clear();
    currentAddressController.clear();

    professionController.clear();
    monthlyIncomeController.clear();
    loanPurposeController.clear();
    educationController.clear();

    nomineeNameController.clear();
    nomineeRelationController.clear();
    nomineePhoneController.clear();

    nidNameController.clear();
    idController.clear();

    accountHolderController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    ifcCodeController.clear();

    // Clear image paths
    frontIdImagePath = null;
    backIdImagePath = null;
    selfieWithIdImagePath = null;
    signatureImagePath = null;

    // Clear image bytes
    frontIdImageBytes = null;
    backIdImageBytes = null;
    selfieWithIdImageBytes = null;
    signatureImageBytes = null;

    // Reset step and completion status
    _currentStep = PersonalInfoStep.personalInfo;
    _personalInfoCompleted = false;
    _nomineeInfoCompleted = false;
    _idVerificationCompleted = false;
    _bankAccountCompleted = false;

    // Clear saved data
    clearSavedData();

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save form data
      await prefs.setString('pi_name', nameController.text);
      await prefs.setString('pi_currentAddress', currentAddressController.text);
 
      await prefs.setString('pi_profession', professionController.text);
      await prefs.setString('pi_monthlyIncome', monthlyIncomeController.text);
      await prefs.setString('pi_loanPurpose', loanPurposeController.text);
      await prefs.setString('pi_education', educationController.text);

      await prefs.setString('pi_nomineeName', nomineeNameController.text);
      await prefs.setString(
          'pi_nomineeRelation', nomineeRelationController.text);
      await prefs.setString('pi_nomineePhone', nomineePhoneController.text);

      await prefs.setString('pi_nidName', nidNameController.text);
      await prefs.setString('pi_id', idController.text);

      await prefs.setString('pi_accountHolder', accountHolderController.text);
      await prefs.setString('pi_bankName', bankNameController.text);
      await prefs.setString('pi_accountNumber', accountNumberController.text);
      await prefs.setString('pi_ifcCode', ifcCodeController.text);

      // Save image paths
      if (frontIdImagePath != null) {
        await prefs.setString('pi_frontIdImagePath', frontIdImagePath!);
      }
      if (backIdImagePath != null) {
        await prefs.setString('pi_backIdImagePath', backIdImagePath!);
      }
      if (selfieWithIdImagePath != null) {
        await prefs.setString(
            'pi_selfieWithIdImagePath', selfieWithIdImagePath!);
      }
      if (signatureImagePath != null) {
        await prefs.setString('pi_signatureImagePath', signatureImagePath!);
      }

      // Save step and completion status
      await prefs.setInt('pi_currentStep', _currentStep.index);
      await prefs.setBool('pi_personalInfoCompleted', _personalInfoCompleted);
      await prefs.setBool('pi_nomineeInfoCompleted', _nomineeInfoCompleted);
      await prefs.setBool(
          'pi_idVerificationCompleted', _idVerificationCompleted);
      await prefs.setBool('pi_bankAccountCompleted', _bankAccountCompleted);
    } catch (e) {
      debugPrint("Error saving personal info data: $e");
      // Continue even if data couldn't be saved
    }
  }

  // Load data from SharedPreferences
  Future<void> loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load form data
      nameController.text = prefs.getString('pi_name') ?? '';
      currentAddressController.text =
          prefs.getString('pi_currentAddress') ?? '';
     
      professionController.text = prefs.getString('pi_profession') ?? '';
      monthlyIncomeController.text = prefs.getString('pi_monthlyIncome') ?? '';
      loanPurposeController.text = prefs.getString('pi_loanPurpose') ?? '';
      educationController.text = prefs.getString('pi_education') ?? '';

      nomineeNameController.text = prefs.getString('pi_nomineeName') ?? '';
      nomineeRelationController.text =
          prefs.getString('pi_nomineeRelation') ?? '';
      nomineePhoneController.text = prefs.getString('pi_nomineePhone') ?? '';

      nidNameController.text = prefs.getString('pi_nidName') ?? '';
      idController.text = prefs.getString('pi_id') ?? '';

      accountHolderController.text = prefs.getString('pi_accountHolder') ?? '';
      bankNameController.text = prefs.getString('pi_bankName') ?? '';
      accountNumberController.text = prefs.getString('pi_accountNumber') ?? '';
      ifcCodeController.text = prefs.getString('pi_ifcCode') ?? '';

      // Load image paths
      frontIdImagePath = prefs.getString('pi_frontIdImagePath');
      backIdImagePath = prefs.getString('pi_backIdImagePath');
      selfieWithIdImagePath = prefs.getString('pi_selfieWithIdImagePath');
      signatureImagePath = prefs.getString('pi_signatureImagePath');

      // Load step and completion status
      final stepIndex = prefs.getInt('pi_currentStep');
      if (stepIndex != null &&
          stepIndex >= 0 &&
          stepIndex < PersonalInfoStep.values.length) {
        _currentStep = PersonalInfoStep.values[stepIndex];
      }

      _personalInfoCompleted =
          prefs.getBool('pi_personalInfoCompleted') ?? false;
      _nomineeInfoCompleted = prefs.getBool('pi_nomineeInfoCompleted') ?? false;
      _idVerificationCompleted =
          prefs.getBool('pi_idVerificationCompleted') ?? false;
      _bankAccountCompleted = prefs.getBool('pi_bankAccountCompleted') ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading personal info data: $e");
      // Reset to default state in case of error
      _currentStep = PersonalInfoStep.personalInfo;
      _personalInfoCompleted = false;
      _nomineeInfoCompleted = false;
      _idVerificationCompleted = false;
      _bankAccountCompleted = false;
    }
  }

  // Clear saved data
  Future<void> clearSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all personal info related keys
      final keys =
          prefs.getKeys().where((key) => key.startsWith('pi_')).toList();
      for (var key in keys) {
        await prefs.remove(key);
      }

      // Clear all form controllers
      nameController.clear();
      currentAddressController.clear();
     
      professionController.clear();
      monthlyIncomeController.clear();
      loanPurposeController.clear();
      educationController.clear();

      nomineeNameController.clear();
      nomineeRelationController.clear();
      nomineePhoneController.clear();

      nidNameController.clear();
      idController.clear();

      accountHolderController.clear();
      bankNameController.clear();
      accountNumberController.clear();
      ifcCodeController.clear();

      // Clear image paths
      frontIdImagePath = null;
      backIdImagePath = null;
      selfieWithIdImagePath = null;
      signatureImagePath = null;

      // Clear image bytes
      frontIdImageBytes = null;
      backIdImageBytes = null;
      selfieWithIdImageBytes = null;
      signatureImageBytes = null;

      // Reset step and completion status
      _currentStep = PersonalInfoStep.personalInfo;
      _personalInfoCompleted = false;
      _nomineeInfoCompleted = false;
      _idVerificationCompleted = false;
      _bankAccountCompleted = false;

      // Reset verification status if needed
      // Note: We typically don't want to reset verification status as it comes from the server
      // _isVerified = false;

      debugPrint("All personal information data cleared successfully");

      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing personal info data: $e");
      // Continue even if data couldn't be cleared
    }
  }

  // Dispose resources
  @override
  void dispose() {
    // Dispose all TextEditingControllers
    nameController.dispose();
    currentAddressController.dispose();
  
    professionController.dispose();
    monthlyIncomeController.dispose();
    loanPurposeController.dispose();
    educationController.dispose();

    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    nomineePhoneController.dispose();

    nidNameController.dispose();
    idController.dispose();

    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifcCodeController.dispose();

    super.dispose();
  }

  void clearSignature() {
    signatureImagePath = null;
    signatureImageBytes = null;
    notifyListeners();
  }

  bool get hasSignature =>
      (signatureImageBytes != null) ||
      (signatureImagePath != null &&
          signatureImagePath!.isNotEmpty &&
          (signatureImagePath == 'image_selected' ||
              signatureImagePath == 'signature_provided' ||
              signatureImagePath!.startsWith('blob:') || // Handle web blob URLs
              signatureImagePath!.startsWith('data:') || // Handle web data URLs
              File(signatureImagePath!).existsSync()));

  bool validatePersonalInfo() {
    return nameController.text.isNotEmpty &&
        currentAddressController.text.isNotEmpty &&
      
        professionController.text.isNotEmpty &&
        monthlyIncomeController.text.isNotEmpty &&
        loanPurposeController.text.isNotEmpty &&
        educationController.text.isNotEmpty;
  }

  bool validateNomineeInfo() {
    return nomineeNameController.text.isNotEmpty &&
        nomineeRelationController.text.isNotEmpty &&
        nomineePhoneController.text.isNotEmpty;
  }

  bool validateIdVerification() {
    // Check for image bytes (especially for web)
    bool hasFrontIdImage = frontIdImageBytes != null ||
        (frontIdImagePath != null && frontIdImagePath!.isNotEmpty);

    bool hasBackIdImage = backIdImageBytes != null ||
        (backIdImagePath != null && backIdImagePath!.isNotEmpty);

    bool hasSelfieImage = selfieWithIdImageBytes != null ||
        (selfieWithIdImagePath != null && selfieWithIdImagePath!.isNotEmpty);

    return nidNameController.text.isNotEmpty &&
        idController.text.isNotEmpty &&
        hasFrontIdImage &&
        hasBackIdImage &&
        hasSelfieImage;
  }

  bool validateBankAccount() {
    return accountHolderController.text.isNotEmpty &&
        bankNameController.text.isNotEmpty &&
        accountNumberController.text.isNotEmpty &&
        ifcCodeController.text.isNotEmpty;
  }
}
