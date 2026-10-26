// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دلي الشام';

  @override
  String get appTagline => 'اكتشف الأماكن من حولك';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ الاستكشاف';

  @override
  String get onboardingWelcomeTitle => 'أهلاً بك في دلي الشام';

  @override
  String get onboardingWelcomeBody =>
      'دليلك لاكتشاف أفضل المطاعم والمقاهي والمعالم القريبة منك.';

  @override
  String get onboardingExploreTitle => 'كل ما تحتاجه قريب منك';

  @override
  String get onboardingExploreBody =>
      'مطاعم ومقاهٍ، فنادق ومعالم، صيدليات وبنوك — صنّف وابحث واعثر على ما يناسبك بسهولة.';

  @override
  String get onboardingLocationTitle => 'أماكنك على الخريطة';

  @override
  String get onboardingLocationBody =>
      'اسمح بالوصول إلى موقعك لنعرض لك الأماكن الأقرب والاتجاهات إليها بضغطة واحدة.';

  @override
  String get homeTitle => 'الأماكن القريبة';

  @override
  String get searchHint => 'ابحث عن الأماكن…';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryRestaurant => 'مطاعم';

  @override
  String get categoryCafe => 'مقاهي';

  @override
  String get categoryShopping => 'تسوق';

  @override
  String get categoryHealth => 'صحة';

  @override
  String get categoryHotel => 'فنادق';

  @override
  String get categoryAttraction => 'معالم';

  @override
  String get categoryFuel => 'وقود';

  @override
  String get categoryBank => 'بنوك';

  @override
  String get locationLoading => 'جارٍ البحث عن الأماكن من حولك…';

  @override
  String get locationPermissionTitle => 'مطلوب الوصول إلى الموقع';

  @override
  String get locationPermissionMessage =>
      'نستخدم موقعك للعثور على الأماكن من حولك. يرجى تفعيل الإذن من إعدادات النظام.';

  @override
  String get locationServiceDisabled =>
      'خدمات الموقع معطلة. يرجى تفعيلها من إعدادات النظام.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get placesEmpty => 'لا توجد أماكن قريبة';

  @override
  String get placesError => 'حدث خطأ أثناء تحميل الأماكن';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String distanceMeters(int value) {
    return '$value م';
  }

  @override
  String distanceKilometers(num value) {
    return '$value كم';
  }

  @override
  String get detailsTitle => 'تفاصيل المكان';

  @override
  String get labelCategory => 'الفئة';

  @override
  String get labelDistance => 'المسافة';

  @override
  String get labelAddress => 'العنوان';

  @override
  String get labelPhone => 'الهاتف';

  @override
  String get labelWebsite => 'الموقع الإلكتروني';

  @override
  String get labelOpeningHours => 'ساعات العمل';

  @override
  String get valueUnknown => 'غير متوفر';

  @override
  String get getDirections => 'احصل على الاتجاهات';

  @override
  String get call => 'اتصال';

  @override
  String get visitWebsite => 'زيارة الموقع';

  @override
  String get unsupportedAction => 'هذا الإجراء غير متاح على هذا الجهاز';

  @override
  String get changeLanguage => 'English';

  @override
  String get localeSwitchTooltip => 'تغيير اللغة';

  @override
  String get storiesTitle => 'القصص';
}
