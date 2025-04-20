import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';

class BankAccountStepScreen extends StatefulWidget {
  const BankAccountStepScreen({super.key});

  @override
  _BankAccountStepScreenState createState() => _BankAccountStepScreenState();
}

class _BankAccountStepScreenState extends State<BankAccountStepScreen> {
  // Add a state variable to track whether bank details are visible
  bool _showBankDetails = false;

  String? validateAccountHolder(String? value) {
    if (value == null || value.isEmpty) {
      return 'অ্যাকাউন্ট হোল্ডারের নাম প্রয়োজন';
    }
    if (value.length < 3) {
      return 'নাম কমপক্ষে ৩ অক্ষরের হতে হবে';
    }
    
    return null;
  }

  String? validateBankName(String? value) {
    if (value == null || value.isEmpty) {
      return 'ব্যাংকের নাম প্রয়োজন';
    }
    if (value.length < 3) {
      return 'অনুগ্রহ করে একটি বৈধ ব্যাংকের নাম দিন';
    }
    
    return null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'অ্যাকাউন্ট নম্বর প্রয়োজন';
    }
    // Remove any spaces or special characters
    String cleanAccount = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{5,18}$').hasMatch(cleanAccount)) {
      return 'অনুগ্রহ করে একটি বৈধ অ্যাকাউন্ট নম্বর দিন (৯-১৮ সংখ্যা)';
    }
    return null;
  }

  String? validateBranchName(String? value) {
    if (value == null || value.isEmpty) {
      return 'শাখার নাম প্রয়োজন';
    }
    if (value.length < 2) {
      return 'অনুগ্রহ করে একটি বৈধ শাখার নাম দিন';
    }
    return null;
  }

  // Helper method to mask sensitive information
  String maskSensitiveInfo(String text, {bool keepEnds = true}) {
    if (text.isEmpty) return '';
    if (text.length <= 4) return '*' * text.length;

    if (keepEnds) {
      return text.substring(0, 2) +
          '*' * (text.length - 4) +
          text.substring(text.length - 2);
    } else {
      return '*' * text.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        bool isVerified = provider.isVerified;
        // Determine if this is being viewed standalone or as part of multi-step form
        bool isStandalone =
            ModalRoute.of(context)?.settings.name?.contains('/bank_account') ??
                false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button - only show if this is a standalone page
                if (isStandalone)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
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
                _buildInfoCard(context),
                SizedBox(height: 24),

                // Show toggle button only if user is verified
                // This ensures the button only appears after verification
                if (isVerified)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showBankDetails = !_showBankDetails;
                        });
                      },
                      icon: Icon(_showBankDetails
                          ? Icons.visibility_off
                          : Icons.visibility),
                      label: Text(_showBankDetails
                          ? 'ব্যাংক বিবরণ লুকান'
                          : 'ব্যাংক বিবরণ দেখান'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                _buildTextField(
                  context,
                  'অ্যাকাউন্ট হোল্ডারের নাম',
                  provider.accountHolderController,
                  prefixIcon: Icons.person_outline,
                  validator: validateAccountHolder,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  context,
                  'ব্যাংকের নাম',
                  provider.bankNameController,
                  prefixIcon: Icons.account_balance_outlined,
                  validator: validateBankName,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  context,
                  'অ্যাকাউন্ট নম্বর',
                  provider.accountNumberController,
                  prefixIcon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: validateAccountNumber,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  context,
                  'শাখার নাম',
                  provider.ifcCodeController,
                  prefixIcon: Icons.business_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: validateBranchName,
                  isReadOnly: isVerified,
                  isHidden: isVerified && !_showBankDetails,
                ),
                SizedBox(height: 24),
                _buildSecurityNotice(context),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'ব্যাংক অ্যাকাউন্ট বিবরণ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'অনুগ্রহ করে আপনার ব্যাংক অ্যাকাউন্টের বিবরণ প্রদান করুন। এখানেই আমরা আপনার ঋণের পরিমাণ প্রদান করব।',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    bool isHidden = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    // If the field should be hidden, create a masked value
    String displayValue = '';
    if (isHidden) {
      // Different masking for different field types
      if (label == 'অ্যাকাউন্ট নম্বর') {
        displayValue = maskSensitiveInfo(controller.text, keepEnds: true);
      } else {
        displayValue = maskSensitiveInfo(controller.text, keepEnds: false);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isHidden
          ? _buildMaskedField(context, label, displayValue, prefixIcon)
          : TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              readOnly: isReadOnly,
              enabled: !isReadOnly,
              textCapitalization: textCapitalization,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                errorStyle: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
                suffix: isReadOnly
                    ? Icon(Icons.lock, size: 16, color: Colors.grey)
                    : null,
              ),
              onChanged: (value) {
                if (!isReadOnly) {
                  Provider.of<PersonalInfoProvider>(context, listen: false)
                      .saveData();
                }
              },
              validator: isReadOnly ? null : validator,
              autovalidateMode: isReadOnly
                  ? AutovalidateMode.disabled
                  : AutovalidateMode.onUserInteraction,
            ),
    );
  }

  // New widget for displaying masked fields
  Widget _buildMaskedField(
    BuildContext context,
    String label,
    String maskedValue,
    IconData? prefixIcon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: Colors.grey),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  maskedValue,
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'নিরাপত্তা নোটিশ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'আপনার ব্যাংক বিবরণ ব্যাংক-লেভেল এনক্রিপশন দিয়ে সুরক্ষিত রাখা হয়েছে',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'আমরা শুধুমাত্র আপনার ঋণের অর্থ প্রদান করার জন্য এই তথ্য ব্যবহার করব',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'বিলম্ব এড়াতে জমা দেওয়ার আগে বিবরণগুলি যাচাই করুন',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
