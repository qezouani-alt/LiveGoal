import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdmobService {
  static final AdmobService _instance = AdmobService._internal();
  factory AdmobService() => _instance;
  AdmobService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isShowingInterstitial = false;
  VoidCallback? _onInterstitialClosed;
  int _tabSwitchCount = 0;
  static const int _showAdAfterSwitches = 1; // Show ad every tab switch

  // App Open Ad
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdReady = false;
  DateTime? _appOpenAdLoadTime;
  static const Duration _maxAppOpenAdAge = Duration(hours: 4);
  bool _isShowingAppOpenAd = false;
  VoidCallback? _onAppOpenAdClosed;

  // Configured iOS interstitial ad unit. Verify ownership in AdMob.
  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-2535194044471316/4897867713'; // iOS Interstitial Ad
    } else {
      throw UnsupportedError('Only iOS is supported');
    }
  }

  // iOS App Open ad unit. The app ID in Info.plist is not an ad unit.
  static const String _configuredAppOpenAdUnitId =
      'ca-app-pub-2535194044471316/5479312485';

  static String? get appOpenAdUnitId {
    if (kIsWeb || !Platform.isIOS) return null;
    if (RegExp(
          r'^ca-app-pub-2535194044471316/[0-9]{10}$',
        ).hasMatch(_configuredAppOpenAdUnitId) &&
        _configuredAppOpenAdUnitId != interstitialAdUnitId) {
      return _configuredAppOpenAdUnitId;
    }
    return null;
  }

  // Initialize AdMob
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isIOS) return;

    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadAppOpenAd();
  }

  // Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          // Set full screen content callback
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('💰 Interstitial ad showed');
              _isShowingInterstitial = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('💰 Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _isShowingInterstitial = false;
              _loadInterstitialAd(); // Load next ad
              _completeInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _isShowingInterstitial = false;
              _loadInterstitialAd(); // Load next ad
              _completeInterstitialAd();
            },
          );

          debugPrint('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          // Retry loading after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Show Interstitial Ad on tab switch
  void onTabSwitch() {
    _tabSwitchCount++;

    if (_tabSwitchCount >= _showAdAfterSwitches) {
      _tabSwitchCount = 0; // Reset counter
      showInterstitialAd();
    }
  }

  Future<void> showInterstitialAdAndWait() async {
    final completion = Completer<void>();
    if (showInterstitialAd(onComplete: completion.complete)) {
      await completion.future;
    }
  }

  void _completeInterstitialAd() {
    final onClosed = _onInterstitialClosed;
    _onInterstitialClosed = null;
    onClosed?.call();
  }

  // Show Interstitial Ad
  bool showInterstitialAd({VoidCallback? onComplete}) {
    if (_isShowingInterstitial || _isShowingAppOpenAd) return false;

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _onInterstitialClosed = onComplete;
      _isShowingInterstitial = true;
      _isInterstitialAdReady = false;
      _interstitialAd!.show();
      return true;
    }

    debugPrint('Interstitial ad not ready yet');
    return false;
  }

  // Load App Open Ad
  void _loadAppOpenAd() {
    final adUnitId = appOpenAdUnitId;
    if (adUnitId == null) return;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
          _appOpenAdLoadTime = DateTime.now();

          // Set full screen content callback
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('🎬 App open ad showed successfully!');
              _isShowingAppOpenAd = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('🎬 App open ad dismissed');
              ad.dispose();
              _isAppOpenAdReady = false;
              _appOpenAd = null;
              _isShowingAppOpenAd = false;
              _loadAppOpenAd(); // Load next ad
              _completeAppOpenAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('🎬 App open ad failed to show: $error');
              ad.dispose();
              _isAppOpenAdReady = false;
              _appOpenAd = null;
              _isShowingAppOpenAd = false;
              _loadAppOpenAd(); // Load next ad
              _completeAppOpenAd();
            },
          );

          debugPrint('App open ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: $error');
          _isAppOpenAdReady = false;
          // Retry loading after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadAppOpenAd();
          });
        },
      ),
    );
  }

  // Check if app open ad is available and not expired
  bool _isAppOpenAdAvailable() {
    if (!_isAppOpenAdReady || _appOpenAd == null) {
      return false;
    }

    // Check if ad is expired (older than 4 hours)
    if (_appOpenAdLoadTime != null) {
      final now = DateTime.now();
      final age = now.difference(_appOpenAdLoadTime!);
      if (age > _maxAppOpenAdAge) {
        debugPrint('App open ad expired, loading new one');
        _appOpenAd?.dispose();
        _appOpenAd = null;
        _isAppOpenAdReady = false;
        _loadAppOpenAd();
        return false;
      }
    }

    return true;
  }

  // Show App Open Ad (called when app opens or resumes)
  Future<void> showAppOpenAdAndWait() async {
    final completion = Completer<void>();
    if (showAppOpenAd(onComplete: completion.complete)) {
      await completion.future;
    }
  }

  void _completeAppOpenAd() {
    final onClosed = _onAppOpenAdClosed;
    _onAppOpenAdClosed = null;
    onClosed?.call();
  }

  bool showAppOpenAd({VoidCallback? onComplete}) {
    if (appOpenAdUnitId == null) return false;

    // Don't show if already showing an app open ad
    if (_isShowingAppOpenAd) {
      debugPrint('🎬 Already showing an app open ad, skipping');
      return false;
    }

    // Don't show if an interstitial is currently showing
    if (_isShowingInterstitial) {
      debugPrint('🎬 Interstitial is showing, skipping app open ad');
      return false;
    }

    debugPrint('🎬 Attempting to show app open ad...');
    debugPrint('🎬 Ad ready: $_isAppOpenAdReady');
    debugPrint('🎬 Ad object: ${_appOpenAd != null}');

    if (_isAppOpenAdAvailable()) {
      debugPrint('🎬 App open ad is available, showing now!');
      _onAppOpenAdClosed = onComplete;
      _appOpenAd!.show();
      _isAppOpenAdReady = false;
      return true;
    } else {
      debugPrint('🎬 App open ad not ready yet');
      if (_appOpenAdLoadTime != null) {
        final age = DateTime.now().difference(_appOpenAdLoadTime!);
        debugPrint(
          '🎬 Ad age: ${age.inSeconds} seconds (max: ${_maxAppOpenAdAge.inHours} hours)',
        );
      } else {
        debugPrint('🎬 Ad has never been loaded yet');
      }
      return false;
    }
  }

  // Check if interstitial is currently showing (for external use)
  bool isShowingInterstitial() => _isShowingInterstitial;

  // Dispose ads
  void dispose() {
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
  }
}
