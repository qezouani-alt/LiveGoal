# iOS AdMob configuration

The runtime configuration uses only iOS ad IDs. The AdMob app ID in
`ios/Runner/Info.plist` ends with `~2279443232`. It identifies the app and is
not an ad unit.

The configured interstitial ad unit in `lib/services/admob_service.dart` ends
with `/4897867713`. Its publisher prefix matches the iOS app ID. Confirm this
unit belongs to your iOS app and is active in your AdMob account before release.

An iOS App Open ad unit is now configured in `_configuredAppOpenAdUnitId` in
`lib/services/admob_service.dart`. It ends with `/5479312485`, shares the
publisher prefix of the iOS app ID, and differs from the interstitial unit.
Confirm that it is an active App Open unit for this app in your AdMob account.

The service accepts only a ten-digit ad unit under the publisher prefix already
used by the iOS app. The splash still lasts five seconds; it shows an App Open
ad only when an ad has finished loading by then.

The previously listed IDs under a different publisher prefix were not present
in the runtime configuration and should not be treated as verified production
IDs for this app.
