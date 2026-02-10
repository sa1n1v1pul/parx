class WalletModel {
  final String balance;
  final String totalEarned;
  final double totalWithdrawn;

  WalletModel({
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // Handle totalWithdrawn - can be String or int/double
    double parseTotalWithdrawn(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return WalletModel(
      balance: json['balance']?.toString() ?? '0.00',
      totalEarned: json['total_earned']?.toString() ?? '0.00',
      totalWithdrawn: parseTotalWithdrawn(json['total_withdrawn']),
    );
  }
}

class WalletHistoryModel {
  final int id;
  final int dealerId;
  final String type;
  final String amount;
  final String description;
  final int? qrCodeId;
  final String createdAt;
  final String updatedAt;

  WalletHistoryModel({
    required this.id,
    required this.dealerId,
    required this.type,
    required this.amount,
    required this.description,
    this.qrCodeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      id: json['id'] ?? 0,
      dealerId: json['dealer_id'] ?? 0,
      type: json['type'] ?? '',
      amount: json['amount'] ?? '0.00',
      description: json['description'] ?? '',
      qrCodeId: json['qr_code_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

