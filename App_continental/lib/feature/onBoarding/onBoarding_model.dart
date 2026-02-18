
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


@immutable
class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPageModel({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}


final onboardingPagesProvider = Provider<List<OnboardingPageModel>>((ref) {
  return [
     const OnboardingPageModel(
      imagePath: 'assets/images/onboarding_image.png', 
      title: 'Centralized Property Management',
      description:
          'Easily keep all your property details organized in one place. Edit descriptions, amenities, and availability in just a few clicks.',
    ),
    const OnboardingPageModel(
      imagePath: 'assets/images/onboarding_image2.png', 
      title: 'Simplified Tenant Management',
      description:
          'Stay on top of tenant details and communication effortlessly. Access lease information, manage records, and connect seamlessly.',
    ),
   
  ];
});


final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);


