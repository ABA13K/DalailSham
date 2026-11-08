import 'package:equatable/equatable.dart';

/// One number, address or link inside a contact group, as the service published
/// it. The backend marks at most one value of a group as primary.
class ServiceContactValue extends Equatable {
  const ServiceContactValue({required this.value, this.isPrimary = false});

  final String value;
  final bool isPrimary;

  @override
  List<Object?> get props => [value, isPrimary];
}

/// All values of one contact kind: phones, whatsapp, email, website and the
/// social links, each with the label the backend localized.
class ServiceContactGroup extends Equatable {
  const ServiceContactGroup({
    required this.type,
    required this.label,
    required this.values,
  });

  final String type;
  final String label;
  final List<ServiceContactValue> values;

  ServiceContactValue? get primary {
    for (final value in values) {
      if (value.isPrimary) return value;
    }
    return values.isEmpty ? null : values.first;
  }

  @override
  List<Object?> get props => [type, label, values];
}

/// One row of the service's week. Times arrive as `HH:MM:SS`; a closed day
/// carries nulls instead.
class ServiceWorkingDay extends Equatable {
  const ServiceWorkingDay({
    required this.day,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  final String day;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  @override
  List<Object?> get props => [day, openTime, closeTime, isClosed];
}

/// Everything the details endpoint publishes about one service, for the public
/// and the signed-in reader alike.
class ServiceDetail extends Equatable {
  const ServiceDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.categoryName,
    this.regionName,
    this.address,
    this.rating = 0,
    this.reviewsCount = 0,
    this.distanceKm,
    this.distanceText,
    this.isFavorited = false,
    this.isAuthenticated = false,
    this.mainImage,
    this.description,
    this.mapsUrl,
    this.lat,
    this.lng,
    this.isMain = false,
    this.visitsCount = 0,
    this.isOpenNow,
    this.contacts = const [],
    this.workingHours = const [],
    this.amenities = const [],
    this.imagesCount = 0,
    this.productsCount = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String? categoryName;
  final String? regionName;
  final String? address;
  final double rating;
  final int reviewsCount;
  final double? distanceKm;
  final String? distanceText;
  final bool isFavorited;

  /// Whether the answer came from the bearer-token variant.
  final bool isAuthenticated;
  final String? mainImage;
  final String? description;
  final String? mapsUrl;
  final double? lat;
  final double? lng;
  final bool isMain;
  final int visitsCount;

  /// Null when the backend did not judge the opening hours.
  final bool? isOpenNow;
  final List<ServiceContactGroup> contacts;
  final List<ServiceWorkingDay> workingHours;
  final List<String> amenities;
  final int imagesCount;
  final int productsCount;

  /// The first phone line, preferring the one marked primary.
  String? get phone => _firstOf('phone');

  String? get website => _firstOf('website');

  String? _firstOf(String type) {
    for (final group in contacts) {
      if (group.type == type) return group.primary?.value;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    categoryName,
    regionName,
    address,
    rating,
    reviewsCount,
    distanceKm,
    distanceText,
    isFavorited,
    isAuthenticated,
    mainImage,
    description,
    mapsUrl,
    lat,
    lng,
    isMain,
    visitsCount,
    isOpenNow,
    contacts,
    workingHours,
    amenities,
    imagesCount,
    productsCount,
  ];
}