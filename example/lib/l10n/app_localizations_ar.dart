// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'استوديو المواقع';

  @override
  String get commonLanguage => 'اللغة';

  @override
  String get settingsAppLanguage => 'لغة التطبيق';

  @override
  String get settingsAppLanguageDevice => 'لغة الجهاز';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCopy => 'نسخ';

  @override
  String get commonRawResponse => 'الاستجابة الخام';

  @override
  String commonApiResponse(String api) {
    return 'استجابة $api';
  }

  @override
  String get errorRequestTimedOut => 'انتهت مهلة الطلب.';

  @override
  String errorNetwork(String detail) {
    return 'خطأ في الشبكة: $detail';
  }

  @override
  String errorHttpStatus(int status) {
    return 'تعذّر إتمام الطلب (رمز HTTP ‏$status).';
  }

  @override
  String errorApiKeyRejected(int status, String detail) {
    return 'رُفض مفتاح API ‏($status): $detail تحقّق من المفتاح ومنطقته والإجراءات المسموح بها في الإعدادات.';
  }

  @override
  String errorNotFound(String detail) {
    return 'غير موجود: $detail';
  }

  @override
  String get errorTooManyRequests =>
      'عدد الطلبات كبير جدًا. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get errorLocationServicesOff => 'خدمات الموقع متوقفة على هذا الجهاز.';

  @override
  String get errorLocationPermissionDenied => 'تم رفض إذن الوصول إلى الموقع.';

  @override
  String get errorLocationPermissionDeniedForever =>
      'تم رفض إذن الموقع نهائيًا. فعّله من إعدادات النظام.';

  @override
  String get errorSettingsNotSaved => 'تعذّر حفظ الإعدادات.';

  @override
  String get errorAppLanguageNotSaved => 'تعذّر حفظ لغة التطبيق.';

  @override
  String get errorGeofencesNotRead =>
      'تعذّرت قراءة السياجات الجغرافية المحفوظة.';

  @override
  String get errorGeofencesNotSaved => 'تعذّر حفظ السياجات الجغرافية.';

  @override
  String get errorGeocodeAddressRequired =>
      'أدخل عنوانًا لتحويله إلى إحداثيات.';

  @override
  String get errorSearchQueryRequired => 'اكتب ما تريد البحث عنه.';

  @override
  String get errorGeofenceNameRequired => 'أدخل اسمًا للسياج الجغرافي.';

  @override
  String get errorGeofencePolygonTooFewPoints =>
      'يحتاج المضلّع إلى 3 نقاط على الأقل.';

  @override
  String get errorGeofenceRadiusNotPositive =>
      'يجب أن يكون نصف القطر أكبر من صفر.';

  @override
  String get errorIsolineThresholdRequired => 'اختر حدًّا واحدًا على الأقل.';

  @override
  String errorIsolineTooManyThresholds(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'لا يمكن اختيار أكثر من $max حدّ.',
      many: 'لا يمكن اختيار أكثر من $max حدًّا.',
      few: 'لا يمكن اختيار أكثر من $max حدود.',
      two: 'لا يمكن اختيار أكثر من حدّين.',
      one: 'لا يمكن اختيار أكثر من حدّ واحد.',
    );
    return '$_temp0';
  }

  @override
  String get errorRouteSameOriginAndDestination =>
      'نقطة الانطلاق والوجهة هما المكان نفسه.';

  @override
  String errorRouteTooManyStops(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'لا يمكن أن يضمّ المسار أكثر من $max محطة.',
      many: 'لا يمكن أن يضمّ المسار أكثر من $max محطة.',
      few: 'لا يمكن أن يضمّ المسار أكثر من $max محطات.',
      two: 'لا يمكن أن يضمّ المسار أكثر من محطتين.',
      one: 'لا يمكن أن يضمّ المسار أكثر من محطة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get errorMatrixPointsRequired =>
      'أضف نقطة انطلاق واحدة ووجهة واحدة على الأقل.';

  @override
  String errorMatrixTooManyPoints(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'استخدم $max نقطة انطلاق و$max وجهة كحدّ أقصى.',
      many: 'استخدم $max نقطة انطلاق و$max وجهة كحدّ أقصى.',
      few: 'استخدم $max نقاط انطلاق و$max وجهات كحدّ أقصى.',
      two: 'استخدم نقطتَي انطلاق ووجهتين كحدّ أقصى.',
      one: 'استخدم نقطة انطلاق واحدة ووجهة واحدة كحدّ أقصى.',
    );
    return '$_temp0';
  }

  @override
  String get errorOptimizeStopsRequired =>
      'أضف محطة واحدة على الأقل إلى جانب نقطة البداية.';

  @override
  String errorOptimizeTooManyStops(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'لا يمكن تحسين ترتيب أكثر من $max محطة.',
      many: 'لا يمكن تحسين ترتيب أكثر من $max محطة.',
      few: 'لا يمكن تحسين ترتيب أكثر من $max محطات.',
      two: 'لا يمكن تحسين ترتيب أكثر من محطتين.',
      one: 'لا يمكن تحسين ترتيب أكثر من محطة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get errorSnapTooFewPoints =>
      'يحتاج مسار التتبّع إلى نقطتين على الأقل.';

  @override
  String errorSnapTooManyPoints(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'لا يمكن أن يضمّ مسار التتبّع أكثر من $max نقطة.',
      many: 'لا يمكن أن يضمّ مسار التتبّع أكثر من $max نقطة.',
      few: 'لا يمكن أن يضمّ مسار التتبّع أكثر من $max نقاط.',
      two: 'لا يمكن أن يضمّ مسار التتبّع أكثر من نقطتين.',
      one: 'لا يمكن أن يضمّ مسار التتبّع أكثر من نقطة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get errorSnapNoRoute => 'لا يوجد مسار بين هذه النقاط.';

  @override
  String get errorTrackerPickTripEnds =>
      'اضغط على الخريطة مرتين لتحديد بداية الرحلة المحاكاة ونهايتها.';

  @override
  String get errorTrackerNoRoute => 'لم يُعثر على مسار للرحلة المحاكاة.';

  @override
  String get commonApiKey => 'مفتاح API';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get mapExplorerTitle => 'مستكشف الخرائط';

  @override
  String get staticMapTitle => 'الخرائط الثابتة';

  @override
  String get searchTitle => 'البحث عن الأماكن';

  @override
  String get nearbyTitle => 'البحث في الجوار';

  @override
  String get geocodeTitle => 'الترميز الجغرافي';

  @override
  String get directionsTitle => 'الاتجاهات';

  @override
  String get isolinesTitle => 'نطاقات الوصول';

  @override
  String get routeMatrixTitle => 'مصفوفة المسارات';

  @override
  String get optimizeTitle => 'تحسين ترتيب المحطات';

  @override
  String get snapTitle => 'المطابقة مع الطرق';

  @override
  String get geofencesTitle => 'السياجات الجغرافية';

  @override
  String get trackerTitle => 'المتتبّع';

  @override
  String get homeHeroSubtitle =>
      'الخرائط والأماكن والمسارات عبر مفتاح API واحد.';

  @override
  String get homeSectionMaps => 'الخرائط';

  @override
  String get homeSectionPlaces => 'الأماكن';

  @override
  String get homeSectionRoutes => 'المسارات';

  @override
  String get homeSectionGeofencing => 'السياجات الجغرافية والتتبّع';

  @override
  String get homeMapExplorerDescription =>
      'أنماط قياسية وأحادية اللون وهجينة وفضائية، مع الوضع الداكن والعروض السياسية والتضاريس وخطوط الكنتور وطبقات حركة المرور ووسائل التنقّل.';

  @override
  String get homeStaticMapDescription =>
      'أنشئ صور خرائط تتضمّن علامات وخطوطًا وتسميات ومقياس رسم.';

  @override
  String get homeSearchTitle => 'البحث';

  @override
  String get homeSearchDescription =>
      'ابحث عن الأنشطة التجارية والمعالم والعناوين مع اقتراحات أثناء الكتابة وتفاصيل كاملة.';

  @override
  String get homeNearbyTitle => 'في الجوار';

  @override
  String get homeNearbyDescription =>
      'المعالم المحيطة بموقع ما، مصنّفة حسب الفئة.';

  @override
  String get homeGeocodeTitle => 'الترميز الجغرافي';

  @override
  String get homeGeocodeDescription =>
      'حوّل العناوين النصية أو المنظَّمة إلى إحداثيات.';

  @override
  String get homeReverseGeocodeTitle => 'الترميز الجغرافي العكسي';

  @override
  String get homeReverseGeocodeDescription =>
      'حوّل الإحداثيات إلى عناوين وشوارع ومناطق.';

  @override
  String get homeDirectionsDescription =>
      'مسارات للسيارات والمشي والدراجات البخارية والشاحنات، مع محطات توقّف ومسارات بديلة وخيارات تجنّب وحركة المرور وأوقات المغادرة.';

  @override
  String get homeIsolinesDescription =>
      'المناطق التي يمكن الوصول إليها خلال زمن أو مسافة محددة.';

  @override
  String get homeRouteMatrixDescription =>
      'زمن الرحلة والمسافة بين عدة نقاط انطلاق ووجهات.';

  @override
  String get homeOptimizeDescription => 'أفضل ترتيب لزيارة مجموعة من المحطات.';

  @override
  String get homeSnapDescription =>
      'طابِق مسارات GPS غير الدقيقة مع شبكة الطرق.';

  @override
  String get homeGeofencesApis => 'تقييم على الجهاز';

  @override
  String get homeGeofencesDescription =>
      'ارسم سياجات جغرافية دائرية أو مضلّعة، أو أنشئها من نطاقات الوصول.';

  @override
  String get homeTrackerDescription =>
      'تتبّع مباشر أو محاكى مع تنبيهات الدخول إلى السياجات الجغرافية والخروج منها.';

  @override
  String get commonOk => 'حسنًا';

  @override
  String get commonDefault => 'الافتراضي';

  @override
  String get commonOff => 'إيقاف';

  @override
  String get commonLight => 'فاتح';

  @override
  String get commonDark => 'داكن';

  @override
  String get commonPoliticalView => 'المنظور السياسي';

  @override
  String get unitsMetric => 'متري';

  @override
  String get unitsImperial => 'إمبراطوري';

  @override
  String get mapStyleTitle => 'نمط الخريطة';

  @override
  String get mapStyleStandard => 'قياسي';

  @override
  String get mapStyleMonochrome => 'أحادي اللون';

  @override
  String get mapStyleHybrid => 'هجين';

  @override
  String get mapStyleSatellite => 'قمر صناعي';

  @override
  String get mapTerrainHillshade => 'تظليل التضاريس';

  @override
  String get mapTerrain3d => 'تضاريس ثلاثية الأبعاد';

  @override
  String get mapContoursLow => 'منخفضة';

  @override
  String get mapContoursMedium => 'متوسطة';

  @override
  String get mapContoursHigh => 'عالية';

  @override
  String get mapTravelModesTransit => 'النقل العام';

  @override
  String get mapTravelModesTruck => 'الشاحنات';

  @override
  String get countryArgentina => 'الأرجنتين';

  @override
  String get countryCyprus => 'قبرص';

  @override
  String get countryEgypt => 'مصر';

  @override
  String get countryGeorgia => 'جورجيا';

  @override
  String get countryGreece => 'اليونان';

  @override
  String get countryIndia => 'الهند';

  @override
  String get countryKenya => 'كينيا';

  @override
  String get countryMorocco => 'المغرب';

  @override
  String get countryPalestine => 'فلسطين';

  @override
  String get countryRussia => 'روسيا';

  @override
  String get countrySudan => 'السودان';

  @override
  String get countrySerbia => 'صربيا';

  @override
  String get countrySuriname => 'سورينام';

  @override
  String get countrySyria => 'سوريا';

  @override
  String get countryTurkey => 'تركيا';

  @override
  String get countryTanzania => 'تنزانيا';

  @override
  String get countryUruguay => 'الأوروغواي';

  @override
  String get countryVietnam => 'فيتنام';

  @override
  String get settingsSectionConnection => 'الاتصال';

  @override
  String get settingsSaveKey => 'حفظ المفتاح';

  @override
  String get settingsRegion => 'المنطقة';

  @override
  String get settingsRegionHelper =>
      'يجب أن تكون المنطقة نفسها التي أُنشئ فيها مفتاح API';

  @override
  String get settingsTestConnection => 'اختبار الاتصال';

  @override
  String settingsTestSuccess(String answer) {
    return 'تم الاتصال بنجاح. استجابة Places API: $answer';
  }

  @override
  String get settingsSectionResults => 'النتائج';

  @override
  String get settingsResultsLanguage => 'لغة الأماكن والاتجاهات';

  @override
  String get settingsUnits => 'وحدات القياس';

  @override
  String get settingsSectionAppearance => 'المظهر';

  @override
  String get settingsThemeSystem => 'تلقائي';

  @override
  String get settingsResetDefaults => 'استعادة الإعدادات الافتراضية';

  @override
  String get settingsAboutApiKeysTitle => 'حول مفاتيح API';

  @override
  String get settingsAboutApiKeysBody =>
      'تتيح مفاتيح API في Amazon Location استخدام واجهات الخرائط والأماكن والمسارات. قيِّد المفتاح من وحدة تحكم AWS بالإجراءات التي تستخدمها فقط، وبالمواقع المُحيلة أو معرّفات الحزم الخاصة بتطبيقك. أما مجموعات السياجات الجغرافية وأجهزة التتبّع فتتطلّب بيانات اعتماد IAM أو Cognito.';

  @override
  String get commonMyLocation => 'موقعي';

  @override
  String get commonDetails => 'التفاصيل';

  @override
  String get commonResults => 'النتائج';

  @override
  String get commonPick => 'اختيار';

  @override
  String get commonAdd => 'إضافة';

  @override
  String mapExplorerCamera(String zoom, String center) {
    return 'التكبير $zoom · $center';
  }

  @override
  String get mapExplorerSearchHint => 'ابحث عن أماكن أو أنشطة تجارية أو عناوين';

  @override
  String get mapExplorerLookingUpAddress => 'جارٍ البحث عن العنوان…';

  @override
  String get mapExplorerNoAddress => 'لم يُعثر على عنوان';

  @override
  String get mapExplorerTapHint =>
      'اضغط على أي مكان لعرض عنوانه (الترميز الجغرافي العكسي)';

  @override
  String get mapStyleColorScheme => 'نظام الألوان';

  @override
  String get mapStylePoliticalViewHelper =>
      'الحدود والتسميات في المناطق المتنازع عليها';

  @override
  String get mapStyleNotForSatellite => 'غير متاح مع نمط القمر الصناعي';

  @override
  String get mapStyleTerrain => 'التضاريس';

  @override
  String get mapStyleTerrain3dHint =>
      'تظهر التضاريس ثلاثية الأبعاد على الويب؛ أمِل الخريطة بالسحب بزر الفأرة الأيمن أو بإصبعين.';

  @override
  String get mapStyleContours => 'خطوط الكنتور';

  @override
  String get mapStyleNotAvailable => 'غير متاح';

  @override
  String get mapStyleTraffic => 'حركة المرور المباشرة';

  @override
  String get mapStyleTravelModes => 'طبقة وسائل التنقّل';

  @override
  String get staticMapRender => 'إنشاء الصورة';

  @override
  String staticMapImageSize(String size) {
    return '$size كيلوبايت';
  }

  @override
  String get staticMapRequestUrl => 'رابط الطلب';

  @override
  String get staticMapEmpty => 'اضغط «إنشاء الصورة» لإنشاء صورة الخريطة.';

  @override
  String get staticMapFraming => 'تأطير الصورة';

  @override
  String get staticMapFramingCenterZoom => 'المركز والتكبير';

  @override
  String get staticMapFramingCenterRadius => 'المركز ونصف القطر';

  @override
  String get staticMapFramingFitMarkers => 'احتواء العلامات';

  @override
  String get staticMapCenter => 'المركز';

  @override
  String get staticMapPickCenter => 'مركز الخريطة';

  @override
  String staticMapZoom(String zoom) {
    return 'التكبير $zoom';
  }

  @override
  String staticMapRadius(String meters) {
    return 'نصف القطر $meters م';
  }

  @override
  String staticMapPadding(String pixels) {
    return 'الهامش $pixels بكسل';
  }

  @override
  String get staticMapImage => 'الصورة';

  @override
  String get staticMapSize => 'الحجم';

  @override
  String get staticMapHighDpi => 'دقة عالية (@2x)';

  @override
  String get staticMapStyle => 'النمط';

  @override
  String get staticMapLabelsSmall => 'تسميات صغيرة';

  @override
  String get staticMapLabelsLarge => 'تسميات كبيرة';

  @override
  String get staticMapLabelLanguage => 'لغة التسميات';

  @override
  String get staticMapLabelLanguageLocal => 'اللغة المحلية';

  @override
  String get staticMapPointsOfInterest => 'المعالم';

  @override
  String get staticMapCropLabels => 'قصّ التسميات عند الحواف';

  @override
  String get staticMapScaleBar => 'مقياس الرسم';

  @override
  String get staticMapScaleKilometers => 'كيلومترات';

  @override
  String get staticMapScaleMiles => 'أميال';

  @override
  String get staticMapScaleKilometersMiles => 'كم + أميال';

  @override
  String get staticMapScaleMilesKilometers => 'أميال + كم';

  @override
  String get staticMapMarkers => 'علامات طبقة GeoJSON';

  @override
  String get staticMapAddMarker => 'إضافة علامة';

  @override
  String get staticMapMarkersHint =>
      'تُرسم العلامات باستخدام المعامل geojson-overlay.';

  @override
  String staticMapMarkerFallback(int number) {
    return 'علامة $number';
  }

  @override
  String get staticMapConnectMarkers => 'صِل العلامات بخط';

  @override
  String get commonDistance => 'المسافة';

  @override
  String get commonLoadMore => 'تحميل المزيد';

  @override
  String get commonClear => 'مسح';

  @override
  String commonRadius(String distance) {
    return 'نصف القطر $distance';
  }

  @override
  String commonResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get placeActionNearby => 'الأماكن القريبة';

  @override
  String get placeActionReachableArea => 'نطاق الوصول';

  @override
  String get placeCopyCoordinates => 'نسخ الإحداثيات';

  @override
  String get placeCoordinatesCopied => 'تم نسخ الإحداثيات';

  @override
  String get placeAddress => 'العنوان';

  @override
  String get placeLocation => 'الموقع';

  @override
  String get placeCoordinates => 'الإحداثيات';

  @override
  String get placeTimeZone => 'المنطقة الزمنية';

  @override
  String get placeAccessPoints => 'نقاط الوصول';

  @override
  String get placeContact => 'التواصل';

  @override
  String get placePhone => 'الهاتف';

  @override
  String get placeWebsite => 'الموقع الإلكتروني';

  @override
  String get placeEmail => 'البريد الإلكتروني';

  @override
  String get placeFax => 'الفاكس';

  @override
  String get placeOpeningHours => 'ساعات العمل';

  @override
  String get placeOpenNow => 'مفتوح الآن';

  @override
  String get placeClosed => 'مغلق';

  @override
  String get placeBusinessChain => 'سلسلة تجارية';

  @override
  String get placeNoCoordinates => 'لا تتوفر إحداثيات لهذا المكان.';

  @override
  String get placeSearchHint => 'ابحث عن أماكن أو عناوين';

  @override
  String get placeSearchMoveMap => 'حرّك الخريطة للبحث في الجوار.';

  @override
  String get placeSearchNoMatches => 'لا توجد نتائج مطابقة';

  @override
  String get placeSearchQueryGeneric => 'البحث بهذه العبارة';

  @override
  String get placeSearchQueryCategory => 'البحث في هذه الفئة';

  @override
  String get placeSearchQueryBusinessChain => 'البحث عن هذه السلسلة التجارية';

  @override
  String placeSearchQueryOther(String type) {
    return 'بحث: $type';
  }

  @override
  String get placeTypePointOfInterest => 'معلم';

  @override
  String get placeTypePointAddress => 'عنوان دقيق';

  @override
  String get placeTypeInterpolatedAddress => 'عنوان تقديري';

  @override
  String get placeTypeSecondaryAddress => 'عنوان فرعي';

  @override
  String get placeTypeStreet => 'شارع';

  @override
  String get placeTypeIntersection => 'تقاطع';

  @override
  String get placeTypeBlock => 'مربع سكني';

  @override
  String get placeTypeSubBlock => 'مربع سكني فرعي';

  @override
  String get placeTypeDistrict => 'حي';

  @override
  String get placeTypeSubDistrict => 'حي فرعي';

  @override
  String get placeTypeLocality => 'مدينة';

  @override
  String get placeTypeSubRegion => 'إقليم فرعي';

  @override
  String get placeTypeRegion => 'إقليم';

  @override
  String get placeTypePostalCode => 'رمز بريدي';

  @override
  String get placeTypeCountry => 'دولة';

  @override
  String get placeTypePoint => 'نقطة';

  @override
  String get addressBuilding => 'المبنى';

  @override
  String get addressNumber => 'الرقم';

  @override
  String get addressStreet => 'الشارع';

  @override
  String get addressSubDistrict => 'الحي الفرعي';

  @override
  String get addressDistrict => 'الحي';

  @override
  String get addressLocality => 'المدينة';

  @override
  String get addressSubRegion => 'الإقليم الفرعي';

  @override
  String get addressRegion => 'الإقليم';

  @override
  String get addressPostalCode => 'الرمز البريدي';

  @override
  String get addressCountry => 'الدولة';

  @override
  String get nearbyTapHint => 'اضغط على الخريطة للبحث حول تلك النقطة';

  @override
  String get nearbyCategories => 'الفئات';

  @override
  String nearbyPlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكان',
      many: '$count مكانًا',
      few: '$count أماكن',
      two: 'مكانان',
      one: 'مكان واحد',
      zero: 'لا توجد أماكن',
    );
    return '$_temp0';
  }

  @override
  String get nearbyEmpty => 'لم يُعثر على شيء. جرّب نصف قطر أكبر.';

  @override
  String get nearbyCategoryRestaurants => 'مطاعم';

  @override
  String get nearbyCategoryCoffee => 'مقاهٍ';

  @override
  String get nearbyCategoryFastFood => 'وجبات سريعة';

  @override
  String get nearbyCategoryHotels => 'فنادق';

  @override
  String get nearbyCategoryGroceries => 'بقالة';

  @override
  String get nearbyCategoryMalls => 'مراكز تسوّق';

  @override
  String get nearbyCategoryPharmacies => 'صيدليات';

  @override
  String get nearbyCategoryHospitals => 'مستشفيات';

  @override
  String get nearbyCategoryAtms => 'صرّافات آلية';

  @override
  String get nearbyCategoryBanks => 'بنوك';

  @override
  String get nearbyCategoryFuel => 'محطات وقود';

  @override
  String get nearbyCategoryParking => 'مواقف سيارات';

  @override
  String get nearbyCategoryAttractions => 'معالم سياحية';

  @override
  String get nearbyCategoryMuseums => 'متاحف';

  @override
  String get nearbyCategoryParks => 'حدائق';

  @override
  String get nearbyCategoryGyms => 'صالات رياضية';

  @override
  String get nearbyCategoryMosques => 'مساجد';

  @override
  String get nearbyCategorySchools => 'مدارس';

  @override
  String get nearbyCategoryUniversities => 'جامعات';

  @override
  String get nearbyCategoryCinemas => 'دور سينما';

  @override
  String get nearbyCategoryPolice => 'الشرطة';

  @override
  String get nearbyCategoryTrains => 'محطات قطار';

  @override
  String get nearbyCategoryBuses => 'محطات حافلات';

  @override
  String get nearbyCategoryAirports => 'مطارات';

  @override
  String get searchBiasHint => 'تُعطى الأولوية للنتائج القريبة من مركز الخريطة';

  @override
  String get searchModeSearchText => 'بحث نصي';

  @override
  String get searchModeSuggest => 'اقتراحات';

  @override
  String get searchModeAutocomplete => 'إكمال تلقائي';

  @override
  String get searchModeSearchTextDescription =>
      'أنشطة تجارية ومعالم وعناوين، مقسّمة على صفحات';

  @override
  String get searchModeSuggestDescription =>
      'أماكن واقتراحات لتحسين البحث أثناء الكتابة';

  @override
  String get searchModeAutocompleteDescription =>
      'إكمال سريع للعناوين أثناء الكتابة';

  @override
  String get searchHint => 'مثال: بيتزا، ميدان التحرير، شارع 26 يوليو';

  @override
  String get searchCountryHint => 'تصفية حسب الدولة (رمز ISO-3، مثل EGY)';

  @override
  String get searchOnlyInCircle => 'داخل دائرة حول مركز الخريطة فقط';

  @override
  String searchCompletionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة إكمال',
      many: '$count نتيجة إكمال',
      few: '$count نتائج إكمال',
      two: 'نتيجتا إكمال',
      one: 'نتيجة إكمال واحدة',
      zero: 'لا توجد نتائج إكمال',
    );
    return '$_temp0';
  }

  @override
  String searchSuggestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اقتراح',
      many: '$count اقتراحًا',
      few: '$count اقتراحات',
      two: 'اقتراحان',
      one: 'اقتراح واحد',
      zero: 'لا توجد اقتراحات',
    );
    return '$_temp0';
  }

  @override
  String get searchQueryRefinement => 'اقتراح لتحسين البحث · اضغط للبحث';

  @override
  String searchNoResults(String query) {
    return 'لا توجد نتائج لـ«$query».';
  }

  @override
  String searchTypeQuery(String mode) {
    return 'اكتب عبارة للبحث باستخدام «$mode».';
  }

  @override
  String get pickerTitle => 'اختر موقعًا';

  @override
  String get pickerEmptyHint => 'اضغط على الخريطة أو ابحث عن مكان';

  @override
  String get pickerUse => 'استخدام';

  @override
  String get geocodeReverseTapHint => 'اضغط على الخريطة لمعرفة عنوان النقطة';

  @override
  String get geocodeModeText => 'نص حر';

  @override
  String get geocodeModeStructured => 'حقول منفصلة';

  @override
  String get geocodeModeReverse => 'عكسي';

  @override
  String get geocodeTextHint => 'مثال: 15 طلعت حرب، القاهرة';

  @override
  String get geocodeCountryField => 'الدولة (ISO-3)';

  @override
  String geocodeSearchRadius(String distance) {
    return 'نطاق البحث $distance';
  }

  @override
  String geocodeQueryPosition(String position) {
    return 'موضع الاستعلام: $position';
  }

  @override
  String geocodeMaxResults(int count) {
    return 'الحد الأقصى للنتائج: $count';
  }

  @override
  String get geocodePlaceTypes => 'أنواع الأماكن';

  @override
  String get geocodeAction => 'تحويل إلى إحداثيات';

  @override
  String get commonChange => 'تغيير';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonUndo => 'تراجع';

  @override
  String commonPointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة',
      many: '$count نقطة',
      few: '$count نقاط',
      two: 'نقطتان',
      one: 'نقطة واحدة',
      zero: 'لا توجد نقاط',
    );
    return '$_temp0';
  }

  @override
  String get travelModeCar => 'سيارة';

  @override
  String get travelModeWalk => 'مشي';

  @override
  String get travelModeScooter => 'سكوتر';

  @override
  String get travelModeTruck => 'شاحنة';

  @override
  String get routeFastest => 'الأسرع';

  @override
  String get routeShortest => 'الأقصر';

  @override
  String get truckTypeStraight => 'شاحنة صلبة';

  @override
  String get truckTypeTractor => 'شاحنة جرّ';

  @override
  String get truckTypeLight => 'شاحنة خفيفة';

  @override
  String get avoidTolls => 'طرق برسوم';

  @override
  String get avoidFerries => 'العبّارات';

  @override
  String get avoidHighways => 'الطرق السريعة';

  @override
  String get avoidTunnels => 'الأنفاق';

  @override
  String get avoidUTurns => 'الدوران للخلف';

  @override
  String get avoidDirtRoads => 'الطرق الترابية';

  @override
  String get avoidCarTrains => 'قطارات نقل السيارات';

  @override
  String get routeTapStart => 'اضغط على الخريطة لتحديد نقطة البداية';

  @override
  String get routeStart => 'البداية';

  @override
  String get routeStop => 'محطة';

  @override
  String get routeDestination => 'الوجهة';

  @override
  String get routeAddStop => 'إضافة محطة';

  @override
  String get routeAvoid => 'تجنّب';

  @override
  String get directionsTapDestination => 'اضغط على الخريطة لتحديد الوجهة';

  @override
  String get directionsChooseStart => 'اختر نقطة البداية';

  @override
  String get directionsChooseDestination => 'اختر الوجهة';

  @override
  String get directionsSwap => 'تبديل البداية والوجهة';

  @override
  String directionsRoutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسار',
      many: '$count مسارًا',
      few: '$count مسارات',
      two: 'مساران',
      one: 'مسار واحد',
      zero: 'لا توجد مسارات',
    );
    return '$_temp0';
  }

  @override
  String directionsTurnByTurn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الاتجاهات خطوة بخطوة · $count خطوة',
      many: 'الاتجاهات خطوة بخطوة · $count خطوة',
      few: 'الاتجاهات خطوة بخطوة · $count خطوات',
      two: 'الاتجاهات خطوة بخطوة · خطوتان',
      one: 'الاتجاهات خطوة بخطوة · خطوة واحدة',
      zero: 'الاتجاهات خطوة بخطوة · لا توجد خطوات',
    );
    return '$_temp0';
  }

  @override
  String get directionsRouteOptions => 'خيارات المسار';

  @override
  String directionsSummaryAvoid(int count) {
    return 'تجنّب $count';
  }

  @override
  String get directionsSummaryDepartNow => 'المغادرة الآن';

  @override
  String directionsSummaryDepartAt(String time) {
    return 'المغادرة $time';
  }

  @override
  String directionsAlternatives(int count) {
    return 'المسارات البديلة: $count';
  }

  @override
  String get directionsAlternativesUnavailable =>
      'المسارات البديلة (غير متاحة عند إضافة محطات)';

  @override
  String get directionsUseTraffic =>
      'استخدام بيانات حركة المرور المباشرة والسابقة';

  @override
  String get directionsDepartNow => 'المغادرة الآن';

  @override
  String directionsDepartAt(String time) {
    return 'المغادرة $time';
  }

  @override
  String get directionsNow => 'الآن';

  @override
  String get directionsBest => 'الأفضل';

  @override
  String directionsVia(String roads) {
    return 'عبر $roads';
  }

  @override
  String directionsLegsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرحلة',
      many: '$count مرحلة',
      few: '$count مراحل',
      two: 'مرحلتان',
      one: 'مرحلة واحدة',
      zero: 'لا توجد مراحل',
    );
    return '$_temp0';
  }

  @override
  String directionsTolls(String amount) {
    return 'رسوم الطرق $amount';
  }

  @override
  String get truckType => 'النوع';

  @override
  String truckGrossWeight(String value) {
    return 'الوزن الإجمالي $value طن';
  }

  @override
  String truckHeight(String value) {
    return 'الارتفاع $value م';
  }

  @override
  String truckWidth(String value) {
    return 'العرض $value م';
  }

  @override
  String truckLength(String value) {
    return 'الطول $value م';
  }

  @override
  String truckAxles(int count) {
    return 'عدد المحاور $count';
  }

  @override
  String isolinesSaved(String name) {
    return 'تم حفظ «$name» في السياجات الجغرافية';
  }

  @override
  String get isolinesTapHint => 'اضغط على الخريطة لتحديد نقطة الانطلاق';

  @override
  String get isolinesChooseStart => 'اختر نقطة الانطلاق';

  @override
  String get isolinesStartingPoint => 'نقطة الانطلاق';

  @override
  String get isolinesThreshold => 'الحدّ';

  @override
  String get isolinesTime => 'الوقت';

  @override
  String isolinesMaxThresholds(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'حتى $max حدّ',
      many: 'حتى $max حدًّا',
      few: 'حتى $max حدود',
      two: 'حتى حدّين',
      one: 'حدّ واحد فقط',
    );
    return '$_temp0';
  }

  @override
  String get isolinesUseTraffic => 'استخدام بيانات حركة المرور';

  @override
  String get isolinesReachableAreas => 'المناطق التي يمكن الوصول إليها';

  @override
  String isolinesWithin(String threshold) {
    return 'خلال $threshold';
  }

  @override
  String isolinesPolygonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مضلّع',
      many: '$count مضلّعًا',
      few: '$count مضلّعات',
      two: 'مضلّعان',
      one: 'مضلّع واحد',
      zero: 'لا توجد مضلّعات',
    );
    return '$_temp0';
  }

  @override
  String get isolinesSaveAsGeofence => 'حفظ كسياج جغرافي';

  @override
  String isolinesGeofenceName(String mode, String threshold) {
    return '$mode $threshold';
  }

  @override
  String get matrixTapOrigins => 'اضغط على الخريطة لإضافة نقاط انطلاق';

  @override
  String get matrixTapDestinations => 'اضغط على الخريطة لإضافة وجهات';

  @override
  String get matrixAddOrigins => 'إضافة نقاط انطلاق';

  @override
  String get matrixAddDestinations => 'إضافة وجهات';

  @override
  String matrixCalculate(int origins, int destinations) {
    return 'احسب $origins × $destinations';
  }

  @override
  String matrixErrorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطأ',
      many: '$count خطأً',
      few: '$count أخطاء',
      two: 'خطآن',
      one: 'خطأ واحد',
    );
    return '$_temp0';
  }

  @override
  String matrixOrigins(int count) {
    return 'نقاط الانطلاق ($count)';
  }

  @override
  String matrixDestinations(int count) {
    return 'الوجهات ($count)';
  }

  @override
  String get matrixAddOrigin => 'إضافة نقطة انطلاق';

  @override
  String get matrixAddDestination => 'إضافة وجهة';

  @override
  String get optimizeTapStops =>
      'اضغط على الخريطة لإضافة محطات (تشير الأرقام إلى ترتيب الزيارة)';

  @override
  String get optimizeReturnToStart => 'العودة إلى نقطة البداية';

  @override
  String get optimizeEndAnywhere => 'الانتهاء في أي مكان (اختياري)';

  @override
  String get optimizeEnd => 'النهاية';

  @override
  String get optimizeRoundTrip => 'رحلة ذهاب وعودة';

  @override
  String optimizeStops(int count) {
    return 'المحطات ($count)';
  }

  @override
  String optimizeStopName(int number) {
    return 'المحطة $number';
  }

  @override
  String get optimizeRun => 'تحسين الترتيب';

  @override
  String get optimizeResult => 'الترتيب الأمثل';

  @override
  String optimizeArrive(String time) {
    return 'الوصول $time';
  }

  @override
  String optimizeDepart(String time) {
    return 'المغادرة $time';
  }

  @override
  String optimizeCouldNotVisit(String stops) {
    return 'تعذّرت زيارة: $stops';
  }

  @override
  String get snapTapHint => 'اضغط على امتداد طريق لرسم مسار GPS تقريبي';

  @override
  String snapTracePointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة تتبّع',
      many: '$count نقطة تتبّع',
      few: '$count نقاط تتبّع',
      two: 'نقطتا تتبّع',
      one: 'نقطة تتبّع واحدة',
      zero: 'لا توجد نقاط تتبّع',
    );
    return '$_temp0';
  }

  @override
  String get snapGenerateNoisyTrace =>
      'إنشاء مسار تجريبي غير دقيق بين النقطتين الأولى والأخيرة';

  @override
  String snapRadius(String meters) {
    return 'نطاق المطابقة $meters م';
  }

  @override
  String get snapRun => 'مطابقة مع الطرق';

  @override
  String snapConfidence(String percent) {
    return 'نسبة الثقة $percent%';
  }

  @override
  String get snapSnappedPoints => 'النقاط المطابَقة';

  @override
  String snapMoved(String distance) {
    return 'أُزيحت $distance';
  }

  @override
  String geofencesDefaultName(String shape, int number) {
    return '$shape $number';
  }

  @override
  String get geofencesOpenTracker => 'فتح المتتبّع';

  @override
  String get geofencesTapTest => 'اضغط لاختبار ما إذا كانت النقطة داخل سياج';

  @override
  String get geofencesTapCircle => 'اضغط لتحديد مركز الدائرة';

  @override
  String get geofencesTapPolygon => 'اضغط لإضافة رؤوس المضلّع';

  @override
  String get geofencesInfo =>
      'تتطلّب مجموعات السياجات الجغرافية وأجهزة التتبّع في Amazon Location بيانات اعتماد IAM أو Cognito (مفاتيح API تغطي واجهات الخرائط والأماكن والمسارات فقط). تحفظ هذه الشاشة السياجات على الجهاز وتقيّم أحداث الدخول والخروج بالطريقة نفسها.';

  @override
  String get geofencesToolTest => 'اختبار';

  @override
  String get geofencesShapeCircle => 'دائرة';

  @override
  String get geofencesShapePolygon => 'مضلّع';

  @override
  String get geofencesOutsideAll => 'النقطة خارج جميع السياجات.';

  @override
  String geofencesInside(String names) {
    return 'داخل: $names';
  }

  @override
  String geofencesVerticesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رأس',
      many: '$count رأسًا',
      few: '$count رؤوس',
      two: 'رأسان',
      one: 'رأس واحد',
      zero: 'لا توجد رؤوس',
    );
    return '$_temp0';
  }

  @override
  String get geofencesName => 'الاسم';

  @override
  String get geofencesNameHint => 'مثال: المكتب، المستودع';

  @override
  String get geofencesSave => 'حفظ السياج';

  @override
  String get geofencesFromIsoline => 'إنشاء من نطاق وصول بالسيارة';

  @override
  String geofencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سياج جغرافي',
      many: '$count سياجًا جغرافيًا',
      few: '$count سياجات جغرافية',
      two: 'سياجان جغرافيان',
      one: 'سياج جغرافي واحد',
      zero: 'لا توجد سياجات جغرافية',
    );
    return '$_temp0';
  }

  @override
  String get geofencesDeleteAll => 'حذف الكل';

  @override
  String get geofencesEmpty =>
      'لا توجد سياجات جغرافية بعد. ارسم سياجًا على الخريطة.';

  @override
  String get trackerEventEnter => 'دخول';

  @override
  String get trackerEventExit => 'خروج';

  @override
  String get trackerTapStart => 'اضغط على الخريطة لتحديد بداية الرحلة';

  @override
  String get trackerTapEnd => 'اضغط على الخريطة لتحديد نهاية الرحلة';

  @override
  String get trackerReady =>
      'اضغط «بدء التتبّع»، أو اضغط على الخريطة لاختيار بداية جديدة';

  @override
  String get trackerFollow => 'تتبّع الجهاز';

  @override
  String get trackerSimulate => 'محاكاة';

  @override
  String get trackerDeviceGps => 'GPS الجهاز';

  @override
  String trackerPlaybackSpeed(int speed) {
    return 'سرعة التشغيل ×$speed';
  }

  @override
  String get trackerStop => 'إيقاف';

  @override
  String get trackerStart => 'بدء التتبّع';

  @override
  String get trackerSnapTrail => 'مطابقة المسار مع الطرق';

  @override
  String trackerFixesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قراءة',
      many: '$count قراءة',
      few: '$count قراءات',
      two: 'قراءتان',
      one: 'قراءة واحدة',
      zero: 'لا توجد قراءات',
    );
    return '$_temp0';
  }

  @override
  String get trackerLocatingAddress => 'جارٍ تحديد العنوان…';

  @override
  String trackerGeofences(int count) {
    return 'السياجات الجغرافية ($count)';
  }

  @override
  String trackerInsideCount(int count) {
    return 'داخل $count';
  }

  @override
  String get trackerNoGeofences =>
      'لا توجد سياجات محفوظة. أنشئ بعضها من شاشة السياجات الجغرافية لتظهر أحداث الدخول والخروج هنا.';

  @override
  String trackerEvents(int count) {
    return 'الأحداث ($count)';
  }

  @override
  String unitMeters(String value) {
    return '$value م';
  }

  @override
  String unitKilometers(String value) {
    return '$value كم';
  }

  @override
  String unitFeet(String value) {
    return '$value قدم';
  }

  @override
  String unitMiles(String value) {
    return '$value ميل';
  }

  @override
  String unitKmh(String value) {
    return '$value كم/س';
  }

  @override
  String unitMph(String value) {
    return '$value ميل/س';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ثانية',
      many: '$count ثانية',
      few: '$count ثوانٍ',
      two: 'ثانيتان',
      one: 'ثانية واحدة',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String unitHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ساعة',
      many: '$count ساعة',
      few: '$count ساعات',
      two: 'ساعتان',
      one: 'ساعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String unitHoursMinutes(String hours, String minutes) {
    return '$hours و$minutes';
  }

  @override
  String dateTimeShort(String date, String time) {
    return '$date، $time';
  }

  @override
  String commonRange(String from, String to) {
    return '$from إلى $to';
  }

  @override
  String errorCredentialsRejected(int status, String detail) {
    return 'رُفضت بيانات اعتماد AWS ‏($status): $detail تحقّق من أذونات دور مجمّع الهويات.';
  }

  @override
  String get errorTrackerConfigIncomplete =>
      'أدخل معرّف مجمّع الهويات واسم المتتبّع.';

  @override
  String get errorIdentityPoolIdInvalid =>
      'يجب أن يكون معرّف مجمّع الهويات بالشكل region:uuid.';

  @override
  String get errorTrackerNotConfigured => 'اتصل بالمتتبّع أولًا.';

  @override
  String get errorBackgroundTrackingUnsupported =>
      'التتبّع في الخلفية غير متاح على هذه المنصّة.';

  @override
  String errorCognitoSignInFailed(String detail) {
    return 'تعذّر تسجيل الدخول إلى Cognito: $detail';
  }

  @override
  String errorTrackingPlatform(String detail) {
    return 'خطأ في التتبّع: $detail';
  }

  @override
  String get errorCloudTrackerSettingsNotSaved => 'تعذّر حفظ إعدادات المتتبّع.';

  @override
  String get cloudTrackingTitle => 'التتبّع السحابي';

  @override
  String get homeCloudTrackingDescription =>
      'أرسل مواقع الجهاز إلى متتبّع Amazon Location عبر حِزم Amazon Location للأجهزة المحمولة، في المقدّمة أو في الخلفية.';

  @override
  String get cloudTrackingSetupTitle => 'المتتبّع';

  @override
  String get cloudTrackingIdentityPool => 'معرّف مجمّع هويات Cognito';

  @override
  String get cloudTrackingTrackerName => 'اسم المتتبّع';

  @override
  String get cloudTrackingSetupHelp =>
      'لا تقبل المتتبّعات مفاتيح API. تُوقَّع المواقع ببيانات اعتماد من مجمّع هويات Cognito يسمح دوره غير المصادَق عليه بالإجراءات geo:BatchUpdateDevicePosition وgeo:GetDevicePosition وgeo:GetDevicePositionHistory على المتتبّع.';

  @override
  String get cloudTrackingTimeFilter => 'مرشّح الوقت';

  @override
  String cloudTrackingTimeFilterValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'بفاصل $seconds ثانية على الأقل',
      many: 'بفاصل $seconds ثانية على الأقل',
      few: 'بفاصل $seconds ثوانٍ على الأقل',
      two: 'بفاصل ثانيتين على الأقل',
      one: 'بفاصل ثانية واحدة على الأقل',
    );
    return '$_temp0';
  }

  @override
  String get cloudTrackingDistanceFilter => 'مرشّح المسافة';

  @override
  String cloudTrackingDistanceFilterValue(String distance) {
    return 'بفاصل $distance على الأقل';
  }

  @override
  String get cloudTrackingAccuracyFilter => 'مرشّح الدقّة';

  @override
  String get cloudTrackingAccuracyFilterHint =>
      'تجاهل التحرّكات الأصغر من دقّة الموقع';

  @override
  String get cloudTrackingConnect => 'اتصال';

  @override
  String get cloudTrackingNotConnected => 'غير متصل';

  @override
  String cloudTrackingConnected(String deviceId) {
    return 'متصل · الجهاز $deviceId';
  }

  @override
  String get cloudTrackingStatusTracking => 'يرسل المواقع';

  @override
  String get cloudTrackingStatusBackground => 'يرسل المواقع في الخلفية';

  @override
  String get cloudTrackingBackground => 'التتبّع في الخلفية';

  @override
  String get cloudTrackingBackgroundActive => 'نشط';

  @override
  String get cloudTrackingBackgroundBatterySaver => 'توفير البطارية';

  @override
  String get cloudTrackingBackgroundStart => 'بدء في الخلفية';

  @override
  String get cloudTrackingBackgroundStop => 'إيقاف الخلفية';

  @override
  String get cloudTrackingBackgroundHelp =>
      'يعرض Android إشعارًا أثناء التشغيل، ويرفع وضع توفير البطارية المواقع كل 15 دقيقة تقريبًا. يحتاج iOS إلى إذن الموقع «دائمًا».';

  @override
  String get cloudTrackingBackgroundWeb =>
      'التتبّع في الخلفية غير متاح في المتصفح.';

  @override
  String get cloudTrackingReadBack => 'القراءة من المتتبّع';

  @override
  String get cloudTrackingLatest => 'آخر موقع';

  @override
  String get cloudTrackingHistory => 'آخر 24 ساعة';

  @override
  String cloudTrackingLatestValue(String time) {
    return 'خُزّن في $time';
  }

  @override
  String get cloudTrackingNoPosition =>
      'لا يملك المتتبّع موقعًا لهذا الجهاز بعد.';

  @override
  String cloudTrackingHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موقع في آخر 24 ساعة',
      many: '$count موقعًا في آخر 24 ساعة',
      few: '$count مواقع في آخر 24 ساعة',
      two: 'موقعان في آخر 24 ساعة',
      one: 'موقع واحد في آخر 24 ساعة',
      zero: 'لا مواقع في آخر 24 ساعة',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موقع مستلَم',
      many: '$count موقعًا مستلَمًا',
      few: '$count مواقع مستلَمة',
      two: 'موقعان مستلَمان',
      one: 'موقع مستلَم',
      zero: 'لا مواقع مستلَمة',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موقع مرفوع',
      many: '$count موقعًا مرفوعًا',
      few: '$count مواقع مرفوعة',
      two: 'موقعان مرفوعان',
      one: 'موقع مرفوع',
      zero: 'لا مواقع مرفوعة',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موقع مُستبعَد',
      many: '$count موقعًا مُستبعَدًا',
      few: '$count مواقع مُستبعَدة',
      two: 'موقعان مُستبعَدان',
      one: 'موقع مُستبعَد',
      zero: 'لا مواقع مُستبعَدة',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطأ',
      many: '$count خطأً',
      few: '$count أخطاء',
      two: 'خطآن',
      one: 'خطأ واحد',
      zero: 'لا أخطاء',
    );
    return '$_temp0';
  }

  @override
  String get cloudTrackingEventPosition => 'استُلم موقع';

  @override
  String cloudTrackingEventUploadStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جارٍ رفع $count موقع',
      many: 'جارٍ رفع $count موقعًا',
      few: 'جارٍ رفع $count مواقع',
      two: 'جارٍ رفع موقعين',
      one: 'جارٍ رفع موقع واحد',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingEventUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رُفع $count موقع',
      many: 'رُفع $count موقعًا',
      few: 'رُفعت $count مواقع',
      two: 'رُفع موقعان',
      one: 'رُفع موقع واحد',
    );
    return '$_temp0';
  }

  @override
  String get cloudTrackingEventSkipped => 'استُبعد بالمرشّح';

  @override
  String get cloudTrackingEventAvailable => 'الموقع متاح';

  @override
  String get cloudTrackingEventUnavailable => 'الموقع غير متاح';

  @override
  String get cloudTrackingEventBackgroundStopped => 'توقّف التتبّع في الخلفية';

  @override
  String cloudTrackingEventError(String message) {
    return 'خطأ: $message';
  }

  @override
  String get cloudTrackingLegendReceived => 'المستلَمة';

  @override
  String get cloudTrackingLegendUploaded => 'المرفوعة';

  @override
  String get cloudTrackingLegendHistory => 'السجلّ المخزَّن';
}
