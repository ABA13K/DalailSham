import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/features/service_profile/data/models/service_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// The envelope the signed-in details endpoint answered with.
Map<String, dynamic> _envelope() => {
  'locale': 'ar',
  'is_authenticated': true,
  'is_favorited': true,
  'data': {
    'id': 1,
    'name': 'الاسد',
    'slug': 'amran',
    'category': {'id': 1, 'name': 'مطاعم'},
    'region': {'id': 1, 'name': 'المزة'},
    'address': 'دمشق',
    'rating': 0,
    'reviews_count': 0,
    'distance_km': null,
    'distance_text': null,
    'is_favorited': true,
    'main_image':
        'https://dalildimashq.com/storage/app/public/join_requests/images/a.jpg',
    'description': 'عمران',
    'google_maps_url': 'https://www.google.com/maps?q=33.5298611,36.2337500',
    'lat': 33.5298611,
    'lng': 36.23375,
    'is_main': true,
    'visits_count': 15,
    'is_open_now': true,
    'branch_group': null,
    'contacts': [
      {
        'type': 'email',
        'type_label': 'بريد إلكتروني',
        'values': [
          {'value': 'amran1@gmail.com', 'is_primary': false},
        ],
      },
      {
        'type': 'phone',
        'type_label': 'هاتف',
        'values': [
          {'value': '0999111222', 'is_primary': true},
          {'value': '0999111223', 'is_primary': false},
        ],
      },
      {
        'type': 'website',
        'type_label': 'موقع إلكتروني',
        'values': [
          {'value': 'https://aa-dev.online/', 'is_primary': false},
        ],
      },
    ],
    'working_hours': [
      {
        'day': 'السبت',
        'open_time': '10:00:00',
        'close_time': '22:00:00',
        'is_closed': false,
      },
      {
        'day': 'الجمعة',
        'open_time': null,
        'close_time': null,
        'is_closed': true,
      },
    ],
    'amenities': [
      {'name': 'مكان صلاة111'},
    ],
    'counts': {'images_count': 3, 'products_count': 1, 'reviews_count': 0},
  },
};

void main() {
  test('reads the whole signed-in envelope', () {
    final detail = ServiceDetailModel.fromEnvelope(_envelope());

    expect(detail.id, 1);
    expect(detail.name, 'الاسد');
    expect(detail.slug, 'amran');
    expect(detail.categoryName, 'مطاعم');
    expect(detail.regionName, 'المزة');
    expect(detail.address, 'دمشق');
    expect(detail.reviewsCount, 0);
    expect(detail.isFavorited, isTrue);
    expect(detail.isAuthenticated, isTrue);
    expect(detail.description, 'عمران');
    expect(detail.mapsUrl, contains('33.5298611'));
    expect(detail.lat, 33.5298611);
    expect(detail.lng, 36.23375);
    expect(detail.isMain, isTrue);
    expect(detail.visitsCount, 15);
    expect(detail.isOpenNow, isTrue);
    expect(detail.imagesCount, 3);
    expect(detail.productsCount, 1);
  });

  test('keeps the contact groups with their primary value', () {
    final detail = ServiceDetailModel.fromEnvelope(_envelope());

    expect(detail.contacts, hasLength(3));
    final phone = detail.contacts.firstWhere((group) => group.type == 'phone');
    expect(phone.label, 'هاتف');
    expect(phone.values, hasLength(2));
    expect(phone.primary?.value, '0999111222');
    expect(detail.phone, '0999111222');
    expect(detail.website, 'https://aa-dev.online/');
  });

  test('keeps the closed day with no times', () {
    final detail = ServiceDetailModel.fromEnvelope(_envelope());

    expect(detail.workingHours, hasLength(2));
    expect(detail.workingHours.last.day, 'الجمعة');
    expect(detail.workingHours.last.isClosed, isTrue);
    expect(detail.workingHours.last.openTime, isNull);
    expect(detail.amenities, ['مكان صلاة111']);
  });

  test('the public envelope carries no favourite and no authentication', () {
    final envelope = _envelope()
      ..remove('is_authenticated')
      ..remove('is_favorited');
    (envelope['data'] as Map<String, dynamic>).remove('is_favorited');

    final detail = ServiceDetailModel.fromEnvelope(envelope);

    expect(detail.isAuthenticated, isFalse);
    expect(detail.isFavorited, isFalse);
  });

  test('a body without a service is a parsing failure', () {
    expect(
      () => ServiceDetailModel.fromEnvelope(const {'locale': 'ar'}),
      throwsA(isA<ParseException>()),
    );
  });

  test('a service without a name is a parsing failure', () {
    final envelope = _envelope();
    (envelope['data'] as Map<String, dynamic>)['name'] = '  ';

    expect(
      () => ServiceDetailModel.fromEnvelope(envelope),
      throwsA(isA<ParseException>()),
    );
  });
}
