class AppImages {
  // Private constructor to prevent instantiation
  AppImages._();

  // Base path for images
  static const String _imagePath = 'assets/images/';

  // SVG Images
  static const String apple = '${_imagePath}apple.svg';
  static const String car = '${_imagePath}car.svg';
  static const String drIcon = '${_imagePath}drIcon.svg';
  static const String food = '${_imagePath}food.svg';
  static const String foodWhite = '${_imagePath}food_white.svg';
  static const String google = '${_imagePath}google.svg';
  static const String location = '${_imagePath}location.svg';
  static const String logo = '${_imagePath}logo.svg';
  static const String redCar = '${_imagePath}red_car.svg';
  static const String safety = '${_imagePath}safety.svg';
   static const String search = '${_imagePath}search.svg';
  static const String welcome = '${_imagePath}welcome.svg';
  static const String xIcon = '${_imagePath}xIcon.svg';
  static const String yellowLocation = '${_imagePath}yellow_location.svg';

  // Additional SVG Images
  static const String bmwTest = '${_imagePath}bmw_test.svg';
  static const String star = '${_imagePath}star.svg';
  static const String megoStyleImage = '${_imagePath}z.svg';

  // PNG Images (keeping only those without SVG versions)
  static const String blurLogo = '${_imagePath}blurLogo.png';
  static const String carInRide = '${_imagePath}car_in_ride.png';
  static const String italicBg = '${_imagePath}italic_bg.png';
  static const String locationIcon = '${_imagePath}LocationIcon.png';
  static const String phone = '${_imagePath}phone.svg';
  // GIF Images
  static const String loading = '${_imagePath}loading.gif';
  static const String loginVector = 'assets/images/login_vector.svg';
  static const String ItIsMegoImage = 'assets/images/itMego.svg';
  static const String megoPatternImage = 'assets/images/pattern.svg';

  static const String historyIcon = 'assets/images/history.svg';
  static const String logoutIcon = 'assets/images/logout.svg';
  static const String settingsIcon = 'assets/images/settings.svg';
  static const String walletIcon = 'assets/images/wallet.svg';
  static const String aboutIcon = 'assets/images/about.svg';
  static const String couponsIcon = 'assets/images/coupons.svg';
  static const String customerSupportIcon = 'assets/images/customer_support.svg';
  static const String splashVideo = 'assets/images/v1.mp4';
      //'assets/images/splash_video.mp4';
  static const String nameIcon = 'assets/images/name.svg';
  static const String emailIcon = 'assets/images/mail.svg';


  // Legacy compatibility (deprecated - use specific SVG versions above)
  // @Deprecated('Use AppImages.logo instead')
  // static const String megoStyleImage = italicBg;
}