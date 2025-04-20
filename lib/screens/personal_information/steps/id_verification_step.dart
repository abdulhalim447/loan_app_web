import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:world_bank_loan/providers/personal_info_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
// Use dart:convert for base64Encode
// Add math import
// Add dart:typed_data for Uint8List
import 'package:world_bank_loan/core/utils/image_picker_helper.dart'; // Import the helper

// Simple class for custom drawing canvas
class HandSignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;
  final double strokeWidth;

  HandSignaturePainter(this.points, this.strokeColor, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(HandSignaturePainter oldDelegate) => true;
}

// Widget for custom drawing canvas
class HandSignatureView extends StatefulWidget {
  final GlobalKey<HandSignatureViewState> signatureKey;
  final Color strokeColor;
  final Color backgroundColor;
  final double strokeWidth;

  const HandSignatureView({
    required this.signatureKey,
    this.strokeColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.strokeWidth = 3.0,
  }) : super(key: signatureKey);

  @override
  HandSignatureViewState createState() => HandSignatureViewState();
}

class HandSignatureViewState extends State<HandSignatureView> {
  final List<Offset?> _points = [];
  late Size _boxSize;
  late Rect _drawingRect;

  bool get isEmpty => _points.isEmpty;

  void clear() {
    setState(() {
      _points.clear();
    });
  }

  Future<ui.Image> toImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(300, 200);

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = widget.backgroundColor,
    );

    // Draw signature
    final paint = Paint()
      ..color = widget.strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = widget.strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      } else if (_points[i] != null && _points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [_points[i]!], paint);
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  // Constrains an offset to be within the drawing rectangle
  Offset _constrainOffset(Offset offset) {
    double x = offset.dx.clamp(_drawingRect.left, _drawingRect.right);
    double y = offset.dy.clamp(_drawingRect.top, _drawingRect.bottom);
    return Offset(x, y);
  }

  // Check if an offset is within the drawing area
  bool _isWithinBounds(Offset offset) {
    return _drawingRect.contains(offset);
  }

  // Handle a drawing start event
  void _handleDrawingStart(Offset localPosition) {
    if (_isWithinBounds(localPosition)) {
      setState(() {
        _points.add(_constrainOffset(localPosition));
      });
    }
  }

  // Handle a drawing update event
  void _handleDrawingUpdate(Offset localPosition) {
    setState(() {
      _points.add(_constrainOffset(localPosition));
    });
  }

  // Handle a drawing end event
  void _handleDrawingEnd() {
    setState(() {
      _points.add(null); // Add null to break the line
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _boxSize = Size(constraints.maxWidth, constraints.maxHeight);
        // Define the drawing area
        _drawingRect = Rect.fromLTRB(0, 0, _boxSize.width, _boxSize.height);

        return ClipRect(
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                _handleDrawingStart(details.localPosition);
                // Prevents scrolling
                details.sourceTimeStamp;
              },
              onPanUpdate: (details) {
                _handleDrawingUpdate(details.localPosition);
                // Prevents scrolling
                details.sourceTimeStamp;
              },
              onPanEnd: (details) {
                _handleDrawingEnd();
              },
              child: CustomPaint(
                painter: HandSignaturePainter(
                    _points, widget.strokeColor, widget.strokeWidth),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}

class IdVerificationStepScreen extends StatefulWidget {
  const IdVerificationStepScreen({super.key});

  @override
  _IdVerificationStepScreenState createState() =>
      _IdVerificationStepScreenState();
}

class _IdVerificationStepScreenState extends State<IdVerificationStepScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final GlobalKey<HandSignatureViewState> _webSignatureKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nidNameController = TextEditingController();
  final TextEditingController _nidNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? validateNidName(String? value) {
    if (value == null || value.isEmpty) {
      return 'আইডি অনুযায়ী নাম প্রয়োজন';
    }
    if (value.length < 3) {
      return 'নাম কমপক্ষে ৩ অক্ষরের হতে হবে';
    }
    return null;
  }

  String? validateNidNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'আইডি নম্বর প্রয়োজন';
    }
    if (value.length < 5) {
      return 'অনুগ্রহ করে একটি বৈধ আইডি নম্বর দিন';
    }
    return null;
  }

  bool validateImages(BuildContext context, PersonalInfoProvider provider) {
    bool isValid = true;
    if (provider.frontIdImagePath == null ||
        provider.frontIdImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('অনুগ্রহ করে আপনার এনআইডির সামনের দিক আপলোড করুন'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (provider.backIdImagePath == null || provider.backIdImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('অনুগ্রহ করে আপনার এনআইডির পিছনের দিক আপলোড করুন'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (provider.selfieWithIdImagePath == null ||
        provider.selfieWithIdImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('অনুগ্রহ করে আপনার আইডি সহ একটি সেলফি তুলুন'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    return isValid;
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider =
          Provider.of<PersonalInfoProvider>(context, listen: false);
      _nidNameController.text = provider.nidNameController.text;
      _nidNumberController.text = provider.idController.text;

      // Ensure we have the right image data for web platform
      if (kIsWeb) {
        debugPrint("Web platform detected, ensuring image data is available");
        // Log images status
        debugPrint(
            "Front ID: ${provider.frontIdImagePath != null ? 'Path available' : 'No path'}, ${provider.frontIdImageBytes != null ? 'Bytes available' : 'No bytes'}");
        debugPrint(
            "Back ID: ${provider.backIdImagePath != null ? 'Path available' : 'No path'}, ${provider.backIdImageBytes != null ? 'Bytes available' : 'No bytes'}");
        debugPrint(
            "Selfie: ${provider.selfieWithIdImagePath != null ? 'Path available' : 'No path'}, ${provider.selfieWithIdImageBytes != null ? 'Bytes available' : 'No bytes'}");
        debugPrint(
            "Signature: ${provider.signatureImagePath != null ? 'Path available' : 'No path'}, ${provider.signatureImageBytes != null ? 'Bytes available' : 'No bytes'}");

        setState(() {}); // Ensure UI reflects current state
      }
    });
  }

  @override
  void dispose() {
    _nidNameController.dispose();
    _nidNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalInfoProvider>(
      builder: (context, provider, _) {
        bool isVerified = provider.isVerified;
        // Determine if this is being viewed standalone or as part of multi-step form
        bool isStandalone = ModalRoute.of(context)
                ?.settings
                .name
                ?.contains('/id_verification') ??
            false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              _buildTextField(
                context,
                'নাম (আইডি অনুযায়ী)',
                provider.nidNameController,
                prefixIcon: Icons.badge_outlined,
                validator: validateNidName,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 16),
              _buildTextField(
                context,
                'আইডি নম্বর',
                provider.idController,
                prefixIcon: Icons.credit_card_outlined,
                validator: validateNidNumber,
                isReadOnly: isVerified,
              ),
              SizedBox(height: 24),

              // Front ID image
              _buildImageSection(
                context,
                'আইডির সামনের দিক',
                'আপনার আইডি কার্ডের সামনের দিকের একটি পরিষ্কার ছবি আপলোড করুন',
                provider.frontIdImagePath,
                imageUrl: provider.frontIdImageUrl,
                onUpload: isVerified
                    ? null
                    : () async {
                        final path = await _pickImage(context, 'front');
                        if (path != null) {
                          provider.saveImagePath('front', path);
                        }
                      },
              ),
              SizedBox(height: 16),

              // Back ID image
              _buildImageSection(
                context,
                'আইডির পিছনের দিক',
                'আপনার আইডি কার্ডের পিছনের দিকের একটি পরিষ্কার ছবি আপলোড করুন',
                provider.backIdImagePath,
                imageUrl: provider.backIdImageUrl,
                onUpload: isVerified
                    ? null
                    : () async {
                        final path = await _pickImage(context, 'back');
                        if (path != null) {
                          provider.saveImagePath('back', path);
                        }
                      },
              ),
              SizedBox(height: 16),

              // Selfie with ID
              _buildImageSection(
                context,
                'আইডি সহ সেলফি',
                'আপনার আইডি কার্ড ধরে একটি সেলফি তুলুন',
                provider.selfieWithIdImagePath,
                imageUrl: provider.selfieWithIdImageUrl,
                onUpload: isVerified
                    ? null
                    : () async {
                        final path = await _pickImage(context, 'selfie');
                        if (path != null) {
                          provider.saveImagePath('selfie', path);
                        }
                      },
              ),
              SizedBox(height: 16),

              // Signature section - different implementations for web vs mobile
              _buildSignatureSection(context, provider),

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
          colors: [Colors.cyan.shade700, Colors.cyan.shade400],
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
                Icons.verified_user_outlined,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'আইডি যাচাইকরণ',
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
            'আমাদের আপনার ঋণের আবেদন প্রক্রিয়া করতে আপনার পরিচয় যাচাই করতে হবে। অনুগ্রহ করে আপনার আইডি কার্ডের পরিষ্কার ছবি প্রদান করুন।',
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
    String? Function(String?)? validator,
    bool isReadOnly = false,
  }) {
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

  Widget _buildImageSection(
    BuildContext context,
    String title,
    String description,
    String? imagePath, {
    String? imageUrl,
    VoidCallback? onUpload,
  }) {
    final hasImage = imagePath != null || imageUrl != null;
    final isReadOnly = onUpload == null;
    final imageType = title.contains("সামনের")
        ? "front"
        : title.contains("পিছনের")
            ? "back"
            : title.contains("সেলফি")
                ? "selfie"
                : "signature";

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: hasImage ? Colors.cyan : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera_outlined,
                color: hasImage ? Colors.cyan : Colors.grey.shade600,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isReadOnly) ...[
                SizedBox(width: 8),
                Icon(Icons.lock, size: 16, color: Colors.grey),
              ],
              // Add change/replace button when an image is already selected
              if (hasImage && !isReadOnly) ...[
                Spacer(),
                TextButton.icon(
                  onPressed: onUpload,
                  icon: Icon(Icons.change_circle_outlined, size: 18),
                  label: Text(
                    'পরিবর্তন করুন',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          if (hasImage)
            _buildImagePreview(
              context,
              imagePath,
              imageUrl: imageUrl,
              imageType: imageType,
              onRemove: isReadOnly
                  ? null
                  : () {
                      final provider = Provider.of<PersonalInfoProvider>(
                          context,
                          listen: false);
                      if (imageType == 'front') {
                        provider.saveImagePath('front', '');
                        provider.frontIdImageBytes = null;
                      } else if (imageType == 'back') {
                        provider.saveImagePath('back', '');
                        provider.backIdImageBytes = null;
                      } else if (imageType == 'selfie') {
                        provider.saveImagePath('selfie', '');
                        provider.selfieWithIdImageBytes = null;
                      }
                      setState(() {}); // Refresh the UI
                    },
              onTap: isReadOnly
                  ? null
                  : onUpload, // Allow tapping on the image to replace it
            )
          else
            _buildImageUploader(context, onUpload),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    String? imagePath, {
    String? imageUrl,
    String imageType = "unknown",
    VoidCallback? onRemove,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // Handle taps to replace the image
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: _buildImage(imagePath, imageUrl, imageType),
            ),
            if (onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: onRemove,
                    tooltip: 'Remove Image',
                  ),
                ),
              ),
            if (onTap != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Tap to change',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath, String? imageUrl, String imageType) {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    // 1. First check for API provided image URLs
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.red),
              SizedBox(height: 8),
              Text(
                'ছবি লোড করতে ব্যর্থ হয়েছে',
                style: TextStyle(color: Colors.red),
              ),
            ],
          );
        },
      );
    }
    // 2. For web platform, check binary data first
    else if (kIsWeb) {
      if (imagePath == null) {
        return _buildNoImagePlaceholder();
      }

      // For web, use the imageType parameter to determine which bytes to show
      Uint8List? imageBytes;
      switch (imageType) {
        case "front":
          imageBytes = provider.frontIdImageBytes;
          break;
        case "back":
          imageBytes = provider.backIdImageBytes;
          break;
        case "selfie":
          imageBytes = provider.selfieWithIdImageBytes;
          break;
        case "signature":
          imageBytes = provider.signatureImageBytes;
          break;
      }

      // Display image from bytes if available
      if (imageBytes != null) {
        debugPrint(
            'Displaying image for type: $imageType with ${imageBytes.length} bytes');
        return Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error displaying image from bytes: $error');
            return _buildImageErrorWidget();
          },
        );
      }

      // Fallback for web if URL-like path is provided
      if (imagePath.startsWith('blob:') || imagePath.startsWith('data:')) {
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading web image URL: $error');
            return _buildImageErrorWidget();
          },
        );
      }

      // No valid image source found for web
      return _buildInvalidImageWidget();
    }
    // 3. For mobile/desktop platforms, handle file paths
    else if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (!file.existsSync()) {
          debugPrint('Image file does not exist: $imagePath');
          return _buildInvalidImageWidget();
        }

        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading file image: $error');
            return _buildImageErrorWidget();
          },
        );
      } catch (e) {
        debugPrint('Error processing image file: $e');
        return _buildInvalidImageWidget();
      }
    }
    // 4. No image available
    else {
      return _buildNoImagePlaceholder();
    }
  }

  // Helper widgets for image display
  Widget _buildNoImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'কোন ছবি নেই',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildImageErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 40, color: Colors.red),
        SizedBox(height: 8),
        Text(
          'ছবি লোড করতে ব্যর্থ হয়েছে',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildInvalidImageWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 40, color: Colors.red),
        SizedBox(height: 8),
        Text(
          'অবৈধ ছবি ফাইল',
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(
      BuildContext context, PersonalInfoProvider provider,
      {bool isReadOnly = false}) {
    final hasSignature =
        provider.hasSignature || provider.signatureImageUrl != null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: hasSignature ? Colors.cyan : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.draw_outlined,
                color: hasSignature ? Colors.cyan : Colors.grey.shade600,
              ),
              SizedBox(width: 8),
              Text(
                'স্বাক্ষর',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isReadOnly) ...[
                SizedBox(width: 8),
                Icon(Icons.lock, size: 16, color: Colors.grey),
              ],
              // Add change option for signature
              if (hasSignature && !isReadOnly) ...[
                Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Clear existing signature and show the uploader
                    provider.clearSignature();
                    setState(() {});
                  },
                  icon: Icon(Icons.change_circle_outlined, size: 18),
                  label: Text(
                    'পরিবর্তন করুন',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Text(
            'স্বাক্ষর আঁকুন বা গ্যালারি থেকে আপলোড করুন',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          if (hasSignature)
            _buildImagePreview(
              context,
              provider.signatureImagePath,
              imageUrl: provider.signatureImageUrl,
              imageType: "signature",
              onRemove: isReadOnly
                  ? null
                  : () {
                      provider.clearSignature();
                      setState(() {}); // Refresh UI
                    },
              onTap: isReadOnly
                  ? null
                  : () {
                      // Clear existing signature and show the uploader
                      provider.clearSignature();
                      setState(() {});
                    },
            )
          else if (!isReadOnly)
            _buildSignatureUploader(context),
        ],
      ),
    );
  }

  Widget _buildImageUploader(
    BuildContext context,
    VoidCallback? onUpload,
  ) {
    if (onUpload == null) {
      return SizedBox(); // Return empty container if read-only
    }

    return InkWell(
      onTap: () async {
        if (onUpload != null) {
          onUpload();
          // Ensure we refresh the UI after upload
          setState(() {});
        }
      },
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'আপলোড করতে ট্যাপ করুন',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureUploader(BuildContext context) {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    // For web, provide a drawing canvas using our custom implementation
    if (kIsWeb) {
      return Column(
        children: [
          // Web-friendly drawing canvas
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "এখানে আপনার স্বাক্ষর আঁকুন",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Expanded(
                  // Add NotificationListener to prevent parent scrolling
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (_) => true, // Block scroll notifications
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      // Prevent scrolling with listener
                      child: IgnorePointer(
                        ignoring: false, // Don't ignore drawing
                        child: Listener(
                          onPointerDown: (event) {
                            // Prevent default browser behavior
                            event.position; // Access to prevent optimization
                          },
                          onPointerMove: (event) {
                            // Prevent default browser behavior
                            event.position; // Access to prevent optimization
                            // Cancel any ongoing scroll activities
                            if (kIsWeb) {
                              // This helps prevent scrolling while drawing
                              event.original?.down;
                            }
                          },
                          child: HandSignatureView(
                            signatureKey: _webSignatureKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            strokeWidth: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveWebSignature(context),
                  icon: Icon(Icons.save),
                  label: Text('স্বাক্ষর সংরক্ষণ করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _webSignatureKey.currentState?.clear();
                  },
                  icon: Icon(Icons.clear),
                  label: Text('পরিষ্কার করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          // Modified text instruction to make it clearer
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.amber.shade800, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'স্বাক্ষর বক্সের ভিতরে আঁকুন, বাইরে যাবে না',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            '- অথবা -',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          // Upload signature option
          InkWell(
            onTap: () async {
              final path = await _pickImage(context, 'signature');
              if (path != null) {
                // For web, path will be a placeholder and bytes will be stored in provider
                setState(() {}); // Trigger rebuild to show the image
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'গ্যালারি থেকে আপলোড করুন',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Original signature pad implementation for non-web platforms
    return Column(
      children: [
        // Draw signature option
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "এখানে আপনার স্বাক্ষর আঁকুন",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Expanded(
                child: SfSignaturePad(
                  key: _signaturePadKey,
                  backgroundColor: Colors.white,
                  strokeColor: Colors.black,
                  minimumStrokeWidth: 1.0,
                  maximumStrokeWidth: 4.0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Add mandatory save note
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade700, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'অবশ্যই স্বাক্ষর সংরক্ষণ করুন!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveSignature(context),
                icon: Icon(Icons.save),
                label: Text('স্বাক্ষর সংরক্ষণ করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _signaturePadKey.currentState?.clear();
                },
                icon: Icon(Icons.clear),
                label: Text('পরিষ্কার করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        // Upload signature option
        InkWell(
          onTap: () async {
            final path = await _pickImage(context, 'signature');
            if (path != null) {
              provider.saveImagePath('signature', path);
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'গ্যালারি থেকে আপলোড করুন',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSignature(BuildContext context) async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    try {
      // Get signature data as image
      final signatureData = await _signaturePadKey.currentState?.toImage();

      if (signatureData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('অনুগ্রহ করে প্রথমে আপনার স্বাক্ষর আঁকুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Convert to byte data
      final byteData =
          await signatureData.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert signature to bytes');
      }

      // Create file path
      final tempDir = await getTemporaryDirectory();
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      // Save signature to file
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (await file.exists()) {
        // Clean up old file if it exists
        final oldPath = provider.signatureImagePath;
        if (oldPath != null && oldPath.isNotEmpty) {
          try {
            final oldFile = File(oldPath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } catch (e) {
            debugPrint('Error cleaning up old signature file: $e');
          }
        }

        // Save new signature path
        provider.saveImagePath('signature', filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('স্বাক্ষর সফলভাবে সংরক্ষিত হয়েছে'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving signature: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('স্বাক্ষর সংরক্ষণ করতে ব্যর্থ হয়েছে: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.cyan.shade800,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Method to save web signature
  Future<void> _saveWebSignature(BuildContext context) async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    try {
      // Check if signature is empty
      if (_webSignatureKey.currentState?.isEmpty ?? true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('অনুগ্রহ করে প্রথমে আপনার স্বাক্ষর আঁকুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get signature as image
      final signatureImage = await _webSignatureKey.currentState?.toImage();
      if (signatureImage == null) {
        throw Exception('Failed to capture signature');
      }

      // Convert to PNG byte data
      final byteData =
          await signatureImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert signature to bytes');
      }

      // Convert to bytes list for direct storage
      final bytes = byteData.buffer.asUint8List();

      debugPrint('Saving signature with ${bytes.length} bytes');

      // Save the raw image bytes for direct upload - ONLY FOR SIGNATURE
      provider.saveImageBytes('signature', bytes);

      // Make sure the UI gets refreshed to show the signature
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('স্বাক্ষর সফলভাবে সংরক্ষিত হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error saving web signature: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('স্বাক্ষর সংরক্ষণ করতে ব্যর্থ হয়েছে: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _pickImage(BuildContext context, String type) async {
    final provider = Provider.of<PersonalInfoProvider>(context, listen: false);

    if (!mounted) return null;

    try {
      // Use our new helper to pick an image
      final result = await ImagePickerHelper.pickImage(
        context: context,
        imageQuality: kIsWeb ? 70 : 50,
        maxWidth: 1280,
        maxHeight: 720,
      );

      // If no image was picked
      if (result == null || !mounted) return null;

      // Save the image path and bytes
      final String path = result['path'];
      final Uint8List bytes = result['bytes'];

      debugPrint("Image selected for type: $type with ${bytes.length} bytes");

      // Save bytes for direct upload (important for web)
      provider.saveImageBytes(type, bytes);

      // For web, we just use the placeholder path
      if (kIsWeb) {
        debugPrint("Selected image type: $type with placeholder path");

        // Ensure the UI is refreshed to show the new image
        setState(() {});

        return path; // Will be 'image_selected'
      }

      // For mobile, we also save the file path
      provider.saveImagePath(type, path);

      // Clean up old file if exists
      final oldPath = type == 'front'
          ? provider.frontIdImagePath
          : type == 'back'
              ? provider.backIdImagePath
              : type == 'selfie'
                  ? provider.selfieWithIdImagePath
                  : provider.signatureImagePath;

      if (oldPath != null &&
          oldPath.isNotEmpty &&
          oldPath != 'image_selected' &&
          oldPath != path) {
        try {
          final oldFile = File(oldPath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          debugPrint('Error cleaning up old file: $e');
        }
      }

      debugPrint("Selected image type: $type with path: $path");
      return path;
    } catch (e) {
      if (!mounted) return null;
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'ছবি নির্বাচন করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // Helper method to determine MIME type from filename
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png'; // Default to PNG
    }
  }
}
