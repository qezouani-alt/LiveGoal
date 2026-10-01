import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../widgets/app_brand_image.dart';
import '../widgets/app_wallpaper.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onFinished});

  /// Allows the completed flow to be embedded without changing its saved state.
  final VoidCallback? onFinished;

  static const completedKey = 'onboarding_completed';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _isFinishing = false;

  static const _navy = Color(0xFF002366);
  static const _orange = Color(0xFFFF4D00);
  static const _pages = [
    _OnboardingContent(
      eyebrow: 'THE MATCHDAY HUB',
      title: 'Every match,\nall in one place.',
      description:
          'Browse today’s fixtures, follow live scores, and open a match for the details that matter.',
      icon: Icons.sports_soccer,
      color: _navy,
      useBrandImage: true,
      highlights: ['Live scores', 'Fixtures', 'Match details'],
    ),
    _OnboardingContent(
      eyebrow: 'YOUR FOOTBALL, YOUR WAY',
      title: 'Keep your favorites close.',
      description:
          'Save the competitions you follow and catch up on football news in a few taps.',
      icon: Icons.star_rounded,
      color: _orange,
      highlights: ['Favorite leagues', 'Football news'],
    ),
    _OnboardingContent(
      eyebrow: 'MORE THAN SCORES',
      title: 'Explore. Guess. Play.',
      description:
          'Ask the football AI assistant and try quizzes about players, clubs, stadiums, and more.',
      icon: Icons.auto_awesome_rounded,
      color: _navy,
      highlights: ['AI assistant', 'Football quizzes'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(OnboardingPage.completedKey, true);
      if (!mounted) return;

      if (widget.onFinished != null) {
        widget.onFinished!();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const FootballMatchesPage(),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  void _continue() {
    if (_pageIndex == _pages.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Positioned.fill(child: AppWallpaper()),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        const AppBrandImage(size: 30),
                        const SizedBox(width: 9),
                        const Text(
                          'LiveGoal AI',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (!isLastPage)
                          TextButton(
                            onPressed: _isFinishing ? null : _finish,
                            child: const Text('Skip'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged:
                          (index) => setState(() => _pageIndex = index),
                      itemBuilder:
                          (context, index) =>
                              _OnboardingSlide(content: _pages[index]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_pageIndex + 1} of ${_pages.length}',
                            style: const TextStyle(
                              color: _navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: index == _pageIndex ? 28 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      index == _pageIndex
                                          ? _orange
                                          : _navy.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              onPressed: _isFinishing ? null : _continue,
                              style: FilledButton.styleFrom(
                                backgroundColor: _navy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                isLastPage ? 'Get started' : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.highlights,
    this.useBrandImage = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> highlights;
  final bool useBrandImage;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: content.color.withValues(alpha: 0.10),
                            border: Border.all(
                              color: content.color.withValues(alpha: 0.16),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: content.color,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: content.color.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child:
                                  content.useBrandImage
                                      ? const AppBrandImage(
                                        size: 112,
                                        borderRadius: 30,
                                      )
                                      : Icon(
                                        content.icon,
                                        color: Colors.white,
                                        size: 58,
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          content.eyebrow,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFF4D00),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          content.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF002366),
                            fontSize: 34,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          content.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF53627B),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              content.highlights
                                  .map(
                                    (label) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: content.color.withValues(
                                            alpha: 0.18,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Color(0xFF002366),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
