// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ftarna';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get phone => 'Phone Number';

  @override
  String get loginWithEmail => 'Login with Email';

  @override
  String get loginWithPhone => 'Login with Phone';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidPassword => 'Password must be at least 6 characters';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get menu => 'Menu';

  @override
  String get myOrder => 'My Order';

  @override
  String get admin => 'Admin Panel';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get sessionOpen => 'Session is Open';

  @override
  String get sessionClosed => 'Session is Closed';

  @override
  String get sessionDelivered => 'Session Delivered';

  @override
  String get openSession => 'Open Session';

  @override
  String get closeSession => 'Close Session';

  @override
  String get markDelivered => 'Mark as Delivered';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get totalBill => 'Total Bill';

  @override
  String get enterDeliveryFee => 'Enter delivery fee';

  @override
  String get enterTotalBill => 'Enter total bill';

  @override
  String get addItem => 'Add Item';

  @override
  String get editItem => 'Edit Item';

  @override
  String get archiveItem => 'Archive Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get itemPrice => 'Price';

  @override
  String get itemActive => 'Active';

  @override
  String get itemArchived => 'Archived';

  @override
  String get saveItem => 'Save Item';

  @override
  String get menuManagement => 'Menu Management';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get submitOrder => 'Submit Order';

  @override
  String get orderSubmitted => 'Order submitted successfully!';

  @override
  String get orderFailed => 'Failed to submit order';

  @override
  String get noItemsSelected => 'Please select at least one item';

  @override
  String get repeatLastOrder => 'Repeat Last Order';

  @override
  String get noLastOrder => 'No previous order found';

  @override
  String get orderHistory => 'Order History';

  @override
  String get quantity => 'Quantity';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get yourShare => 'Your Share';

  @override
  String get orders => 'Orders';

  @override
  String get allOrders => 'All Orders';

  @override
  String get aggregatedItems => 'Aggregated Items';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get paid => 'Paid';

  @override
  String get notPaid => 'Not Paid';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get confirmCancel => 'Are you sure you want to cancel this order?';

  @override
  String get confirmPaid => 'Mark this order as paid?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get egp => 'EGP';

  @override
  String currency(double amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString EGP';
  }

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noMenuItems => 'No menu items available';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get success => 'Success';

  @override
  String get orderAlreadySubmitted => 'You have already submitted an order';

  @override
  String get sessionClosedCannotOrder =>
      'Session is closed, you cannot place orders';

  @override
  String get notificationSessionOpened =>
      'Breakfast is available, place your order now!';

  @override
  String get notificationSessionClosed => 'Orders are now closed';

  @override
  String notificationPaymentDue(double amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'You need to pay $amountString EGP';
  }

  @override
  String get notificationReminder => 'You haven\'t ordered yet';

  @override
  String get notificationOrderCancelled => 'Your order has been cancelled';

  @override
  String get users => 'Users';

  @override
  String get user => 'User';

  @override
  String get items => 'Items';

  @override
  String get item => 'Item';

  @override
  String get price => 'Price';

  @override
  String get qty => 'Qty';

  @override
  String totalItems(int count) {
    return 'Total: $count items';
  }

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get orderNow => 'Order Now';

  @override
  String get viewMenu => 'View Menu';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get addToOrder => 'Add to Order';

  @override
  String get searchMenu => 'Search menu...';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort by';

  @override
  String get name => 'Name';

  @override
  String get priceAsc => 'Price: Low to High';

  @override
  String get priceDesc => 'Price: High to Low';

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
