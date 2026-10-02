import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../services/admob_service.dart';
import '../widgets/app_brand_image.dart';
import '../widgets/app_wallpaper.dart';
import 'onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Completer<void>? _whenResumed;

  Future<void> _waitUntilActive() async {
    while (mounted &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      _whenResumed ??= Completer<void>();
      await _whenResumed!.future;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _whenResumed?.complete();
      _whenResumed = null;
    }
  }

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..forward();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openNextPage();
  }

  Future<void> _openNextPage() async {
    final splashDelay = Future<void>.delayed(const Duration(seconds: 5));
    final preferences = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        preferences.getBool(OnboardingPage.completedKey) ?? false;

    // ATT can only present its system alert after the app has drawn a frame.
    // Finish the choice before starting AdMob or loading the first ad.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _waitUntilActive();
        if (!mounted) return;
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await _waitUntilActive();
          if (!mounted) return;
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } catch (error) {
        debugPrint('Tracking authorization request failed: $error');
      }
    }
    if (!mounted) return;
    unawaited(
      AdmobService().initialize().catchError((Object error) {
        debugPrint('Ad initialization failed: $error');
      }),
    );

    await splashDelay;
    if (!mounted) return;

    await AdmobService().showAppOpenAdAndWait();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder:
            (context) =>
                hasSeenOnboarding
                    ? const FootballMatchesPage()
                    : const OnboardingPage(),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _whenResumed?.complete();
    _whenResumed = null;
    _entrance.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Positioned.fill(child: AppWallpaper()),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _entrance,
                    curve: Curves.easeIn,
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1).animate(
                      CurvedAnimation(
                        parent: _entrance,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 116,
                          height: 116,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF002366,
                                ).withValues(alpha: 0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const AppBrandImage(
                            size: 116,
                            borderRadius: 30,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'LiveGoal AI',
                          style: TextStyle(
                            color: Color(0xFF002366),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your football companion',
                          style: TextStyle(
                            color: Color(0xFF53627B),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 44),
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (context, child) {
                            final percentage = (_progress.value * 100).round();
                            return SizedBox(
                              width: 240,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _progress.value,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFFFE6D9),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFFF4D00),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$percentage%',
                                    style: const TextStyle(
                                      color: Color(0xFFFF4D00),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
