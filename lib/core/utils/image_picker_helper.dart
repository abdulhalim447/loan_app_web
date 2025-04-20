import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source and returns the bytes and path.
  /// For web, only bytes are returned with a placeholder path.
  /// For mobile, both bytes and file path are returned.
  static Future<Map<String, dynamic>?> pickImage({
    required BuildContext context,
    ImageSource? source,
    int imageQuality = 70,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      // On web platform
      if (kIsWeb) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, // Only gallery works on web
          imageQuality: imageQuality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

        if (pickedFile == null) return null;

        // Read the file as bytes for web
        final bytes = await pickedFile.readAsBytes();
        return {
          'bytes': bytes,
          'path': 'image_selected',
          'name': pickedFile.name,
        };
      }

      // Show source selection dialog if source not provided
      if (source == null) {
        source = await _showSourceSelectionDialog(context);
        if (source == null) return null;
      }

      // For camera source, check for camera permission
      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.status;
        if (cameraPermission.isDenied) {
          final status = await Permission.camera.request();
          if (status.isDenied) {
            _showPermissionError(context, 'Camera');
            return null;
          }
        }
      }

      // For Android 13+ gallery, system photo picker is used without Storage permission
      // For Android < 13, we don't need to do anything special here as the image_picker handles it

      // Pick the image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile == null) return null;

      // Read file as bytes
      final bytes = await pickedFile.readAsBytes();

      // For mobile platforms, save the file to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      // Write file
      await file.writeAsBytes(bytes);

      return {
        'bytes': bytes,
        'path': filePath,
        'name': pickedFile.name,
      };
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Shows a dialog to select an image source
  static Future<ImageSource?> _showSourceSelectionDialog(
      BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context,
                    Icons.camera_alt,
                    'Camera',
                    () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _buildSourceOption(
                    context,
                    Icons.photo_library,
                    'Gallery',
                    () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an option for the source selection dialog
  static Widget _buildSourceOption(
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

  /// Shows a permission error dialog
  static void _showPermissionError(
      BuildContext context, String permissionType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permissionType permission is required'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () async {
            await openAppSettings();
          },
        ),
      ),
    );
  }
}
