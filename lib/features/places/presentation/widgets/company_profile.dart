import 'package:flutter/material.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';

/// A string that ships in both app languages.
class LocalizedText {
  const LocalizedText(this.en, this.ar);

  final String en;
  final String ar;

  String forLocale(String languageCode) => languageCode == 'ar' ? ar : en;
}

class ProfileSpecialty {
  const ProfileSpecialty(this.label);

  final LocalizedText label;
}

class ProfileAmenity {
  const ProfileAmenity(this.label, this.icon);

  final LocalizedText label;
  final IconData icon;
}

enum OpeningStatus { open, closed, open24 }

/// Business-profile content derived from a [Place].
///
/// The live API only exposes basic OpenStreetMap tags, so profile extras
/// (price level, specialties, amenities, review spread) are generated from the
/// place id. They stay stable between launches and differ per company.
class CompanyProfile {
  CompanyProfile(this.place) : _seed = _hash(place.id);

  final Place place;
  final int _seed;

  static int _hash(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  LocalizedText get about => _about[place.category]!;

  int get priceLevel => switch (place.category) {
    PlaceCategory.restaurant ||
    PlaceCategory.cafe ||
    PlaceCategory.hotel => 2 + _seed % 3,
    PlaceCategory.shopping || PlaceCategory.attraction => 1 + _seed % 3,
    _ => 1 + _seed % 2,
  };

  int get sinceYear => 1988 + _seed % 35;

  List<ProfileSpecialty> get specialties =>
      _pick(_specialties[place.category] ?? const [], 3);

  List<ProfileAmenity> get amenities =>
      _pick(_amenities[place.category] ?? const [], 4);

  List<T> _pick<T>(List<T> pool, int count) {
    if (pool.isEmpty) return const [];
    final start = _seed % pool.length;
    final size = count < pool.length ? count : pool.length;
    return [for (var i = 0; i < size; i++) pool[(start + i) % pool.length]];
  }

  /// Share of reviews for 5, 4, 3, 2 and 1 stars, in that order.
  ///
  /// A small 1–3 star tail is split against 4/5 star reviews so the weighted
  /// average always matches [Place.rating].
  List<double> get ratingDistribution {
    final rating = place.rating;
    final tail = (0.22 - (rating - 3.8) * 0.18).clamp(0.03, 0.22);
    final fiveStar = rating - 4 + 1.45 * tail;
    return [
      fiveStar,
      1 - tail - fiveStar,
      tail * 0.64,
      tail * 0.27,
      tail * 0.09,
    ];
  }

  /// Whether the place is open right now, approximated from its hours string.
  ///
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

const Map<PlaceCategory, LocalizedText> _about = {
  PlaceCategory.restaurant: LocalizedText(
    'A welcoming restaurant serving freshly prepared Syrian dishes, from mezze '
        'to charcoal grills, in a relaxed setting.',
    'مطعم يقدّم أطباقاً سورية طازجة من المقبلات إلى المشاوي على الفحم، في أجواء مريحة.',
  ),
  PlaceCategory.cafe: LocalizedText(
    'A neighbourhood café with specialty coffee, freshly baked desserts and '
        'comfortable seating for long conversations.',
    'مقهى في الحي يقدّم القهوة المختصة والحلويات الطازجة وجلسات مريحة لساعات طويلة.',
  ),
  PlaceCategory.shopping: LocalizedText(
    'A local shop with a curated selection of goods, friendly service and '
        'convenient opening hours.',
    'متجر محلي يضم تشكيلة منتقاة من السلع، مع خدمة ودودة وساعات عمل مريحة.',
  ),
  PlaceCategory.health: LocalizedText(
    'A trusted health provider offering professional care, practical advice '
        'and convenient access.',
    'مرفق صحي موثوق يقدّم رعاية مهنية ونصائح عملية ووصولاً مريحاً.',
  ),
  PlaceCategory.hotel: LocalizedText(
    'A comfortable stay with well-kept rooms, attentive service and easy '
        'access to the city’s highlights.',
    'إقامة مريحة بغرف معتنى بها وخدمة مهتمة وسهولة وصول إلى معالم المدينة.',
  ),
  PlaceCategory.attraction: LocalizedText(
    'One of the area’s notable landmarks, ideal for a relaxed visit with '
        'family and friends.',
    'أحد المعالم البارزة في المنطقة، مثالي لزيارة هادئة مع العائلة والأصدقاء.',
  ),
  PlaceCategory.fuel: LocalizedText(
    'A convenient fuel stop with essential services for drivers, open '
        'throughout the day.',
    'محطة وقود مريحة مع خدمات أساسية للسائقين، مفتوحة طوال اليوم.',
  ),
  PlaceCategory.bank: LocalizedText(
    'A full-service banking branch offering everyday personal and business '
        'services.',
    'فرع مصرفي متكامل يقدّم الخدمات الشخصية والتجارية اليومية.',
  ),
  PlaceCategory.other: LocalizedText(
    'A local business serving the neighbourhood with friendly, professional '
        'service.',
    'عمل محلي يخدم الحي بخدمة ودودة ومهنية.',
  ),
};

const Map<PlaceCategory, List<ProfileSpecialty>> _specialties = {
  PlaceCategory.restaurant: [
    ProfileSpecialty(LocalizedText('Syrian mezze', 'مقبلات شامية')),
    ProfileSpecialty(LocalizedText('Charcoal grills', 'مشاوي على الفحم')),
    ProfileSpecialty(LocalizedText('Fresh bread', 'خبز طازج')),
    ProfileSpecialty(LocalizedText('Vegetarian dishes', 'أطباق نباتية')),
  ],
  PlaceCategory.cafe: [
    ProfileSpecialty(LocalizedText('Specialty coffee', 'قهوة مختصة')),
    ProfileSpecialty(LocalizedText('Arabic coffee', 'قهوة عربية')),
    ProfileSpecialty(LocalizedText('Desserts', 'حلويات')),
    ProfileSpecialty(LocalizedText('Breakfast', 'فطور')),
  ],
  PlaceCategory.shopping: [
    ProfileSpecialty(LocalizedText('Local crafts', 'حرف محلية')),
    ProfileSpecialty(LocalizedText('Souvenirs', 'تحف تذكارية')),
    ProfileSpecialty(LocalizedText('Textiles', 'منسوجات')),
    ProfileSpecialty(LocalizedText('Gifts', 'هدايا')),
  ],
  PlaceCategory.health: [
    ProfileSpecialty(LocalizedText('Walk-in service', 'خدمة دون موعد')),
    ProfileSpecialty(LocalizedText('Expert staff', 'طاقم خبير')),
    ProfileSpecialty(LocalizedText('Health advice', 'استشارات صحية')),
    ProfileSpecialty(LocalizedText('Convenient hours', 'ساعات مريحة')),
  ],
  PlaceCategory.hotel: [
    ProfileSpecialty(LocalizedText('Rooms & suites', 'غرف وأجنحة')),
    ProfileSpecialty(LocalizedText('Breakfast', 'فطور')),
    ProfileSpecialty(LocalizedText('City tours', 'جولات في المدينة')),
    ProfileSpecialty(LocalizedText('Airport pickup', 'استقبال من المطار')),
  ],
  PlaceCategory.attraction: [
    ProfileSpecialty(LocalizedText('Guided tours', 'جولات مرشدة')),
    ProfileSpecialty(LocalizedText('Family activities', 'أنشطة عائلية')),
    ProfileSpecialty(LocalizedText('Historic site', 'موقع تاريخي')),
    ProfileSpecialty(LocalizedText('Photo spots', 'أماكن تصوير')),
  ],
  PlaceCategory.fuel: [
    ProfileSpecialty(LocalizedText('Fuel & diesel', 'بنزين وديزل')),
    ProfileSpecialty(LocalizedText('Air & water', 'هواء وماء')),
    ProfileSpecialty(LocalizedText('Mini market', 'متجر صغير')),
    ProfileSpecialty(LocalizedText('Car wash', 'غسيل سيارات')),
  ],
  PlaceCategory.bank: [
    ProfileSpecialty(LocalizedText('ATM services', 'خدمات الصراف')),
    ProfileSpecialty(LocalizedText('Currency exchange', 'صرف العملات')),
    ProfileSpecialty(LocalizedText('Personal banking', 'خدمات شخصية')),
    ProfileSpecialty(LocalizedText('Business banking', 'خدمات تجارية')),
  ],
  PlaceCategory.other: [
    ProfileSpecialty(LocalizedText('Friendly service', 'خدمة ودودة')),
    ProfileSpecialty(LocalizedText('Central location', 'موقع مركزي')),
    ProfileSpecialty(LocalizedText('Card payments', 'دفع بالبطاقة')),
    ProfileSpecialty(LocalizedText('Local business', 'عمل محلي')),
  ],
};

const _wifi = ProfileAmenity(
  LocalizedText('Free Wi-Fi', 'واي فاي مجاني'),
  Icons.wifi_rounded,
);
const _parking = ProfileAmenity(
  LocalizedText('Parking', 'موقف سيارات'),
  Icons.local_parking_rounded,
);
const _cards = ProfileAmenity(
  LocalizedText('Card payments', 'دفع بالبطاقة'),
  Icons.credit_card_rounded,
);
const _outdoor = ProfileAmenity(
  LocalizedText('Outdoor seating', 'جلسات خارجية'),
  Icons.deck_rounded,
);
const _family = ProfileAmenity(
  LocalizedText('Family friendly', 'مناسب للعائلات'),
  Icons.family_restroom_rounded,
);
const _accessible = ProfileAmenity(
  LocalizedText('Step-free access', 'دخول مهيأ للكراسي المتحركة'),
  Icons.accessible_forward_rounded,
);
const _delivery = ProfileAmenity(
  LocalizedText('Delivery', 'توصيل'),
  Icons.delivery_dining_rounded,
);
const _reservations = ProfileAmenity(
  LocalizedText('Reservations', 'حجز مسبق'),
  Icons.event_available_rounded,
);
const _takeaway = ProfileAmenity(
  LocalizedText('Takeaway', 'طلبات سفري'),
  Icons.takeout_dining_rounded,
);
const _breakfast = ProfileAmenity(
  LocalizedText('Breakfast', 'فطور'),
  Icons.free_breakfast_rounded,
);
const _shuttle = ProfileAmenity(
  LocalizedText('Airport shuttle', 'نقل من المطار'),
  Icons.airport_shuttle_rounded,
);
const _tours = ProfileAmenity(
  LocalizedText('Guided tours', 'جولات مرشدة'),
  Icons.tour_rounded,
);
const _airWater = ProfileAmenity(
  LocalizedText('Air & water', 'هواء وماء'),
  Icons.air_rounded,
);
const _market = ProfileAmenity(
  LocalizedText('Mini market', 'متجر صغير'),
  Icons.storefront_rounded,
);
const _carWash = ProfileAmenity(
  LocalizedText('Car wash', 'غسيل سيارات'),
  Icons.local_car_wash_rounded,
);
const _atm = ProfileAmenity(
  LocalizedText('ATM', 'صراف آلي'),
  Icons.atm_rounded,
);

const Map<PlaceCategory, List<ProfileAmenity>> _amenities = {
  PlaceCategory.restaurant: [
    _outdoor,
    _delivery,
    _reservations,
    _family,
    _cards,
    _wifi,
  ],
  PlaceCategory.cafe: [
    _wifi,
    _outdoor,
    _cards,
    _takeaway,
    _family,
    _reservations,
  ],
  PlaceCategory.shopping: [_cards, _parking, _family, _accessible, _delivery],
  PlaceCategory.health: [_accessible, _parking, _cards, _family],
  PlaceCategory.hotel: [
    _wifi,
    _parking,
    _breakfast,
    _shuttle,
    _accessible,
    _cards,
  ],
  PlaceCategory.attraction: [_family, _accessible, _tours, _parking, _cards],
  PlaceCategory.fuel: [
    _airWater,
    _market,
    _carWash,
    _accessible,
    _cards,
    _parking,
  ],
  PlaceCategory.bank: [_atm, _accessible, _parking, _cards],
  PlaceCategory.other: [_wifi, _cards, _parking, _family, _accessible],
};
