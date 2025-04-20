import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';
import 'package:intl/intl.dart';

class PersonalInfoStepScreen extends StatelessWidget {
  const PersonalInfoStepScreen({super.key});

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'পূর্ণ নাম প্রয়োজন';
    }
    if (value.length < 3) {
      return 'নাম কমপক্ষে ৩ অক্ষরের হতে হবে';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'ফোন নম্বর প্রয়োজন';
    }
    // Remove any spaces or special characters
    String cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\d{10,12}$').hasMatch(cleanPhone)) {
      return 'অনুগ্রহ করে একটি বৈধ ফোন নম্বর দিন (১০-১২ সংখ্যা)';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'ঠিকানা প্রয়োজন';
    }
    if (value.length < 5) {
      return 'অনুগ্রহ করে একটি বৈধ ঠিকানা দিন';
    }
    return null;
  }

  String? validateProfession(String? value) {
    if (value == null || value.isEmpty) {
      return 'পেশা প্রয়োজন';
    }
    if (value.length < 3) {
      return 'অনুগ্রহ করে একটি বৈধ পেশা দিন';
    }
    return null;
  }

  String? validateMonthlyIncome(String? value) {
    if (value == null || value.isEmpty) {
      return 'মাসিক আয় প্রয়োজন';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'অনুগ্রহ করে একটি বৈধ সংখ্যা দিন';
    }
    final income = int.tryParse(value);
    if (income == null || income < 1000) {
      return 'মাসিক আয় কমপক্ষে ১০০০ টাকা হতে হবে';
    }
    return null;
  }

  String? validateLoanPurpose(String? value) {
    if (value == null || value.isEmpty) {
      return 'ঋণের উদ্দেশ্য প্রয়োজন';
    }
    if (value.length < 10) {
      return 'অনুগ্রহ করে ঋণের উদ্দেশ্যের বিবরণ দিন';
    }
    return null;
  }

  String? validateEducation(String? value) {
    if (value == null || value.isEmpty) {
      return 'শিক্ষার তথ্য প্রয়োজন';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(context),
              SizedBox(height: 24),
              _buildTextField(
                context,
                'পূর্ণ নাম',
                provider.nameController,
                prefixIcon: Icons.person_outline,
                validator: validateFullName,
                isReadOnly: provider.isVerified,
              ),
            
            
              SizedBox(height: 16),
              _buildTextField(
                context,
                'ঠিকানা',
                provider.currentAddressController,
                prefixIcon: Icons.home_outlined,
                keyboardType: TextInputType.streetAddress,
                maxLines: 2,
                validator: validateAddress,
                isReadOnly: provider.isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'পেশা',
                provider.professionController,
                prefixIcon: Icons.work_outline,
                validator: validateProfession,
                isReadOnly: provider.isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'মাসিক আয়',
                provider.monthlyIncomeController,
                prefixIcon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                validator: validateMonthlyIncome,
                isReadOnly: provider.isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'ঋণের উদ্দেশ্য',
                provider.loanPurposeController,
                prefixIcon: Icons.assignment_outlined,
                maxLines: 2,
                validator: validateLoanPurpose,
                isReadOnly: provider.isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'শিক্ষা',
                provider.educationController,
                prefixIcon: Icons.school_outlined,
                validator: validateEducation,
                isReadOnly: provider.isVerified,
              ),
              SizedBox(height: 24),
            ],
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
          colors: [Colors.cyan.shade700, Colors.cyan.shade300],
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
                Icons.info_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'ব্যক্তিগত তথ্য',
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
            'আপনার ব্যক্তিগত তথ্য আমাদের সঙ্গে নিরাপদে থাকবে এবং শুধুমাত্র ঋণ অনুমোদনের উদ্দেশ্যে ব্যবহার করা হবে।',
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
  }) {
    // Get provider to check if user is verified
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);
    final bool isVerified = provider.isVerified;

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
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: isReadOnly,
        enabled: !isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? prefixIcon,
    String? Function(String?)? validator,
    bool isReadOnly = false,
  }) {
    // Get provider to check if user is verified
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);
    final bool isVerified = provider.isVerified;

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
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        enabled: !isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}
