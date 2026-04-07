// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'فطارنا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get loginWithEmail => 'تسجيل الدخول بالبريد';

  @override
  String get loginWithPhone => 'تسجيل الدخول بالهاتف';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get enterPhone => 'أدخل رقم هاتفك';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get invalidPassword => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get registerSuccess => 'تم إنشاء الحساب بنجاح';

  @override
  String get registerFailed => 'فشل إنشاء الحساب';

  @override
  String get menu => 'القائمة';

  @override
  String get myOrder => 'طلبي';

  @override
  String get admin => 'لوحة التحكم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get breakfast => 'الفطار';

  @override
  String get sessionOpen => 'الجلسة مفتوحة';

  @override
  String get sessionClosed => 'الجلسة مغلقة';

  @override
  String get sessionDelivered => 'تم التوصيل';

  @override
  String get openSession => 'فتح الجلسة';

  @override
  String get closeSession => 'إغلاق الجلسة';

  @override
  String get markDelivered => 'تحديد كمُوصَّل';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get totalBill => 'إجمالي الفاتورة';

  @override
  String get enterDeliveryFee => 'أدخل رسوم التوصيل';

  @override
  String get enterTotalBill => 'أدخل إجمالي الفاتورة';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String get editItem => 'تعديل صنف';

  @override
  String get archiveItem => 'أرشفة صنف';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get itemPrice => 'السعر';

  @override
  String get itemActive => 'نشط';

  @override
  String get itemArchived => 'مؤرشف';

  @override
  String get saveItem => 'حفظ الصنف';

  @override
  String get menuManagement => 'إدارة القائمة';

  @override
  String get placeOrder => 'اطلب الآن';

  @override
  String get submitOrder => 'إرسال الطلب';

  @override
  String get orderSubmitted => 'تم إرسال الطلب بنجاح!';

  @override
  String get orderFailed => 'فشل إرسال الطلب';

  @override
  String get noItemsSelected => 'يرجى اختيار صنف واحد على الأقل';

  @override
  String get repeatLastOrder => 'تكرار الطلب السابق';

  @override
  String get noLastOrder => 'لا يوجد طلب سابق';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get quantity => 'الكمية';

  @override
  String get total => 'الإجمالي';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get yourShare => 'حصتك';

  @override
  String get orders => 'الطلبات';

  @override
  String get allOrders => 'كل الطلبات';

  @override
  String get aggregatedItems => 'ملخص الأصناف';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get markAsPaid => 'تحديد كمدفوع';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get paid => 'مدفوع';

  @override
  String get notPaid => 'غير مدفوع';

  @override
  String get cancelled => 'ملغي';

  @override
  String get confirmCancel => 'هل أنت متأكد من إلغاء هذا الطلب؟';

  @override
  String get confirmPaid => 'تحديد هذا الطلب كمدفوع؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get egp => 'جنيه';

  @override
  String currency(double amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString جنيه';
  }

  @override
  String get noOrders => 'لا توجد طلبات بعد';

  @override
  String get noMenuItems => 'لا توجد أصناف متاحة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'حدث خطأ ما';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get success => 'تم بنجاح';

  @override
  String get orderAlreadySubmitted => 'لقد أرسلت طلبك بالفعل';

  @override
  String get sessionClosedCannotOrder => 'الجلسة مغلقة، لا يمكنك الطلب الآن';

  @override
  String get notificationSessionOpened => 'الفطار متاح الآن، اطلب الآن!';

  @override
  String get notificationSessionClosed => 'تم إغلاق الطلبات الآن';

  @override
  String notificationPaymentDue(double amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'عليك دفع $amountString جنيه';
  }

  @override
  String get notificationReminder => 'لم تطلب بعد';

  @override
  String get notificationOrderCancelled => 'تم إلغاء طلبك';

  @override
  String get users => 'المستخدمين';

  @override
  String get user => 'مستخدم';

  @override
  String get items => 'الأصناف';

  @override
  String get item => 'صنف';

  @override
  String get price => 'السعر';

  @override
  String get qty => 'الكمية';

  @override
  String totalItems(int count) {
    return 'الإجمالي: $count صنف';
  }

  @override
  String get welcome => 'مرحباً';

  @override
  String get welcomeBack => 'مرحباً بعودتك!';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get orderNow => 'اطلب الآن';

  @override
  String get viewMenu => 'عرض القائمة';

  @override
  String get emptyCart => 'السلة فارغة';

  @override
  String get addToOrder => 'أضف للطلب';

  @override
  String get searchMenu => 'ابحث في القائمة...';

  @override
  String get filter => 'تصفية';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get name => 'الاسم';

  @override
  String get priceAsc => 'السعر: من الأقل للأعلى';

  @override
  String get priceDesc => 'السعر: من الأعلى للأقل';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get nearbyRestaurants => 'Nearby Restaurants';

  @override
  String get allRestaurants => 'All Restaurants';

  @override
  String get searchRestaurants => 'Search restaurants...';

  @override
  String get noRestaurantsFound => 'No restaurants found';

  @override
  String get cuisineType => 'Cuisine Type';

  @override
  String get rating => 'Rating';

  @override
  String get reviews => 'Reviews';

  @override
  String get deliveryTime => 'Delivery Time';

  @override
  String get minOrder => 'Min. Order';

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get verified => 'Verified';

  @override
  String get branches => 'Branches';

  @override
  String get selectBranch => 'Select Branch';

  @override
  String get nearestBranch => 'Nearest Branch';

  @override
  String get categories => 'Categories';

  @override
  String get products => 'Products';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get viewCart => 'View Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get placeOrderBtn => 'Place Order';

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String get orderConfirmed => 'Order Confirmed';

  @override
  String get orderPreparing => 'Preparing Your Order';

  @override
  String get orderReady => 'Order Ready';

  @override
  String get orderOutForDelivery => 'Out for Delivery';

  @override
  String get orderDelivered => 'Order Delivered';

  @override
  String get trackOrder => 'Track Order';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get addAddress => 'Add Address';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get building => 'Building';

  @override
  String get floor => 'Floor';

  @override
  String get apartment => 'Apartment';

  @override
  String get deliveryInstructions => 'Delivery Instructions';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get cardPayment => 'Card Payment';

  @override
  String get payWhenReceive => 'Pay when you receive your order';

  @override
  String get discountCode => 'Discount Code';

  @override
  String get applyCode => 'Apply Code';

  @override
  String get codeApplied => 'Code Applied';

  @override
  String get invalidCode => 'Invalid Code';

  @override
  String get removeCode => 'Remove Code';

  @override
  String get discount => 'Discount';

  @override
  String get specialInstructions => 'Special Instructions';

  @override
  String get anySpecialRequests => 'Any special requests?';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get arrivingSoon => 'Arriving Soon!';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get manageRestaurants => 'Manage Restaurants';

  @override
  String get manageBranches => 'Manage Branches';

  @override
  String get manageMenu => 'Manage Menu';

  @override
  String get manageOrders => 'Manage Orders';

  @override
  String get orderManagement => 'Order Management';

  @override
  String get newOrders => 'New Orders';

  @override
  String get preparingOrders => 'Preparing';

  @override
  String get readyOrders => 'Ready';

  @override
  String get completedOrders => 'Completed';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markReady => 'Mark Ready';

  @override
  String get outForDelivery => 'Out for Delivery';

  @override
  String get markDeliveredBtn => 'Mark Delivered';

  @override
  String get uploadMenu => 'Upload Menu';

  @override
  String get ocrExtract => 'Extract from Image';

  @override
  String get scanMenu => 'Scan Menu';

  @override
  String get extractingData => 'Extracting data...';

  @override
  String get reviewExtractedData => 'Review Extracted Data';

  @override
  String get importProducts => 'Import Products';

  @override
  String get favorites => 'Favorites';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get offers => 'Offers';

  @override
  String get specialOffers => 'Special Offers';

  @override
  String get limitedTimeOffer => 'Limited Time Offer';

  @override
  String get viewOffer => 'View Offer';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get rateYourExperience => 'Rate your experience';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get thankYouReview => 'Thank you for your review!';
}
