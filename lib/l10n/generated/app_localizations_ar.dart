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
  String get sectionContact => 'التواصل والموقع';

  @override
  String get labelReviews => 'التقييمات';

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
      'اكتب لتضييق الخدمات في الأسفل حسب الاسم أو الفئة أو المنطقة، ثم اضغط البحث للتصفّح في الدليل بالكامل.';

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
  String get chatLocalNotice =>
      'تبقى الرسائل على هذا الجهاز فقط — المحادثة غير متصلة بعد.';

  @override
  String get servicesEmpty => 'لا توجد خدمات هنا بعد';

  @override
  String get servicesError => 'حدث خطأ أثناء تحميل الخدمات';

  @override
  String get topRatedTitle => 'الأعلى تقييماً بين الخدمات';

  @override
  String get nearbyTitle => 'الأقرب إليك';

  @override
  String get nearbyRandomTitle => 'مختارة لك';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesEmpty =>
      'لا توجد عناصر في المفضلة بعد — اضغط على القلب بجانب أي خدمة لإضافتها هنا.';

  @override
  String get favoritesNeedLogin =>
      'المفضلة تحتاج حساباً. سجّل الدخول ثم أعد المحاولة.';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get addedToFavorites => 'أُضيفت إلى المفضلة';

  @override
  String get removedFromFavorites => 'أُزيلت من المفضلة';

  @override
  String get favoritesError => 'تعذّر تحديث المفضلة';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get loginFieldLabel => 'البريد الإلكتروني أو رقم الجوال';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get mobileLabel => 'رقم الجوال';

  @override
  String get emailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get addressLabel => 'العنوان (اختياري)';

  @override
  String get genderLabel => 'الجنس';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get signIn => 'دخول';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get noAccount => 'لا تملك حساباً بعد؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get passwordTooShort => 'استخدم 6 أحرف على الأقل';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get genderRequired => 'اختر الجنس';

  @override
  String get loggedIn => 'تم تسجيل الدخول بنجاح';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get signedOut => 'تم تسجيل الخروج';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get accountProfileTitle => 'الملف الشخصي';

  @override
  String get profileSaved => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get photoPickFailed => 'تعذّر اختيار الصورة';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountWarning =>
      'سيؤدي هذا إلى حذف حسابك نهائيًا. أدخل كلمة المرور للتأكيد.';

  @override
  String get accountDeleted => 'تم حذف الحساب';

  @override
  String get cancel => 'إلغاء';

  @override
  String get vendorServiceTitle => 'خدمي';

  @override
  String get vendorServiceSaved => 'تم تحديث بيانات الخدمة بنجاح';

  @override
  String get removeMainImage => 'حذف الصورة الرئيسية';

  @override
  String get nameArabicLabel => 'الاسم (بالعربية)';

  @override
  String get nameEnglishLabel => 'الاسم (بالإنجليزية)';

  @override
  String get addressArabicLabel => 'العنوان (بالعربية)';

  @override
  String get addressEnglishLabel => 'العنوان (بالإنجليزية)';

  @override
  String get descriptionArabicLabel => 'الوصف (بالعربية)';

  @override
  String get descriptionEnglishLabel => 'الوصف (بالإنجليزية)';

  @override
  String get mapsUrlLabel => 'رابط خرائط جوجل';

  @override
  String get latitudeLabel => 'خط العرض';

  @override
  String get longitudeLabel => 'خط الطول';

  @override
  String get invalidUrl => 'أدخل رابطًا يبدأ بـ http أو https';

  @override
  String get invalidLatitude => 'يجب أن يكون خط العرض بين -90 و 90';

  @override
  String get invalidLongitude => 'يجب أن يكون خط الطول بين -180 و 180';

  @override
  String get tooLong => 'هذا النص طويل جدًا';

  @override
  String get labelRating => 'التقييم';

  @override
  String get labelVisits => 'الزيارات';

  @override
  String get labelPlan => 'الاشتراك';

  @override
  String get labelFlag => 'الخدمة';

  @override
  String get mainServiceFlag => 'الرئيسية';

  @override
  String get searchEmpty => 'لا يوجد ما يطابق هذا البحث';

  @override
  String get vendorJoinTitle => 'أدرج خدمتك';

  @override
  String get joinIntro =>
      'عرّف عن نفسك وعن خدمتك. تظهر الخدمة بعد مراجعتها من الإدارة.';

  @override
  String get joinAccountSection => 'الحساب';

  @override
  String get joinServiceSection => 'الخدمة';

  @override
  String get labelRegion => 'المنطقة';

  @override
  String get chooseRegion => 'اختر المنطقة';

  @override
  String get chooseCategory => 'اختر الفئة';

  @override
  String get regionRequired => 'اختر المنطقة التي تقع فيها خدمتك';

  @override
  String get categoryRequired => 'اختر الفئة المناسبة لخدمتك';

  @override
  String get companyEmailLabel => 'البريد الإلكتروني للشركة (اختياري)';

  @override
  String get addCoverPhoto => 'إضافة صورة غلاف';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get joinRequestSubmitted => 'تم إرسال الطلب، ستراجعه الإدارة';

  @override
  String get vendorContactsTitle => 'جهات الاتصال';

  @override
  String get contactsIntro =>
      'الأرقام والبريد والروابط التي يصل العملاء من خلالها إلى خدمتك.';

  @override
  String get contactsEmpty => 'لا توجد جهات اتصال بعد';

  @override
  String get addContact => 'أضف جهة اتصال';

  @override
  String get editContact => 'تعديل جهة الاتصال';

  @override
  String get chooseContactType => 'اختر النوع';

  @override
  String get labelContactType => 'النوع';

  @override
  String get labelContactValue => 'القيمة';

  @override
  String get contactTypeRequired => 'اختر نوع جهة الاتصال';

  @override
  String get contactValueRequired => 'أدخل الرقم أو العنوان أو الرابط';

  @override
  String get saveContact => 'حفظ';

  @override
  String get contactSaved => 'تم حفظ جهة الاتصال';

  @override
  String get primaryContact => 'الرئيسية';

  @override
  String get setPrimaryContact => 'اجعلها جهة الاتصال الرئيسية';

  @override
  String get deleteContact => 'حذف';

  @override
  String get deleteContactQuestion => 'حذف جهة الاتصال هذه؟';

  @override
  String get vendorImagesTitle => 'صور الخدمة';

  @override
  String get imagesIntro =>
      'الصور التي تظهر تحت خدمتك، بعد موافقة الإدارة عليها.';

  @override
  String imagesLimit(int count, int max) {
    return '$count من $max';
  }

  @override
  String get imagesEmpty => 'لا توجد صور بعد';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get imagePendingApproval => 'بانتظار الموافقة';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String get deleteImageQuestion => 'حذف هذه الصورة؟';

  @override
  String get deleteAllImages => 'حذف كل الصور';

  @override
  String get deleteAllImagesQuestion => 'حذف كل صور هذه الخدمة؟';

  @override
  String imagesRemovedAll(int count) {
    return 'تم حذف $count صورة';
  }

  @override
  String get imagesLimitReached => 'لا توجد مساحة لصورة أخرى';

  @override
  String get searchPrompt => 'اكتب للبحث في الخدمات المدرجة';

  @override
  String get filterCategory => 'الفئة';

  @override
  String get filterRegion => 'المنطقة';

  @override
  String get filterSort => 'الترتيب';

  @override
  String get filterRating => 'التقييم';

  @override
  String get sortLatest => 'الأحدث';

  @override
  String get sortTopRated => 'الأعلى تقييماً';

  @override
  String get sortNearest => 'الأقرب';

  @override
  String get ratingAny => 'أي تقييم';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get vendorProductsTitle => 'المنتجات';

  @override
  String get productsIntro =>
      'كل ما تبيعه خدمتك. المنتج الجديد أو المعدّل ينتظر موافقة الإدارة قبل أن يراه العملاء.';

  @override
  String get productsSearchHint => 'ابحث في المنتجات…';

  @override
  String get productsEmpty => 'لا توجد منتجات بعد';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل منتج';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get deleteProductQuestion => 'هل تريد حذف هذا المنتج؟';

  @override
  String get productSaved => 'تم حفظ المنتج';

  @override
  String get productDeleted => 'تم حذف المنتج';

  @override
  String get productPendingApproval => 'بانتظار الموافقة';

  @override
  String get productHidden => 'مخفي';

  @override
  String get productUnavailable => 'غير متوفر';

  @override
  String get priceLabel => 'السعر (ل.س)';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get activeLabel => 'ظاهر للزبائن';

  @override
  String get availableLabel => 'متوفر في المخزون';

  @override
  String get productCategoryRequired => 'اختر الفئة التي ينتمي إليها المنتج';

  @override
  String get filterStatus => 'الحالة';

  @override
  String get statusAny => 'كل الحالات';

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusApproved => 'معتمدة';

  @override
  String get statusRejected => 'مرفوضة';

  @override
  String get invalidPrice => 'أدخل سعرًا بين 0 و 9999999.99';

  @override
  String get invalidQuantity => 'أدخل عددًا صحيحًا حتى 999999';

  @override
  String get vendorAmenitiesTitle => 'ميزات الخدمة';

  @override
  String get amenitiesIntro =>
      'ما تقدمه خدمتك إضافةً إلى ما تبيعه. الميزة الجديدة أو المعدّلة تنتظر موافقة الإدارة قبل أن يراها العملاء.';

  @override
  String amenitiesLimit(int count, int max) {
    return '$count من $max';
  }

  @override
  String get amenitiesEmpty => 'لا توجد ميزات بعد';

  @override
  String get addAmenity => 'إضافة ميزة';

  @override
  String get editAmenity => 'تعديل ميزة';

  @override
  String get deleteAmenity => 'حذف الميزة';

  @override
  String get deleteAmenityQuestion => 'هل تريد حذف هذه الميزة؟';

  @override
  String get deleteAllAmenities => 'حذف كل الميزات';

  @override
  String get deleteAllAmenitiesQuestion => 'هل تريد حذف كل ميزات هذه الخدمة؟';

  @override
  String amenitiesRemovedAll(int count) {
    return 'تم حذف $count ميزة';
  }

  @override
  String get amenitiesLimitReached => 'لا مجال لميزة أخرى';

  @override
  String get amenityPendingApproval => 'بانتظار الموافقة';

  @override
  String get amenityWaitsForApproval =>
      'تصل الميزة إلى العملاء بعد موافقة الإدارة.';

  @override
  String get amenitySaved => 'تم حفظ الميزة';

  @override
  String get amenityDeleted => 'تم حذف الميزة';

  @override
  String get vendorStoriesTitle => 'أضف قصة';

  @override
  String get storyTypeTitle => 'نوع القصة';

  @override
  String get storyTypeImage => 'صورة';

  @override
  String get storyTypeVideo => 'فيديو';

  @override
  String get storyTypePoll => 'تصويت';

  @override
  String get storyCaptionArabicLabel => 'النص (بالعربية)';

  @override
  String get storyCaptionEnglishLabel => 'النص (بالإنكليزية)';

  @override
  String get storyPickPhoto => 'اختر صورة';

  @override
  String get storyPickVideo => 'اختر فيديو';

  @override
  String get storyPhotoRequired => 'اختر الصورة التي تعرضها القصة';

  @override
  String get storyVideoRequired => 'اختر الفيديو الذي تعرضه القصة';

  @override
  String get storyQuestionArabicLabel => 'السؤال (بالعربية)';

  @override
  String get storyQuestionEnglishLabel => 'السؤال (بالإنكليزية)';

  @override
  String get storyOptionsLabel => 'خيارات التصويت';

  @override
  String storyOptionLabel(int number) {
    return 'الخيار $number';
  }

  @override
  String get storyAddOption => 'أضف خياراً';

  @override
  String get storyRemoveOption => 'إزالة هذا الخيار';

  @override
  String get storyOptionsTooFew => 'التصويت يحتاج خيارين على الأقل';

  @override
  String get storyPublish => 'نشر القصة';

  @override
  String get storySaved => 'تم إنشاء القصة، بانتظار موافقة الإدارة';

  @override
  String get storyWaitsForApproval =>
      'تصل القصة إلى العملاء بعد موافقة الإدارة.';

  @override
  String storyExpiresIn(int hours) {
    return 'تنتهي خلال $hours ساعة';
  }

  @override
  String get storyNoVotes => 'لا توجد أصوات بعد';

  @override
  String get storyVoteHint => 'اضغط على إجابة لتُصوّت';

  @override
  String get storyVoteFailed => 'لم يُسجَّل تصويتك';

  @override
  String get serviceStoriesAll => 'عرض كل قصص هذه الخدمة';

  @override
  String get serviceStoriesEmpty => 'لا توجد قصص لهذه الخدمة حالياً';

  @override
  String get cityTitle => 'دمشق';

  @override
  String get mainCategories => 'الفئات الرئيسية';

  @override
  String get filtersTitle => 'الفلاتر';

  @override
  String get notificationsEmpty => 'لا يوجد جديد حالياً';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navMenu => 'القائمة';

  @override
  String get serviceProfileTitle => 'ملف الخدمة';

  @override
  String get sectionAbout => 'نبذة';

  @override
  String get sectionPhotos => 'الصور';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صور',
      one: 'صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String galleryPosition(int current, int total) {
    return '$current من $total';
  }

  @override
  String get galleryError => 'حدث خطأ أثناء تحميل الصور';

  @override
  String get sectionMenu => 'قائمة المنتجات';

  @override
  String get menuError => 'حدث خطأ أثناء تحميل المنتجات';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف',
      one: 'صنف واحد',
    );
    return '$_temp0';
  }

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get sectionReviews => 'التقييمات والتعليقات';

  @override
  String get reviewsEmpty => 'لا توجد تقييمات بعد';

  @override
  String get reviewsError => 'حدث خطأ أثناء تحميل التقييمات';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييمات',
      one: 'تقييم واحد',
    );
    return '$_temp0';
  }

  @override
  String get sortHighest => 'الأعلى تقييماً';

  @override
  String get sortLowest => 'الأقل تقييماً';

  @override
  String get reviewMine => 'تقييمك';

  @override
  String get reviewAnonymous => 'زائر';

  @override
  String get sectionHours => 'ساعات العمل';

  @override
  String get hoursToday => 'اليوم';

  @override
  String get sectionAmenities => 'المرافق والخدمات';

  @override
  String visitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زيارات',
      one: 'زيارة واحدة',
    );
    return '$_temp0';
  }
}
