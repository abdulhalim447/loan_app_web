import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

import '../auth/saved_login/user_session.dart';
import 'package:world_bank_loan/core/api/api_endpoints.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    try {
      // Get token from shared preferences
      String? token = await UserSession.getToken();
      if (token == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "User token not found.";
            _isLoading = false;
          });
        }
        return;
      }

      // Make API call
      final response = await http.get(
        Uri.parse(ApiEndpoints.slides),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _imageUrls = (data['slides'] as List)
                .map((image) => image['url'] as String)
                .toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                "Failed to load images. Error: ${response.statusCode}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "An error occurred: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    if (_imageUrls.isEmpty) {
      return const Center(child: Text("No images available."));
    }

    return Column(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            aspectRatio: 16 / 9,
            enlargeFactor: 0.3,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              _selectedIndex.value = index;
            },
          ),
          itemCount: _imageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                width: double.maxFinite,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Image.network(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Image failed to load',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }
}
