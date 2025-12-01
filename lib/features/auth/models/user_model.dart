class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final int? yearOfBirth;
  final String? zipCode;
  final bool isDecisionMaker;
  final bool hasMedicarePartB;
  final String? googleId;
  final String? authProvider;
  final bool isGuest;
  final bool isAdmin;
  final DateTime? emailVerifiedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.yearOfBirth,
    this.zipCode,
    required this.isDecisionMaker,
    required this.hasMedicarePartB,
    this.googleId,
    this.authProvider,
    required this.isGuest,
    required this.isAdmin,
    this.emailVerifiedAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isEmailVerified => emailVerifiedAt != null;

  // Getter aliases for backward compatibility
  String? get phone => phoneNumber;
  int? get birthYear => yearOfBirth;

  bool get isProfileComplete =>
      phoneNumber != null &&
      phoneNumber!.isNotEmpty &&
      yearOfBirth != null &&
      zipCode != null &&
      zipCode!.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      yearOfBirth: json['year_of_birth'],
      zipCode: json['zip_code'],
      isDecisionMaker: (json['is_decision_maker'] ?? false) == true,
      hasMedicarePartB: (json['has_medicare_part_b'] ?? false) == true,
      googleId: json['google_id'],
      authProvider: json['auth_provider'],
      isGuest: (json['is_guest'] ?? false) == true,
      isAdmin: (json['is_admin'] ?? false) == true,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
    );
  }
}
