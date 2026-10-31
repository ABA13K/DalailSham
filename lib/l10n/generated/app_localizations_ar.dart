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
  String get exploreCategories => 'تصفح الأقسام';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get loadMore => 'المزيد';

  @override
  String get categoriesEmpty => 'لا توجد أقسام بعد';

  @override
  String get exploreRegions => 'تصفح المناطق';

  @override
  String get regionsEmpty => 'لا توجد مناطق بعد';

  @override
  String servicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خدمة',
      many: '$count خدمة',
      few: '$count خدمات',
      two: 'خدمتان',
      one: 'خدمة واحدة',
      zero: 'لا توجد خدمات',
    );
    return '$_temp0';
  }

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
  String get profileTitle => 'الملف التجاري';

  @override
  String get sectionAbout => 'نبذة عن المكان';

  @override
  String get sectionContact => 'التواصل والموقع';

  @override
  String get sectionAmenities => 'الخدمات والمرافق';

  @override
  String get sectionReviews => 'التقييمات والمراجعات';

  @override
  String get labelPrice => 'الفئة السعرية';

  @override
  String get labelReviews => 'التقييمات';

  @override
  String get labelSince => 'منذ';

  @override
  String get statusOpenNow => 'مفتوح الآن';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get statusOpen24 => 'مفتوح 24 ساعة';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get viewStory => 'شاهد القصة';

  @override
  String get viewPhoto => 'عرض الصورة';

  @override
  String get profilePhoto => 'صورة الملف';

  @override
  String profilePopularFor(String first, String second) {
    return 'يقصدها الزوار من أجل $first و$second.';
  }

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
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get adLabel => 'إعلان';

  @override
  String get menuTitle => 'قائمة الطعام';

  @override
  String get menuSubtitle => 'قائمة تجريبية · الأسعار بالليرة السورية';

  @override
  String get currencySyp => 'ل.س';

  @override
  String ratingSummary(String rating, int count) {
    return 'التقييم $rating من 5 · $count تقييم';
  }

  @override
  String get tutorialMenu => 'جولة تعريفية';

  @override
  String get tutorialStoriesTitle => 'القصص';

  @override
  String get tutorialStoriesBody =>
      'اضغط على أي دائرة في الأعلى لعرض الأماكن بملء الشاشة. تتحول القصص المشاهدة إلى رمادي.';

  @override
  String get tutorialAdsTitle => 'العروض';

  @override
  String get tutorialAdsBody =>
      'تتحرك العروض المحلية تلقائياً — اسحب لتصفحها بنفسك.';

  @override
  String get tutorialSearchTitle => 'البحث والتصفية';

  @override
  String get tutorialSearchBody =>
      'ابحث بالاسم، ثم ضيّق النتائج عبر فئات الأزرار في الأسفل.';

  @override
  String get tutorialMenuTitle => 'القائمة والإعدادات';

  @override
  String get tutorialMenuBody =>
      'افتح القائمة لتغيير اللغة أو تفعيل الوضع الداكن أو إعادة هذه الجولة.';

  @override
  String get tutorialDone => 'فهمت';

  @override
  String get storiesTitle => 'القصص';

  @override
  String get storiesNow => 'الآن';

  @override
  String get storiesClose => 'إغلاق القصص';

  @override
  String get viewPlace => 'عرض المكان';

  @override
  String get demoDataNotice => 'بيانات تجريبية — تعذّر تحميل الأماكن المباشرة.';

  @override
  String get chat => 'محادثة';

  @override
  String get chatRoomTitle => 'غرفة النقاش';

  @override
  String get chatHint => 'اكتب رسالة…';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد — ابدأ النقاش.';

  @override
  String get chatError => 'حدث خطأ أثناء تحميل الرسائل';

  @override
  String get chatDemoNotice =>
      'محادثة تجريبية — تبقى الرسائل على هذا الجهاز فقط.';

  @override
  String get servicesEmpty => 'لا توجد خدمات ضمن هذه الفئة بعد';
}
