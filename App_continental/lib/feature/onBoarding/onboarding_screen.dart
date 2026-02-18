import 'package:continental/feature/onBoarding/onBoarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../storage/token_storage.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(onboardingPagesProvider);
    final currentPageIndex = ref.watch(onboardingPageIndexProvider);
    final isLastPage = currentPageIndex == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  ref.read(onboardingPageIndexProvider.notifier).state = index;
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(page: pages[index]);
                },
              ),
            ),
            _buildBottomControls(isLastPage, pages.length),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool isLastPage, int pageCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (isLastPage) {
              // Mark onboarding as completed
              await _tokenStorage.markOnboardingCompleted();
              if (mounted) {
                context.goNamed('login');
              }
            } else {
              // Go to the next page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            isLastPage ? 'Get Started' : 'Next',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


class _OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;
  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 10),
          Center(child: Image.asset(page.imagePath, height: MediaQuery.of(context).size.height * 0.35)),
          const Spacer(flex: 2),
          Text(
            page.title,
            textAlign: TextAlign.start,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.start,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}