class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://app.sarxhardware.com';

  // API Endpoints
  static const String loginEndpoint = '/api/dealer/login';
  static const String logoutEndpoint = '/api/dealer/logout';
  static const String qrCodesEndpoint = '/api/dealer/qr-codes';
  /// Partner claims reward on same product QR after customer has activated warranty.
  /// POST body: `{ "qr_token": "<scanned token>" }` — Bearer required.
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
  static const String catalogsEndpoint = '/api/catalogs_data';
  static const String partnerOffersEndpoint = '/api/partner-offers';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String dealerDataKey = 'dealer_data';
  static const String userTypeKey = 'user_type';

  // App Info
  static const String appName = 'Sarx Hardware';
}
