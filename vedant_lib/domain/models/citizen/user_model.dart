import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for both citizens and officers
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? designation;
  final String? officeId;
  final String? regionId;
  final bool isActive;
  final DateTime createdAt;
  final String? address;
  final String? consumerNumber;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.designation,
    this.officeId,
    this.regionId,
    this.isActive = true,
    required this.createdAt,
    this.address,
    this.consumerNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      designation: map['designation'],
      officeId: map['officeId'],
      regionId: map['regionId'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      address: map['address'],
      consumerNumber: map['consumerNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'designation': designation,
      'officeId': officeId,
      'regionId': regionId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'address': address,
      'consumerNumber': consumerNumber,
    };
  }

  /// Copy with method for immutable updates
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? designation,
    String? officeId,
    String? regionId,
    bool? isActive,
    DateTime? createdAt,
    String? address,
    String? consumerNumber,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      officeId: officeId ?? this.officeId,
      regionId: regionId ?? this.regionId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      consumerNumber: consumerNumber ?? this.consumerNumber,
    );
  }
}
