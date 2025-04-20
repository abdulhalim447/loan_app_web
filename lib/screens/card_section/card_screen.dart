import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_screen.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Set status bar icons to white
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _initializeCardData();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCardData() async {
    if (!mounted || _isDisposed) return;

    final provider = Provider.of<CardProvider>(context, listen: false);
    try {
      await provider.fetchCardData();
      // Check if still mounted after async operation
      if (mounted && !_isDisposed) {
        _animationController.forward();
      }
    } catch (e) {
      print('Error initializing card data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, provider, _) {
        // Build card screen appBar
        final cardAppBar = AppBar(
          elevation: 0,
          backgroundColor: AppTheme.authorityBlue,
          centerTitle: true,
          title: Text(
            'আমার কার্ড',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (provider.status == CardLoadingStatus.loaded)
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  if (!mounted || _isDisposed) return;
                  provider.fetchCardData();
                  if (!_isDisposed) {
                    _animationController.reset();
                    _animationController.forward();
                  }
                },
              ),
          ],
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        );

        // Build card screen content
        final cardContent = Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.authorityBlue,
                    AppTheme.trustCyan,
                    AppTheme.backgroundLight,
                  ],
                  stops: [0.0, 0.2, 0.4],
                ),
              ),
            ),

            SafeArea(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildBody(provider, context),
                    ),
                  );
                },
              ),
            ),
          ],
        );

        // Use the responsive wrapper
        return cardContent.asResponsiveScreen(
          appBar: cardAppBar,
          extendBodyBehindAppBar: true,
        );
      },
    );
  }

  Widget _buildBody(CardProvider provider, BuildContext context) {
    switch (provider.status) {
      case CardLoadingStatus.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                "আপনার কার্ডের বিবরণ লোড হচ্ছে...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      case CardLoadingStatus.error:
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red[400],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "কার্ডের বিবরণ লোড করা যায়নি",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral800,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? "একটি অজানা ত্রুটি ঘটেছে",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.neutral600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (!mounted || _isDisposed) return;
                    provider.fetchCardData();
                    if (!_isDisposed) {
                      _animationController.reset();
                      _animationController.forward();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authorityBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'আবার চেষ্টা করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case CardLoadingStatus.loaded:
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreditCard(provider, context),
              SizedBox(height: 24),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardDetails(provider),
                    
                  
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      default: // Initial state or any other state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                "প্রস্তুত হচ্ছে...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildCreditCard(CardProvider provider, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Limit card width for web platforms to prevent oversized cards
    final maxCardWidth = 450.0; // Maximum width for the card
    final cardWidth = screenWidth > 600
        ? (screenWidth * 0.4)
            .clamp(300.0, maxCardWidth) // For web/large screens
        : screenWidth - 48; // For mobile screens (original logic)

    final cardHeight = cardWidth * 0.63; // Standard card aspect ratio

    return Container(
      margin: EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              "আপনার ডেবিট কার্ড",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(0.05), // Slight perspective tilt
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Card background with fallback gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.authorityBlue.withOpacity(0.9),
                            AppTheme.trustCyan,
                            Colors.cyan.shade300,
                          ],
                        ),
                      ),
                    ),
                    // Background pattern - REPLACED WITH CUSTOM PATTERN TO AVOID ASSET ISSUE
                    Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        size: Size(cardWidth, cardHeight),
                        painter: CardPatternPainter(),
                      ),
                    ),
                    // Card content
                    Padding(
                      padding: EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side - Chip
                              Container(
                                height: 40,
                                width: 55,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade300,
                                      Colors.amber.shade400,
                                      Colors.amber.shade500,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.credit_score,
                                    color: Colors.amber.shade800,
                                    size: 24,
                                  ),
                                ),
                              ),
                              // Right side - VISA logo
                              Container(
                                child: Text(
                                  'VISA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Spacer(),

                          // Account number instead of card number
                          Text(
                            provider.userBankNumber.isNotEmpty
                                ? _formatCardNumber(provider.userBankNumber)
                                : '**** **** **** ****',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // Bank name and validity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ব্যাংকের নাম',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    provider.userBankName.isNotEmpty
                                        ? provider.userBankName.toUpperCase()
                                        : 'ব্যাংকের নাম',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          offset: Offset(0.5, 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'মেয়াদ শেষ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    provider.validity.isNotEmpty
                                        ? provider.validity
                                        : 'মাস/বছর',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          offset: Offset(0.5, 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String number) {
    // Format the account number in groups of 4 digits
    if (number.length < 4) return number;

    // Split the account number into groups of 4
    final List<String> groups = [];
    for (int i = 0; i < number.length; i += 4) {
      int end = i + 4;
      if (end > number.length) end = number.length;
      groups.add(number.substring(i, end));
    }

    return groups.join(' ');
  }

  Widget _buildCardDetails(CardProvider provider) {
    return _buildDetailSection("অ্যাকাউন্টের তথ্য", [
      _buildDetailItem(
        "ব্যাংকের নাম",
        provider.userBankName,
        Icons.account_balance_outlined,
        AppTheme.authorityBlue,
      ),
      _buildDetailItem(
        "অ্যাকাউন্ট নম্বর",
        provider.userBankNumber,
        Icons.credit_card_outlined,
        AppTheme.trustCyan,
      ),
    ]);
  }

  Widget _buildBankInformation(CardProvider provider) {
    // Instead of checking for cardHolderName and cardNumber, check if there's any card information
    if (provider.cardNumber.isEmpty &&
        provider.cardHolderName.isEmpty &&
        provider.cvv.isEmpty &&
        provider.validity.isEmpty) {
      return SizedBox.shrink();
    }

    return _buildDetailSection("কার্ডের তথ্য", [
      if (provider.cardHolderName.isNotEmpty)
        _buildDetailItem(
          "কার্ডধারীর নাম",
          provider.cardHolderName,
          Icons.person_outline,
          Colors.indigo,
        ),
      if (provider.cardNumber.isNotEmpty)
        _buildDetailItem(
          "কার্ড নম্বর",
          provider.cardNumber,
          Icons.account_balance_wallet_outlined,
          Colors.teal,
        ),
      if (provider.validity.isNotEmpty)
        _buildDetailItem(
          "মেয়াদ শেষ",
          provider.validity,
          Icons.calendar_today_outlined,
          Colors.orange,
        ),
      if (provider.cvv.isNotEmpty)
        _buildDetailItem(
          "সিভিভি",
          provider.cvv,
          Icons.security_outlined,
          Colors.purple,
        ),
    ]);
  }

  Widget _buildCardServices() {
    return _buildDetailSection("কার্ড সেবাসমূহ", [
      _buildFeatureItem(
        "ব্যালেন্স চেক",
        "আপনার বর্তমান কার্ড ব্যালেন্স চেক করুন",
        Icons.account_balance_wallet_outlined,
        AppTheme.authorityBlue,
      ),
      _buildFeatureItem(
        "লেনদেনের ইতিহাস",
        "আপনার সাম্প্রতিক লেনদেন দেখুন",
        Icons.history,
        Colors.orange,
      ),
      _buildFeatureItem(
        "কার্ড লিমিট",
        "আপনার ব্যয় সীমা পরিচালনা করুন",
        Icons.tune,
        Colors.green,
      ),
      _buildFeatureItem(
        "কার্ড ব্লক",
        "অস্থায়ীভাবে আপনার কার্ড ব্লক করুন",
        Icons.block,
        Colors.red,
      ),
    ]);
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.neutral800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.neutral600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.neutral800,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      String title, String description, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle tap action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('শীঘ্রই আসছে: $title'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(16),
              ),
            );
          },
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.neutral800,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppTheme.neutral600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.neutral400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter to draw a pattern on the card background
// This replaces the need for the card_pattern.png asset
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw grid pattern
    final double spacing = 20;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      // Diagonal lines
      canvas.drawLine(
        Offset(0, i),
        Offset(i, 0),
        paint,
      );

      // Additional curved details
      if (i % (spacing * 3) == 0) {
        final rect = Rect.fromLTWH(
          i - size.width / 4,
          i - size.height / 4,
          size.width / 2,
          size.height / 2,
        );
        canvas.drawOval(rect, paint);
      }
    }

    // Add some circles for visual interest
    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * size.width / 10;
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(CardPatternPainter oldDelegate) => false;
}
