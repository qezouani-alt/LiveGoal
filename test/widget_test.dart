import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foot/pages/onboarding_page.dart';
import 'package:foot/pages/splash_screen.dart';
import 'package:foot/main.dart';
import 'package:foot/pages/competition_matches_page.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
  testWidgets('requests ATT on iOS before leaving the splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const channel = MethodChannel('app_tracking_transparency');
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return call.method == 'getTrackingAuthorizationStatus' ? 0 : 3;
    });
    try {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pump();

      expect(calls, [
        'getTrackingAuthorizationStatus',
        'requestTrackingAuthorization',
      ]);
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    } finally {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('ATT waits for the app to become active', (tester) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const channel = MethodChannel('app_tracking_transparency');
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return call.method == 'getTrackingAuthorizationStatus' ? 0 : 2;
    });
    try {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      await tester.pump();
      expect(calls, isEmpty);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(calls, [
        'getTrackingAuthorizationStatus',
        'requestTrackingAuthorization',
      ]);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    } finally {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
      debugDefaultTargetPlatformOverride = null;
    }
  });

  for (final status in [1, 2, 3]) {
    testWidgets('ATT does not request again for existing status $status', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const channel = MethodChannel('app_tracking_transparency');
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call.method);
        return status;
      });
      try {
        await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
        await tester.pump();
        expect(calls, ['getTrackingAuthorizationStatus']);
        await tester.pump(const Duration(seconds: 5));
        await tester.pump();
        expect(find.byType(OnboardingPage), findsOneWidget);
      } finally {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('first launch opens onboarding after the splash', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('LiveGoal AI'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2500));
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, closeTo(0.5, 0.02));
    expect(find.text('50%'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Every match,\nall in one place.'), findsOneWidget);
  });

  testWidgets('finishing onboarding is saved for later launches', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(home: OnboardingPage(onFinished: () => finished = true)),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Keep your favorites close.'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Explore. Guess. Play.'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pump();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(OnboardingPage.completedKey), isTrue);
    expect(finished, isTrue);
  });

  testWidgets('competition back button returns when no ad is loaded', (
    tester,
  ) async {
    final competition = CompetitionWithMatches(
      id: 1,
      name: 'Test League',
      country: 'Test Country',
      logo: '',
      flag: '',
      matches: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (context) => CompetitionMatchesPage(
                                competition: competition,
                              ),
                        ),
                      ),
                  child: const Text('Open competition'),
                ),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Open competition'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CompetitionMatchesPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CompetitionMatchesPage), findsNothing);
  });
}
