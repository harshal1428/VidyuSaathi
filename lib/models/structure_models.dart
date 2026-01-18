import 'package:cloud_firestore/cloud_firestore.dart';

class RegionModel {
  final String regionId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;

  RegionModel({
    required this.regionId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'regionId': regionId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
    };
  }
}

class OfficeModel {
  final String officeId;
  final String name;
  final String level; // Circle, Division, Subdivision, Section, Unit
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String regionId;

  OfficeModel({
    required this.officeId,
    required this.name,
    required this.level,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.regionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'officeId': officeId,
      'name': name,
      'level': level,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'regionId': regionId,
    };
  }
}

class ClusterModel {
  final String clusterId;
  final String regionId;
  final String officeId;
  final String category;
  final double centerLatitude;
  final double centerLongitude;
  final String status;
  final DateTime createdAt;

  ClusterModel({
    required this.clusterId,
    required this.regionId,
    required this.officeId,
    required this.category,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'clusterId': clusterId,
      'regionId': regionId,
      'officeId': officeId,
      'category': category,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
