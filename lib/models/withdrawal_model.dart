class WithdrawalRequestModel {
  final int id;
  final String requestedAmount;
  final String status;
  final String requestDate;
  final String? approvedAt;
  final String? rejectedAt;
  final String? rejectionReason;

  WithdrawalRequestModel({
    required this.id,
    required this.requestedAmount,
    required this.status,
    required this.requestDate,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
  });

  factory WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestModel(
      id: json['id'] ?? 0,
      requestedAmount: (json['amount'] ?? json['requested_amount'] ?? '0.00').toString(),
      status: json['status'] ?? 'pending',
      requestDate: json['created_at'] ?? json['request_date'] ?? '',
      approvedAt: json['approved_at'],
      rejectedAt: json['rejected_at'],
      rejectionReason: json['rejection_reason'],
    );
  }
}

