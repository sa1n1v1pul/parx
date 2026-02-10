import 'product_model.dart';

class QrCodeModel {
  final int id;
  final String qrToken;
  final String serialNumber;
  final String status;
  final String? warrantyActivatedAt;
  final String? rewardClaimedAt;
  final ProductModel? product;
  final SaleModel? sale;

  QrCodeModel({
    required this.id,
    required this.qrToken,
    required this.serialNumber,
    required this.status,
    this.warrantyActivatedAt,
    this.rewardClaimedAt,
    this.product,
    this.sale,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'] ?? 0,
      qrToken: json['qr_token'] ?? '',
      serialNumber: json['serial_number'] ?? '',
      status: json['status'] ?? '',
      warrantyActivatedAt: json['warranty_activated_at'],
      rewardClaimedAt: json['reward_claimed_at'],
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
      sale: json['sale'] != null ? SaleModel.fromJson(json['sale']) : null,
    );
  }
}

class SaleModel {
  final String customerName;
  final String customerMobile;
  final String saleDate;

  SaleModel({
    required this.customerName,
    required this.customerMobile,
    required this.saleDate,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      customerName: json['customer_name'] ?? '',
      customerMobile: json['customer_mobile'] ?? '',
      saleDate: json['sale_date'] ?? '',
    );
  }
}
