import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintClusterModel {
  final String clusterId;
  final double centroidLatitude;
  final double centroidLongitude;
  final double radiusMeters;
  final String title;
  final List<String> ticketIds;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final String status;
  final int ticketCount;

  ComplaintClusterModel({
    required this.clusterId,
    required this.centroidLatitude,
    required this.centroidLongitude,
    required this.radiusMeters,
    required this.title,
    required this.ticketIds,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.status,
    required this.ticketCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'clusterId': clusterId,
      'centroidLatitude': centroidLatitude,
      'centroidLongitude': centroidLongitude,
      'radiusMeters': radiusMeters,
      'title': title,
      'ticketIds': ticketIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'status': status,
      'ticketCount': ticketCount,
    };
  }

  factory ComplaintClusterModel.fromMap(Map<String, dynamic> map) {
    return ComplaintClusterModel(
      clusterId: map['clusterId'] ?? '',
      centroidLatitude: (map['centroidLatitude'] ?? 0.0).toDouble(),
      centroidLongitude: (map['centroidLongitude'] ?? 0.0).toDouble(),
      radiusMeters: (map['radiusMeters'] ?? 0.0).toDouble(),
      title: map['title'] ?? '',
      ticketIds: List<String>.from(map['ticketIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (map['lastUpdatedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'Active',
      ticketCount: map['ticketCount'] ?? 0,
    );
  }
}
