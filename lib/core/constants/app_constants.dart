class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://crm.teerthsewanyascrm.xyz';

  // API Endpoints
  static const String loginEndpoint = '/api/dealer/login';
  static const String logoutEndpoint = '/api/dealer/logout';
  static const String qrCodesEndpoint = '/api/dealer/qr-codes';
  static const String scanQrEndpoint = '/api/dealer/scan-qr';
  static const String walletEndpoint = '/api/dealer/wallet';
  static const String walletHistoryEndpoint = '/api/dealer/wallet/history';
  static const String withdrawalRequestEndpoint =
      '/api/dealer/withdrawal/request';
  static const String withdrawalHistoryEndpoint =
      '/api/dealer/withdrawal/history';
  static const String profileEndpoint = '/api/dealer/profile';
  static const String profileUpdateEndpoint = '/api/dealer/profile/update';
  static const String productsEndpoint = '/api/dealer/products';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String dealerDataKey = 'dealer_data';
  static const String userTypeKey = 'user_type';

  // App Info
  static const String appName = 'Parx Hardware';
}
