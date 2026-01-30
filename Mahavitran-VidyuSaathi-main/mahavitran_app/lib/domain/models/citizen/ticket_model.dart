import 'package:cloud_firestore/cloud_firestore.dart';

/// Ticket model for citizen complaints and issue tracking
class TicketModel {
  final String ticketId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String citizenId;
  final String? officeId;
  final String? regionId;
  final String? assignedOfficerId;
  final String? assignedRole;
  final DateTime? assignedAt;
  final int? slaHours;
  final int escalationLevel;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final double? latitude;
  final double? longitude;
  final List<String>? imageUrls;

  TicketModel({
    required this.ticketId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.citizenId,
    this.officeId,
    this.regionId,
    this.assignedOfficerId,
    this.assignedRole,
    this.assignedAt,
    this.slaHours,
    this.escalationLevel = 0,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.latitude,
    this.longitude,
    this.imageUrls,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      ticketId: map['ticketId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'Created',
      citizenId: map['citizenId'] ?? '',
      officeId: map['officeId'],
      regionId: map['regionId'],
      assignedOfficerId: map['assignedOfficerId'],
      assignedRole: map['assignedRole'],
      assignedAt: map['assignedAt'] != null
          ? (map['assignedAt'] as Timestamp).toDate()
          : null,
      slaHours: map['slaHours'],
      escalationLevel: map['escalationLevel'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      resolvedAt: map['resolvedAt'] != null
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      imageUrls:
          map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'citizenId': citizenId,
      'officeId': officeId,
      'regionId': regionId,
      'assignedOfficerId': assignedOfficerId,
      'assignedRole': assignedRole,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'slaHours': slaHours,
      'escalationLevel': escalationLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
    };
  }

  /// Copy with method for immutable updates
  TicketModel copyWith({
    String? ticketId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? citizenId,
    String? officeId,
    String? regionId,
    String? assignedOfficerId,
    String? assignedRole,
    DateTime? assignedAt,
    int? slaHours,
    int? escalationLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) {
    return TicketModel(
      ticketId: ticketId ?? this.ticketId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      citizenId: citizenId ?? this.citizenId,
      officeId: officeId ?? this.officeId,
      regionId: regionId ?? this.regionId,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      assignedRole: assignedRole ?? this.assignedRole,
      assignedAt: assignedAt ?? this.assignedAt,
      slaHours: slaHours ?? this.slaHours,
      escalationLevel: escalationLevel ?? this.escalationLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
