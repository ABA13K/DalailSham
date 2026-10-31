import 'package:dali_alsham/l10n/generated/app_localizations.dart';

/// Formats a distance in meters into a localized, human readable string.
String formatDistance(AppLocalizations l10n, int meters) {
  if (meters < 1000) {
    return l10n.distanceMeters(meters);
  }
  final kilometers = (meters / 1000);
  final rounded = kilometers >= 10
      ? kilometers.roundToDouble()
      : (kilometers * 10).roundToDouble() / 10;
  return l10n.distanceKilometers(rounded);
}
