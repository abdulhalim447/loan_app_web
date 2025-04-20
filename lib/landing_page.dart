import 'package:flutter/material.dart';
import 'package:world_bank_loan/auth/LoginScreen.dart';
import 'package:world_bank_loan/auth/SignupScreen.dart';
import 'package:world_bank_loan/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.authorityBlue,
        title: Text(
          "ওয়ার্ল্ড ব্যাংক",
          style: TextStyle(
            fontSize: screenWidth > 600 ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.neutral100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth > 600 ? 600 : double.infinity,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 32 : 20,
                    vertical: screenWidth > 600 ? 32 : 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bank Logo
                      Container(
                        margin: EdgeInsets.only(
                            bottom: screenWidth > 600 ? 24 : 20),
                        height: screenWidth > 600 ? 120 : 100,
                        width: screenWidth > 600 ? 120 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.authorityBlue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.public,
                          size: screenWidth > 600 ? 60 : 48,
                          color: Colors.white,
                        ),
                      ),

                      // Bank Title
                      Text(
                        'ওয়ার্ল্ড ব্যাংক',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.authorityBlue,
                          letterSpacing: 0.5,
                        ),
                      ),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: Text(
                          'টেকসই আর্থিক সমাধানের মাধ্যমে অর্থনৈতিক বৃদ্ধিতে সহায়তা করা',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 16 : 14,
                            color: AppTheme.neutral700,
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: screenWidth > 600 ? 40 : 32),

                      // Buttons
                      _buildButton(
                        'অ্যাকাউন্ট রেজিস্টার করুন',
                        () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));
                        },
                        screenWidth,
                        isPrimary: true,
                      ),
                      SizedBox(height: screenWidth > 600 ? 16 : 12),
                      _buildButton(
                        'অ্যাকাউন্টে লগইন করুন',
                        () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        screenWidth,
                        isPrimary: false,
                      ),
                      SizedBox(height: screenWidth > 600 ? 16 : 12),
                      _buildDownloadButton(
                        "মোবাইল অ্যাপ ডাউনলোড করুন",
                        () {
                          showDownloadDialog(context);
                        },
                        screenWidth,
                      ),

                      // Add some bottom padding to ensure content is not cut off
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, double screenWidth,
      {bool isPrimary = true}) {
    return SizedBox(
      width: double.infinity,
      height: screenWidth > 600 ? 56 : 50,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authorityBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppTheme.authorityBlue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(screenWidth > 600 ? 12 : 10),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.authorityBlue, width: 1.5),
                foregroundColor: AppTheme.authorityBlue,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(screenWidth > 600 ? 12 : 10),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildDownloadButton(
      String text, VoidCallback onPressed, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      height: screenWidth > 600 ? 56 : 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.download_rounded),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.trustCyan,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.trustCyan.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth > 600 ? 12 : 10),
          ),
        ),
      ),
    );
  }

  void showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DownloadProgressDialog(
          onDownloadComplete: () {
            Navigator.pop(context);
            showInstallDialog(context);
          },
        );
      },
    );
  }

  void showInstallDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ডাউনলোড সম্পন্ন',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.authorityBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'আপনি কি অ্যাপটি ইনস্টল করতে চান?',
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 16 : 14,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ফাইল সাইজ: 20MB',
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 14 : 12,
                  color: AppTheme.neutral600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'বাতিল করুন',
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 16 : 14,
                  color: AppTheme.neutral700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Simplified download function that doesn't use HTML APIs
                _downloadMobileApp(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authorityBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'এখনই ইনস্টল করুন',
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 4,
        );
      },
    );
  }

  // Simplified method that doesn't use HTML APIs
  void _downloadMobileApp(BuildContext context) {
    const apkUrl =
        "https://tdnmidmithiggpzojxyf.supabase.co/storage/v1/object/public/app//wbl.apk";
    // Open the APK download link
    launchUrl(Uri.parse(apkUrl));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ডাউনলোড পেজে যাওয়া হচ্ছে...'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}

// Restored DownloadProgressDialog class
class DownloadProgressDialog extends StatefulWidget {
  final VoidCallback onDownloadComplete;

  const DownloadProgressDialog({super.key, required this.onDownloadComplete});

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  bool _isDownloading = true;
  String _status = 'ডাউনলোড প্রস্তুত করা হচ্ছে...';

  @override
  void initState() {
    super.initState();
    _simulateDownload();
  }

  void _simulateDownload() async {
    // Simulate download progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _progress = i / 100;
          _status = 'ডাউনলোড হচ্ছে... $i%';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isDownloading = false;
        _status = 'ডাউনলোড সম্পন্ন!';
      });

      // Wait a moment to show completion
      await Future.delayed(Duration(seconds: 1));
      widget.onDownloadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: Text(
        'অ্যাপ ডাউনলোড হচ্ছে',
        style: TextStyle(
          fontSize: screenWidth > 600 ? 20 : 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.authorityBlue,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _status,
            style: TextStyle(
              fontSize: screenWidth > 600 ? 16 : 14,
              color: _isDownloading ? AppTheme.authorityBlue : AppTheme.success,
              fontWeight: _isDownloading ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth > 600 ? 16 : 10),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppTheme.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
                _isDownloading ? AppTheme.trustCyan : AppTheme.success),
            minHeight: screenWidth > 600 ? 8 : 6,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: screenWidth > 600 ? 16 : 10),
          Text(
            'ফাইল সাইজ: ২০ এমবি',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 14 : 12,
              color: AppTheme.neutral600,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      elevation: 4,
    );
  }
}
