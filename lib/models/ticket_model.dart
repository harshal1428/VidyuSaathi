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
  final int? slaMinutes;
  
  // Location
  final double? latitude;
  final double? longitude;

  final int escalationLevel;
  final String generatedVia; // 'App', 'Web', 'Phone'

  final List<String> imageUrls;
  
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? assignedAt;
  final String? resolutionDescription;
  final List<String> resolutionImageUrls;
  final DateTime? resolutionSubmittedAt;
  final String? resolutionSubmittedBy;
  final String? citizenVerificationStatus;
  final DateTime? citizenVerifiedAt;
  final String? citizenVerificationNote;
  final String? rejectionReason;
  final String departmentId;
  final String rawInputText;
  final Map<String, dynamic> nlpClassification;
  final bool isRecurrence;
  final String previousTicketId;
  final List<String> linkedTicketIds;
  final int escalationStartLevel;
  final int adjustedSlaHours;

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
    this.slaMinutes,
    this.escalationLevel = 0,
    this.generatedVia = 'App',
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.assignedAt,
    this.resolutionDescription,
    this.resolutionImageUrls = const [],
    this.resolutionSubmittedAt,
    this.resolutionSubmittedBy,
    this.citizenVerificationStatus,
    this.citizenVerifiedAt,
    this.citizenVerificationNote,
    this.rejectionReason,
    this.departmentId = '',
    this.rawInputText = '',
    this.nlpClassification = const {},
    this.isRecurrence = false,
    this.previousTicketId = '',
    this.linkedTicketIds = const [],
    this.escalationStartLevel = 1,
    this.adjustedSlaHours = 0,
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
      'slaMinutes': slaMinutes,
      'escalationLevel': escalationLevel,
      'generatedVia': generatedVia,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
      'resolutionDescription': resolutionDescription,
      'resolutionImageUrls': resolutionImageUrls,
      'resolutionSubmittedAt': resolutionSubmittedAt != null ? Timestamp.fromDate(resolutionSubmittedAt!) : null,
      'resolutionSubmittedBy': resolutionSubmittedBy,
      'citizenVerificationStatus': citizenVerificationStatus,
      'citizenVerifiedAt': citizenVerifiedAt != null ? Timestamp.fromDate(citizenVerifiedAt!) : null,
      'citizenVerificationNote': citizenVerificationNote,
      'rejectionReason': rejectionReason,
      'departmentId': departmentId,
      'rawInputText': rawInputText,
      'nlpClassification': nlpClassification,
      'isRecurrence': isRecurrence,
      'previousTicketId': previousTicketId,
      'linkedTicketIds': linkedTicketIds,
      'escalationStartLevel': escalationStartLevel,
      'adjustedSlaHours': adjustedSlaHours,
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
      slaMinutes: map['slaMinutes'],
      escalationLevel: map['escalationLevel'] ?? 0,
      generatedVia: map['generatedVia'] ?? 'App',
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      resolvedAt: map['resolvedAt'] != null ? (map['resolvedAt'] as Timestamp).toDate() : null,
      assignedAt: map['assignedAt'] != null ? (map['assignedAt'] as Timestamp).toDate() : null,
      resolutionDescription: map['resolutionDescription'],
      resolutionImageUrls: List<String>.from(map['resolutionImageUrls'] ?? []),
      resolutionSubmittedAt: map['resolutionSubmittedAt'] != null ? (map['resolutionSubmittedAt'] as Timestamp).toDate() : null,
      resolutionSubmittedBy: map['resolutionSubmittedBy'],
      citizenVerificationStatus: map['citizenVerificationStatus'],
      citizenVerifiedAt: map['citizenVerifiedAt'] != null ? (map['citizenVerifiedAt'] as Timestamp).toDate() : null,
      citizenVerificationNote: map['citizenVerificationNote'],
      rejectionReason: map['rejectionReason'],
      departmentId: map['departmentId'] ?? '',
      rawInputText: map['rawInputText'] ?? '',
      nlpClassification: map['nlpClassification'] != null ? Map<String, dynamic>.from(map['nlpClassification']) : {},
      isRecurrence: map['isRecurrence'] ?? false,
      previousTicketId: map['previousTicketId'] ?? '',
      linkedTicketIds: List<String>.from(map['linkedTicketIds'] ?? []),
      escalationStartLevel: map['escalationStartLevel'] ?? 1,
      adjustedSlaHours: map['adjustedSlaHours'] ?? 0,
    );
  }
}


