// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get title => 'Homie';

  @override
  String get welcome => 'مرحبا بك في Homio';

  @override
  String hello(String name) {
    return 'مرحبًا، $name!';
  }

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
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get idImage => 'صورة الهوية';

  @override
  String get profileImage => 'صورة الملف الشخصي';

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
  String get profileInfo => 'معلومات الملف الشخصي';

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
  String get filterResults => 'نتائج التصفية';

  @override
  String get minPrice => 'الحد الأدنى للسعر';

  @override
  String get maxPrice => 'الحد الأقصى للسعر';

  @override
  String get minRooms => 'الحد الأدنى للغرف';

  @override
  String get maxRooms => 'الحد الأقصى للغرف';

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
  String get success => 'نجح';

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
  String get close => 'إغلاق';

  @override
  String get ok => 'حسنا';

  @override
  String get pleaseLoginFirst => 'يرجى تسجيل الدخول أولا للوصول إلى هذه الميزة';

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
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemMode => 'اتبع النظام';

  @override
  String get english => 'الإنجليزية (English)';

  @override
  String get arabic => 'العربية';

  @override
  String get systemDefault => 'الافتراضي';

  @override
  String get changeTheme => 'تغيير المظهر';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get myReservations => 'حجوزاتي';

  @override
  String get currentReservations => 'الحالية';

  @override
  String get pastReservations => 'السابقة';

  @override
  String get canceledReservations => 'الملغاة';

  @override
  String get checkIn => 'تسجيل الدخول';

  @override
  String get checkOut => 'تسجيل الخروج';

  @override
  String get reserve => 'احجز';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get uploadPhotos => 'تحميل الصور (الحد الأدنى 1، الحد الأقصى 5)';

  @override
  String get chooseLocation => 'اختر الموقع على الخريطة';

  @override
  String get guestMode => 'أنت تتصفح كضيف';

  @override
  String get signInToRent => 'قم بتسجيل الدخول لتأجير هذه العقار';

  @override
  String get accountNotApproved =>
      'حسابك غير معتمد حاليا. يرجى الانتظار للتحقق من الإدارة.';

  @override
  String get hostingRequests => 'طلبات الاستضافة';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get createApartment => 'إنشاء شقة';

  @override
  String get editApartment => 'تعديل الشقة';

  @override
  String get deleteApartment => 'حذف الشقة';

  @override
  String get confirmDelete => 'هل أنت متأكد من حذف هذا؟';

  @override
  String get confirmDeleteApartment => 'هل أنت متأكد من حذف هذه الشقة؟';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get welcome_subtitle => 'اجد منزلك المثالي';

  @override
  String get get_started => 'ابدأ';

  @override
  String get already_have_account => 'هل لديك حساب بالفعل؟';

  @override
  String get dont_have_account => 'ليس لديك حساب؟';

  @override
  String get sign_up_here => 'قم بالتسجيل هنا';

  @override
  String get sign_in_here => 'قم بتسجيل الدخول هنا';

  @override
  String get account_under_review => 'حسابك قيد المراجعة';

  @override
  String get admin => 'المسؤول';

  @override
  String get properties => 'العقارات';

  @override
  String get reservations => 'الحجوزات';

  @override
  String get users => 'المستخدمون';

  @override
  String get hostRequests => 'طلبات المضيف';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get ban => 'حظر';

  @override
  String get pendingUsers => 'المستخدمون المعلقون';

  @override
  String get approvedUsers => 'المستخدمون المعتمدون';

  @override
  String get rejectedUsers => 'المستخدمون المرفوضون';

  @override
  String get bannedUsers => 'المستخدمون المحظورون';

  @override
  String get pendingHostRequests => 'طلبات المضيف المعلقة';

  @override
  String get approvedHostRequests => 'طلبات المضيف المعتمدة';

  @override
  String get rejectedHostRequests => 'طلبات المضيف المرفوضة';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get orderManagement => 'إدارة الطلبات';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get hostRequestManagement => 'إدارة طلبات المضيف';

  @override
  String get photos => 'الصور';

  @override
  String get selectAtLeastOnePhoto => 'يرجى اختيار صورة واحدة على الأقل';

  @override
  String get required => 'مطلوب';

  @override
  String get notAHost => 'قم بالتسجيل كمضيف بالإعدادات لتستطيع نشر شقق';

  @override
  String get nothingHere => 'لا يوجد نتائج';

  @override
  String get oops => 'أوبس!';

  @override
  String get clear => 'مسح';

  @override
  String get map => 'الخريطة';

  @override
  String get contact => 'تواصل';

  @override
  String get deletePost => 'حذف الشقة';

  @override
  String get areYouSureDeletePost => 'هل أنت متأكد من حذف هذا الشقة؟';

  @override
  String get createANewAccount => 'إنشاء حساب جديد';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkYourRequest => 'تأكد من المعلومات المدخلة';
}
