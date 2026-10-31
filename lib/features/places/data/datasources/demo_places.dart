import 'dart:math' as math;

import '../../domain/entities/place_category.dart';
import '../models/place_model.dart';

/// Builds sample Damascus places around [latitude]/[longitude].
///
/// Used only when the live places API is unavailable, so the feed still has
/// realistic content to show. Offsets are in meters so the results stay
/// "nearby" wherever the device is.
List<PlaceModel> demoPlacesAround({
  required double latitude,
  required double longitude,
}) {
  const metersPerDegree = 111320.0;
  final longitudeScale =
      metersPerDegree * math.max(math.cos(latitude * math.pi / 180).abs(), 0.2);

  return [
    for (final (index, sample) in _samples.indexed)
      PlaceModel(
        id: 'demo/${index + 1}',
        name: sample.name,
        nameAr: sample.nameAr,
        category: sample.category,
        latitude: latitude + sample.northMeters / metersPerDegree,
        longitude: longitude + sample.eastMeters / longitudeScale,
        address: sample.address,
        phone: sample.phone,
        openingHours: sample.openingHours,
      ),
  ];
}

class _DemoPlace {
  const _DemoPlace({
    required this.name,
    required this.nameAr,
    required this.category,
    required this.address,
    required this.openingHours,
    required this.northMeters,
    required this.eastMeters,
    this.phone,
  });

  final String name;
  final String nameAr;
  final PlaceCategory category;
  final String address;
  final String openingHours;
  final int northMeters;
  final int eastMeters;
  final String? phone;
}

const _samples = [
  _DemoPlace(
    name: 'Nawfara Cafe',
    nameAr: 'مقهى النوفرة',
    category: PlaceCategory.cafe,
    address: 'Al Hamidiyah, Damascus',
    openingHours: '08:00–23:00',
    northMeters: 120,
    eastMeters: 80,
  ),
  _DemoPlace(
    name: 'Al Khawali Restaurant',
    nameAr: 'مطعم الخوالي',
    category: PlaceCategory.restaurant,
    address: 'Straight Street, Damascus',
    openingHours: '12:00–23:30',
    northMeters: -180,
    eastMeters: -140,
    phone: '+963 11 000 0001',
  ),
  _DemoPlace(
    name: 'Souq Al Hamidiyah',
    nameAr: 'سوق الحميدية',
    category: PlaceCategory.shopping,
    address: 'Al Hamidiyah, Damascus',
    openingHours: '09:00–21:00',
    northMeters: 360,
    eastMeters: 40,
  ),
  _DemoPlace(
    name: 'Damascus National Museum',
    nameAr: 'المتحف الوطني بدمشق',
    category: PlaceCategory.attraction,
    address: 'Shukri Al Quwatli St, Damascus',
    openingHours: '09:00–17:00',
    northMeters: -240,
    eastMeters: -520,
  ),
  _DemoPlace(
    name: 'Beit Al Mamlouka',
    nameAr: 'بيت المملوكة',
    category: PlaceCategory.hotel,
    address: 'Bab Touma, Damascus',
    openingHours: '24/7',
    northMeters: 420,
    eastMeters: 610,
    phone: '+963 11 000 0005',
  ),
  _DemoPlace(
    name: 'Al Rawda Cafe',
    nameAr: 'مقهى الروضة',
    category: PlaceCategory.cafe,
    address: 'Al Rawda, Damascus',
    openingHours: '07:30–00:00',
    northMeters: -700,
    eastMeters: 480,
  ),
  _DemoPlace(
    name: 'Sham Pharmacy',
    nameAr: 'صيدلية الشام',
    category: PlaceCategory.health,
    address: 'Mazzeh, Damascus',
    openingHours: '08:00–22:00',
    northMeters: -280,
    eastMeters: -120,
    phone: '+963 11 000 0007',
  ),
  _DemoPlace(
    name: 'Central Bank of Syria',
    nameAr: 'مصرف سورية المركزي',
    category: PlaceCategory.bank,
    address: 'Sabaa Bahrat, Damascus',
    openingHours: '08:00–15:00',
    northMeters: 480,
    eastMeters: -360,
  ),
  _DemoPlace(
    name: 'Mazzeh Fuel Station',
    nameAr: 'محطة وقود المزة',
    category: PlaceCategory.fuel,
    address: 'Mazzeh Highway, Damascus',
    openingHours: '24/7',
    northMeters: -1080,
    eastMeters: -300,
  ),
  _DemoPlace(
    name: 'Khan Al Harir',
    nameAr: 'خان الحرير',
    category: PlaceCategory.shopping,
    address: 'Al Buzuriyah, Damascus',
    openingHours: '10:00–20:00',
    northMeters: 780,
    eastMeters: 540,
  ),
  _DemoPlace(
    name: 'Tishreen Park',
    nameAr: 'حديقة تشرين',
    category: PlaceCategory.attraction,
    address: 'Tishreen Park, Damascus',
    openingHours: '09:00–22:00',
    northMeters: 1420,
    eastMeters: 120,
  ),
  _DemoPlace(
    name: 'Beit Al Sharq',
    nameAr: 'بيت الشرق',
    category: PlaceCategory.restaurant,
    address: 'Al Qassaa, Damascus',
    openingHours: '13:00–00:00',
    northMeters: 220,
    eastMeters: 760,
    phone: '+963 11 000 0012',
  ),
];
