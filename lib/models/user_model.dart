import 'package:cloud_firestore/cloud_firestore.dart';

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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
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
}
