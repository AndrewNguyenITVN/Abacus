class Account {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final DateTime dateOfBirth;
  final String gender;
  final String? avatarUrl;
  final bool isVerified;
  final String? initials;

  Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    this.avatarUrl,
    this.isVerified = false,
    String? initials,
  }) : initials = initials ?? _generateInitials(fullName);

  // Generate initials from full name
  static String _generateInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  // Copy with method for updating account
  Account copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? avatarUrl,
    bool? isVerified,
  }) {
    return Account(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
    };
  }

  // Create from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      avatarUrl: json['avatarUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

