import '../../domain/entities/place.dart';

enum OpeningStatus { open, closed, open24 }

/// What the listing's own opening hours say about a place right now.
class CompanyProfile {
  const CompanyProfile(this.place);

  final Place place;

  /// Handles `24/7` and a single `HH:MM–HH:MM` range (including overnight
  /// closing); anything more complex than that is treated as unknown.
  OpeningStatus? get openingStatus {
    final hours = place.openingHours?.trim();
    if (hours == null || hours.isEmpty) return null;
    if (hours.replaceAll(' ', '').contains('24/7')) {
      return OpeningStatus.open24;
    }

    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*[–-]\s*(\d{1,2}):(\d{2})',
    ).firstMatch(hours);
    if (match == null) return null;

    final opens = int.parse(match[1]!) * 60 + int.parse(match[2]!);
    final closes = int.parse(match[3]!) * 60 + int.parse(match[4]!);
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final isOpen = closes > opens
        ? minutes >= opens && minutes < closes
        : minutes >= opens || minutes < closes;
    return isOpen ? OpeningStatus.open : OpeningStatus.closed;
  }
}
