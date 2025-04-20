import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:world_bank_loan/providers/personal_info_provider.dart';
import 'package:world_bank_loan/screens/loan_apply_screen/loan_apply_screen.dart';
import 'package:world_bank_loan/core/api/api_service.dart';
import 'package:world_bank_loan/auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/widgets/responsive_screen.dart';
import 'steps/personal_info_step.dart';
import 'steps/nominee_info_step.dart';
import 'steps/id_verification_step.dart';
import 'steps/bank_account_step.dart';
import 'package:flutter/foundation.dart';

class MultiStepPersonalInfoForm extends StatefulWidget {
  const MultiStepPersonalInfoForm({super.key});

  @override
  _MultiStepPersonalInfoFormState createState() =>
      _MultiStepPersonalInfoFormState();
}

class _MultiStepPersonalInfoFormState extends State<MultiStepPersonalInfoForm> {
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nomineeInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _idVerificationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bankAccountFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // The provider is already initialized in PersonalInfoScreen
    // No need to reinitialize here to avoid concurrent initializations
  }

  bool validateCurrentStep(PersonalInfoProvider provider) {
    switch (provider.currentStep) {
      case PersonalInfoStep.personalInfo:
        if (_personalInfoFormKey.currentState?.validate() ?? false) {
          return provider.validatePersonalInfo();
        }
        return false;

      case PersonalInfoStep.nomineeInfo:
        if (_nomineeInfoFormKey.currentState?.validate() ?? false) {
          return provider.validateNomineeInfo();
        }
        return false;

      case PersonalInfoStep.idVerification:
        if (_idVerificationFormKey.currentState?.validate() ?? false) {
          return provider.validateIdVerification();
        }
        return false;

      case PersonalInfoStep.bankAccount:
        if (_bankAccountFormKey.currentState?.validate() ?? false) {
          return provider.validateBankAccount();
        }
        return false;
    }
  }

  void showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        final content = Column(
          children: [
            _buildProgressBar(provider),
            Expanded(
              child: _buildCurrentStep(provider),
            ),
            _buildNavigationButtons(provider),
          ],
        );

        return content.asResponsiveScreen();
      },
    );
  }

  Widget _buildProgressBar(PersonalInfoProvider provider) {
    final currentStep = provider.currentStep;
    final stepCount = PersonalInfoStep.values.length;
    final progress = provider.getProgress();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button for all steps
              GestureDetector(
                onTap: () {
                  // For first step, navigate back to previous screen
                  // For other steps, go to previous step in the form
                  if (currentStep == PersonalInfoStep.personalInfo) {
                    Navigator.pop(context);
                  } else {
                    provider.previousStep();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ধাপ ${currentStep.index + 1} এর $stepCount',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _getStepTitle(currentStep),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            _getStepSubtitle(currentStep),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          // Step indicators
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < stepCount; i++)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        i <= currentStep.index ? Colors.cyan : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(PersonalInfoProvider provider) {
    switch (provider.currentStep) {
      case PersonalInfoStep.personalInfo:
        return Form(
          key: _personalInfoFormKey,
          child: PersonalInfoStepScreen(),
        );
      case PersonalInfoStep.nomineeInfo:
        return Form(
          key: _nomineeInfoFormKey,
          child: NomineeInfoStepScreen(),
        );
      case PersonalInfoStep.idVerification:
        return Form(
          key: _idVerificationFormKey,
          child: IdVerificationStepScreen(),
        );
      case PersonalInfoStep.bankAccount:
        return Form(
          key: _bankAccountFormKey,
          child: BankAccountStepScreen(),
        );
    }
  }

  Widget _buildNavigationButtons(PersonalInfoProvider provider) {
    final isLastStep = provider.currentStep == PersonalInfoStep.bankAccount;
    final isFirstStep = provider.currentStep == PersonalInfoStep.personalInfo;
    final isVerified = provider.isVerified;

    // Only disable button if it's the last step (Submit) and user is verified
    final bool disableButton = isLastStep && isVerified;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Show verification status only on last screen if verified
          if (isLastStep && isVerified)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'আপনার ব্যক্তিগত তথ্য যাচাই করা হয়েছে। জমা দেওয়া নিষ্ক্রিয় করা হয়েছে।',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              // Back button in bottom navigation
              if (!isFirstStep)
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => provider.previousStep(),
                    icon: Icon(Icons.arrow_back),
                    label: Text('পিছনে'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.cyan),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              // Spacer when showing both buttons
              if (!isFirstStep) SizedBox(width: 16),
              // Continue/Submit button - only disable on last screen when verified
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: disableButton
                      ? null
                      : () {
                          // Skip validation if user is verified
                          if (isVerified) {
                            if (isLastStep) {
                              // Do nothing - button should be disabled
                            } else {
                              provider.nextStep();
                            }
                            return;
                          }

                          // Only run validation if user is not verified
                          if (!validateCurrentStep(provider)) {
                            String errorMessage = '';
                            switch (provider.currentStep) {
                              case PersonalInfoStep.personalInfo:
                                errorMessage =
                                    'অনুগ্রহ করে সমস্ত ব্যক্তিগত তথ্য ফিল্ডগুলি সঠিকভাবে পূরণ করুন';
                                break;
                              case PersonalInfoStep.nomineeInfo:
                                errorMessage =
                                    'অনুগ্রহ করে সমস্ত মনোনীত ব্যক্তির তথ্য ফিল্ডগুলি সঠিকভাবে পূরণ করুন';
                                break;
                              case PersonalInfoStep.idVerification:
                                // Simple error message that doesn't check for signature
                                if (provider.frontIdImagePath == null ||
                                    provider.frontIdImagePath!.isEmpty) {
                                  errorMessage =
                                      'অনুগ্রহ করে আপনার এনআইডির সামনের অংশ আপলোড করুন';
                                } else if (provider.backIdImagePath == null ||
                                    provider.backIdImagePath!.isEmpty) {
                                  errorMessage =
                                      'অনুগ্রহ করে আপনার এনআইডির পিছনের অংশ আপলোড করুন';
                                } else if (provider.selfieWithIdImagePath ==
                                        null ||
                                    provider.selfieWithIdImagePath!.isEmpty) {
                                  errorMessage =
                                      'অনুগ্রহ করে আপনার এনআইডির সাথে একটি সেলফি তুলুন';
                                } else {
                                  errorMessage =
                                      'অনুগ্রহ করে সমস্ত প্রয়োজনীয় নথি সহ আইডি যাচাইকরণ সম্পূর্ণ করুন';
                                }
                                break;
                              case PersonalInfoStep.bankAccount:
                                errorMessage =
                                    'অনুগ্রহ করে সমস্ত ব্যাংক অ্যাকাউন্টের বিবরণ সঠিকভাবে পূরণ করুন';
                                break;
                            }
                            showValidationError(errorMessage);
                            return;
                          }

                          if (isLastStep) {
                            _submitForm();
                          } else {
                            provider.nextStep();
                          }
                        },
                  icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                  label: Text(isLastStep ? 'জমা দিন' : 'পরবর্তী'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle(PersonalInfoStep step) {
    switch (step) {
      case PersonalInfoStep.personalInfo:
        return 'ব্যক্তিগত তথ্য';
      case PersonalInfoStep.nomineeInfo:
        return 'মনোনীত ব্যক্তির তথ্য';
      case PersonalInfoStep.idVerification:
        return 'আইডি যাচাইকরণ';
      case PersonalInfoStep.bankAccount:
        return 'ব্যাংক অ্যাকাউন্ট';
    }
  }

  String _getStepSubtitle(PersonalInfoStep step) {
    switch (step) {
      case PersonalInfoStep.personalInfo:
        return 'আপনার মৌলিক বিবরণ';
      case PersonalInfoStep.nomineeInfo:
        return 'আপনার অ্যাকাউন্টের জন্য একজন মনোনীত ব্যক্তি যোগ করুন';
      case PersonalInfoStep.idVerification:
        return 'আপনার আইডি ডকুমেন্ট আপলোড করুন';
      case PersonalInfoStep.bankAccount:
        return 'আপনার ব্যাংক অ্যাকাউন্টের বিবরণ যোগ করুন';
    }
  }

  Future<void> _submitForm() async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);
    final apiService = ApiService();

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Colors.cyan,
          ),
        ),
      );

      // Verify token is available before proceeding
      final token = await UserSession.getToken();
      if (token == null || token.isEmpty) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show error for missing token
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('প্রমাণীকরণ ত্রুটি'),
              ],
            ),
            content: Text(
                'ব্যক্তিগত তথ্য জমা দিতে আপনাকে লগইন করতে হবে। অনুগ্রহ করে আবার লগইন করুন।'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text('ঠিক আছে'),
              ),
            ],
          ),
        );
        return;
      }

      // Handle both web and mobile platforms with a unified approach
      // Check for binary image data first (especially for web)
      File? selfieFile;
      File? nidFrontFile;
      File? nidBackFile;
      File? signatureFile;

      // Handle web platform
      if (kIsWeb) {
        // Validate image data
        if (provider.selfieWithIdImageBytes == null) {
          throw Exception('Selfie image is required');
        }
        if (provider.frontIdImageBytes == null) {
          throw Exception('Front ID image is required');
        }
        if (provider.backIdImageBytes == null) {
          throw Exception('Back ID image is required');
        }

        // For web, use the modified API call that handles multipart uploads with direct byte data
        if (kDebugMode) {
          print('Web form submission with direct binary data:');
          print('name: ${provider.nameController.text}');
          print(
              'Image data available: ${provider.selfieWithIdImageBytes != null}, ${provider.frontIdImageBytes != null}, ${provider.backIdImageBytes != null}, ${provider.signatureImageBytes != null}');
        }

        final response = await apiService.submitPersonalInfoWithImageBytes(
          name: provider.nameController.text.trim(),
          loanPurpose: provider.loanPurposeController.text.trim(),
          profession: provider.professionController.text.trim(),
          nomineeRelation: provider.nomineeRelationController.text.trim(),
          nomineePhone: provider.nomineePhoneController.text.trim(),
          nomineeName: provider.nomineeNameController.text.trim(),
          selfieBytes: provider.selfieWithIdImageBytes!,
          nidFrontBytes: provider.frontIdImageBytes!,
          nidBackBytes: provider.backIdImageBytes!,
          signatureBytes: provider.signatureImageBytes,
          income: provider.monthlyIncomeController.text.trim(),
          bankuserName: provider.accountHolderController.text.trim(),
          bankName: provider.bankNameController.text.trim(),
          account: provider.accountNumberController.text.trim(),
          branchName: provider.ifcCodeController.text.trim(),
          nidNumber: provider.idController.text.trim(),
          edu: provider.educationController.text.isNotEmpty
              ? provider.educationController.text.trim()
              : 'Honors',
          currentAddress: provider.currentAddressController.text.trim(),
        );

        // Close the loading dialog
        Navigator.of(context).pop();

        // Show success or error dialog based on response
        _handleSubmissionResponse(response);
        return;
      }

      // Mobile implementation - read files into memory at submission time
      try {
        // Check if we have paths to images
        if (provider.selfieWithIdImagePath == null ||
            provider.selfieWithIdImagePath!.isEmpty) {
          throw Exception('Selfie image is required');
        }
        if (provider.frontIdImagePath == null ||
            provider.frontIdImagePath!.isEmpty) {
          throw Exception('Front ID image is required');
        }
        if (provider.backIdImagePath == null ||
            provider.backIdImagePath!.isEmpty) {
          throw Exception('Back ID image is required');
        }

        // Create File objects from paths
        selfieFile = File(provider.selfieWithIdImagePath!);
        nidFrontFile = File(provider.frontIdImagePath!);
        nidBackFile = File(provider.backIdImagePath!);

        // Handle signature if available
        if (provider.signatureImagePath != null &&
            provider.signatureImagePath!.isNotEmpty) {
          signatureFile = File(provider.signatureImagePath!);
        }

        // Verify files exist
        if (!await selfieFile.exists()) {
          throw Exception('Selfie image file not found');
        }
        if (!await nidFrontFile.exists()) {
          throw Exception('Front ID image file not found');
        }
        if (!await nidBackFile.exists()) {
          throw Exception('Back ID image file not found');
        }

        // Make the API call for mobile platforms with actual Files
        final response = await apiService.submitPersonalInfo(
          name: provider.nameController.text,
          loanPurpose: provider.loanPurposeController.text,
          profession: provider.professionController.text,
          nomineeRelation: provider.nomineeRelationController.text,
          nomineePhone: provider.nomineePhoneController.text,
          nomineeName: provider.nomineeNameController.text,
          selfie: selfieFile,
          nidFrontImage: nidFrontFile,
          nidBackImage: nidBackFile,
          signature: signatureFile ??
              selfieFile, // Use selfie as fallback if no signature
          income: provider.monthlyIncomeController.text,
          bankuserName: provider.accountHolderController.text,
          bankName: provider.bankNameController.text,
          account: provider.accountNumberController.text,
          branchName: provider.ifcCodeController.text,
          nidNumber: provider.idController.text,
          edu: provider.educationController.text.isNotEmpty
              ? provider.educationController.text
              : 'Honors',
          currentAddress: provider.currentAddressController.text,
        );

        // Close the loading dialog
        Navigator.of(context).pop();

        // Handle the response
        _handleSubmissionResponse(response);
      } catch (e) {
        throw Exception('Error processing mobile image files: $e');
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.of(context).pop();

      // Show an error toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Helper method to validate web image paths
  bool _isValidWebImagePath(String path) {
    return path.startsWith('blob:') || path.startsWith('data:');
  }

  // Helper method to handle API response
  void _handleSubmissionResponse(dynamic response) {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    if (response.success) {
      // Show success toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ব্যক্তিগত তথ্য সফলভাবে জমা দেওয়া হয়েছে!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Clear all locally stored personal information data
      provider.clearSavedData().then((_) {
        debugPrint(
            'Successfully cleared locally stored personal information data');
      }).catchError((error) {
        debugPrint('Error clearing locally stored data: $error');
      });

      // Automatically navigate to loan application screen
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoanApplicationScreen(),
          ),
        );
      });
    } else {
      // Show an error toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('তথ্য জমা দিতে ব্যর্থ: ${response.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'বাতিল',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
