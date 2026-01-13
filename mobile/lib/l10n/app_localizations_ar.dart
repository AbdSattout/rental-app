// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcome => 'مرحبا بك في Homio';

  @override
  String hello(String name) {
    return 'مرحبًا، $name!';
  }

  @override
  String get welcome_subtitle => 'اجد منزلك المثالي';

  @override
  String get get_started => 'ابدأ';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get bio => 'النبذة';

  @override
  String get idImage => 'صورة الهوية';

  @override
  String get profileImage => 'صورة الملف الشخصي';

  @override
  String get dateOfBirthFormat => 'تاريخ الميلاد (YYYY-MM-DD)';

  @override
  String get rent => 'استئجار';

  @override
  String get price => 'السعر';

  @override
  String get rooms => 'الغرف';

  @override
  String get bath => 'الحمامات';

  @override
  String get space => 'المساحة (م²)';

  @override
  String get type => 'النوع';

  @override
  String get location => 'الموقع';

  @override
  String get postDetails => 'تفاصيل الإعلان';

  @override
  String get details => 'التفاصيل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get hostProfile => 'ملف المضيف';

  @override
  String get settings => 'الإعدادات';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get typeHouse => 'منزل';

  @override
  String get typeApartment => 'شقة';

  @override
  String get typeVilla => 'فيلا';

  @override
  String get typeOffice => 'مكتب';

  @override
  String get appartments => 'الشقق';

  @override
  String get myApartments => 'شققي';

  @override
  String get noAppartments => 'لا يوجد شقق';

  @override
  String get publishApartment => 'نشر شقة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get becomeHost => 'أصبح مضيفا';

  @override
  String get approvalPending =>
      'حسابك قيد المراجعة. ستتمكن من استخدام الميزات الكاملة بعد الموافقة.';

  @override
  String get approvalRejected => 'تم رفض حسابك. يرجى التواصل مع الدعم.';

  @override
  String get role => 'نوع الحساب';

  @override
  String get guest => 'ضيف';

  @override
  String get tenant => 'مستأجر';

  @override
  String get host => 'مضيف';

  @override
  String get postHost => 'المضيف';

  @override
  String get requestingHost => 'يطلب الوصول إلى المضيف';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة محاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get invalidCredentials => 'رقم هاتف أو كلمة مرور غير صحيحة';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من الاتصال.';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get english => 'الإنجليزية (English)';

  @override
  String get arabic => 'العربية';

  @override
  String get guestMode => 'أنت تتصفح كضيف';

  @override
  String get account_under_review => 'حسابك قيد المراجعة';

  @override
  String get admin => 'المسؤول';

  @override
  String get selectAtLeastOnePhoto => 'يرجى اختيار صورة واحدة على الأقل';

  @override
  String get required => 'هذا الحقل مطلوب';

  @override
  String get notAHost => 'قم بالتسجيل كمضيف بالإعدادات لتستطيع نشر شقق';

  @override
  String get nothingHere => 'لا يوجد نتائج';

  @override
  String get myFavorites => 'المفضلة';

  @override
  String get noFavorites => 'لا يوجد مفضلة';

  @override
  String get featured => 'الصور المميزة';

  @override
  String get gallery => 'معرض الصور';

  @override
  String get createApartment => 'إنشاء شقة';

  @override
  String get editApartment => 'تعديل الشقة';

  @override
  String get deleteApartment => 'حذف الشقة';

  @override
  String get confirmDeleteApartment => 'هل أنت متأكد من حذف هذه الشقة؟';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get close => 'إغلاق';

  @override
  String get ok => 'حسنا';

  @override
  String get clear => 'مسح';

  @override
  String get map => 'الخريطة';

  @override
  String get contact => 'تواصل';

  @override
  String get deletePost => 'حذف الشقة';

  @override
  String get areYouSureDeletePost => 'هل أنت متأكد من حذف هذه الشقة؟';

  @override
  String get createANewAccount => 'إنشاء حساب جديد';

  @override
  String get already_have_account => 'هل لديك حساب بالفعل؟';

  @override
  String get dont_have_account => 'ليس لديك حساب؟';

  @override
  String get sign_up_here => 'قم بالتسجيل هنا';

  @override
  String get sign_in_here => 'قم بتسجيل الدخول هنا';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkYourRequest => 'تأكد من المعلومات المدخلة';

  @override
  String get anErrorOccurred => 'حدث خطأ، يرجى المحاولة مرة أخرى';

  @override
  String get signInToYourAccount => 'سجل الدخول إلى حسابك';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get phoneMinDigits => 'يجب أن يكون رقم الهاتف 10 أرقام على الأقل';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinCharacters =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get minPasswordCharacters => 'الحد الأدنى 8 أحرف';

  @override
  String get uploadRequiredImages => 'يرجى تحميل جميع الصور المطلوبة';

  @override
  String get invalidPhone => 'رقم هاتف غير صحيح';

  @override
  String get upload => 'تحميل';

  @override
  String get imageTooLarge => 'الصورة كبيرة جدًا';

  @override
  String get invalidImageType => 'نوع الصورة غير صالح';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get openStreetMapContributors => 'OpenStreetMap المساهمون';

  @override
  String get welcome_title => 'مرحبا بك في Homio!';

  @override
  String get welcome_description => 'هل تبحث عن منزل جميل\nللاستئجار؟';

  @override
  String get find_home_title => 'ابحث عن منزلك';

  @override
  String get find_home_description =>
      'يجعل تطبيقنا من السهل العثور على\nالمكان المثالي الذي يناسب\nاحتياجاتك ونمط حياتك';

  @override
  String get start_journey_title => 'ابدأ رحلة منزلك';

  @override
  String get start_journey_description =>
      'هل أنت مستعد للانتقال إلى مكانك\nالمثالي؟ لنبدأ';

  @override
  String get rating => 'التقييم';

  @override
  String get ratings => 'تقييمات';

  @override
  String get ratingSubmitted => 'تم إرسال التقييم';

  @override
  String get cannotRate => 'لا يمكنك التقييم قبل حجز الشقة';

  @override
  String get reservations => 'الحجوزات';

  @override
  String get myReservations => 'حجوزاتي';

  @override
  String get checkIn => 'بداية الحجز';

  @override
  String get checkOut => 'انتهاء الحجز';

  @override
  String get reserve => 'حجز';

  @override
  String get reservationSuccess => 'تم إنشاء الحجز بنجاح';

  @override
  String get reservationConflict => 'التواريخ المحددة محجوزة بالفعل';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get accepted => 'مقبول';

  @override
  String get rejected => 'مرفوض';

  @override
  String get canceled => 'ملغى';

  @override
  String get completed => 'مكتمل';

  @override
  String get noReservations => 'لا توجد حجوزات بعد';

  @override
  String get reservationsSection => 'الحجوزات';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get editReservation => 'تعديل الحجز';

  @override
  String get confirmCancelReservation => 'هل أنت متأكد من إلغاء هذا الحجز؟';

  @override
  String get reservationUpdated => 'تم تحديث الحجز بنجاح';

  @override
  String get reservationCanceled => 'تم إلغاء الحجز بنجاح';

  @override
  String get update => 'تحديث';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get to => 'إلى';

  @override
  String get manageReservations => 'إدارة الحجوزات';

  @override
  String get pendingRequests => 'طلبات معلقة';

  @override
  String get updateRequests => 'طلبات تحديث';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get noUpdateRequests => 'لا توجد طلبات تحديث';

  @override
  String get reservationApproved => 'تم قبول الحجز';

  @override
  String get reservationRejected => 'تم رفض الحجز';

  @override
  String get updateApproved => 'تم قبول التحديث';

  @override
  String get updateRejected => 'تم رفض التحديث';

  @override
  String get confirmApprove => 'هل تريد قبول هذا الحجز؟';

  @override
  String get confirmReject => 'هل تريد رفض هذا الحجز؟';

  @override
  String get confirmApproveUpdate => 'هل تريد قبول طلب التحديث؟';

  @override
  String get confirmRejectUpdate => 'هل تريد رفض طلب التحديث؟';

  @override
  String get showAll => 'عرض الكل';

  @override
  String get nearYou => 'قريبًا منك';

  @override
  String get latestPosts => 'آخر المنشورات';

  @override
  String get perDay => 'لليوم الواحد';

  @override
  String get notSet => 'غير محدد';

  @override
  String get messages => 'الرسائل';

  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get conversations => 'المحادثات';

  @override
  String get noConversations => 'لا توجد محادثات بعد';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get sendMessage => 'إرسال';

  @override
  String get messageFailed => 'فشل إرسال الرسالة';

  @override
  String get retryMessage => 'إعادة المحاولة';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get startConversation => 'ابدأ محادثة';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get guestModeChat => 'قم بتسجيل الدخول لبدء المحادثات';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get you => 'أنت';
}
