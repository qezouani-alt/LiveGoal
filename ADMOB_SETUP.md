# AdMob setup (iOS)

`ios/Runner/Info.plist` contains the iOS AdMob app ID. The iOS interstitial ad
unit and the separate iOS App Open ad unit are configured in
`lib/services/admob_service.dart`; see `ADMOB_PRODUCTION_IDS.md`.

The app initializes and requests ads only on iOS. It does not configure AdMob
for Android, web, or desktop. The interstitial is requested for tab changes and
the competition back button. If an ad is not ready, navigation continues.

Confirm the app ID and both ad units in the AdMob console. Their syntax and
matching publisher prefix alone cannot establish ownership or active status.
For development, follow Google's test-device guidance before interacting with
ads on a physical device.
