class PartnerOfferModel {
  final int id;
  final String planType;
  final int points;
  final String note;
  final OfferProductModel? product;
  final String createdAt;

  PartnerOfferModel({
    required this.id,
    required this.planType,
    required this.points,
    required this.note,
    required this.product,
    required this.createdAt,
  });

  factory PartnerOfferModel.fromJson(Map<String, dynamic> json) {
    return PartnerOfferModel(
      id: json['id'] ?? 0,
      planType: (json['plan_type'] ?? '').toString(),
      points: json['points'] ?? 0,
      note: (json['note'] ?? '').toString(),
      product: json['product'] is Map<String, dynamic>
          ? OfferProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

class OfferProductModel {
  final int id;
  final String name;
  final String price;

  OfferProductModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory OfferProductModel.fromJson(Map<String, dynamic> json) {
    return OfferProductModel(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      price: (json['price'] ?? '0').toString(),
    );
  }
}
