class DealerModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String mobile;
  final String? address;
  final String? profilePic;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;

  DealerModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.mobile,
    this.address,
    this.profilePic,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'],
      profilePic: json['profile_pic'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      upiId: json['upi_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'mobile': mobile,
      'address': address,
      'profile_pic': profilePic,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
    };
  }
}

