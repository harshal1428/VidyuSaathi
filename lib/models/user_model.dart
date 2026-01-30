import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String designation;
  
  // Hierarchy Fields
  final String? divisionId;
  final String? circleId;
  final String? regionId;
  final String? officeId;

  // Citizen Specific Fields
  final String? address;
  final String? consumerNumber;
  
  final bool isActive;
  final DateTime createdAt;

  String get phoneNumber => phone;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.designation,
    this.divisionId,
    this.circleId,
    this.regionId,
    this.officeId,
    this.address,
    this.consumerNumber,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'designation': designation,
      'divisionId': divisionId,
      'circleId': circleId,
      'regionId': regionId,
      'officeId': officeId,
      'address': address,
      'consumerNumber': consumerNumber,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      designation: map['designation'] ?? '',
      divisionId: map['divisionId'],
      circleId: map['circleId'],
      regionId: map['regionId'],
      officeId: map['officeId'],
      address: map['address'],
      consumerNumber: map['consumerNumber'],
      isActive: map['isActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}


