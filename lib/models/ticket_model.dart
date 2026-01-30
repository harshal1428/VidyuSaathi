import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String ticketId;
  final String title;
  final String description;
  final String category;
  final String priority; // 'High', 'Medium', 'Low', 'Critical'
  final String status;
  final String citizenId;
  
  // Hierarchy & Assignment
  final String? currentOwnerId;
  final String? currentOwnerRole;
  final String? supervisingJEId;
  
  final String? officeId;
  final String? regionId;
  final String? circleId;
  final String? divisionId;
  
  final int? slaHours;
  final int escalationLevel;
  final String generatedVia; // 'App', 'Web', 'Phone'
  
  // Location
  final double? latitude;
  final double? longitude;

  final List<String> imageUrls;
  
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? assignedAt;

  TicketModel({
    required this.ticketId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.citizenId,
    this.currentOwnerId,
    this.currentOwnerRole,
    this.supervisingJEId,
    this.officeId,
    this.regionId,
    this.circleId,
    this.divisionId,
    this.slaHours,
    this.escalationLevel = 0,
    this.generatedVia = 'App',
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.assignedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'citizenId': citizenId,
      'currentOwnerId': currentOwnerId,
      'currentOwnerRole': currentOwnerRole,
      'supervisingJEId': supervisingJEId,
      'officeId': officeId,
      'regionId': regionId,
      'circleId': circleId,
      'divisionId': divisionId,
      'slaHours': slaHours,
      'escalationLevel': escalationLevel,
      'generatedVia': generatedVia,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      ticketId: map['ticketId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? '',
      citizenId: map['citizenId'] ?? '',
      currentOwnerId: map['currentOwnerId'],
      currentOwnerRole: map['currentOwnerRole'],
      supervisingJEId: map['supervisingJEId'],
      officeId: map['officeId'],
      regionId: map['regionId'],
      circleId: map['circleId'],
      divisionId: map['divisionId'],
      slaHours: map['slaHours'],
      escalationLevel: map['escalationLevel'] ?? 0,
      generatedVia: map['generatedVia'] ?? 'App',
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      resolvedAt: map['resolvedAt'] != null ? (map['resolvedAt'] as Timestamp).toDate() : null,
      assignedAt: map['assignedAt'] != null ? (map['assignedAt'] as Timestamp).toDate() : null,
    );
  }
}


