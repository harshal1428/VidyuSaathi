class DivisionModel {
  final String divisionId;
  final String name;
  final String state;

  DivisionModel({
    required this.divisionId,
    required this.name,
    required this.state,
  });

  Map<String, dynamic> toMap() => {
    'divisionId': divisionId,
    'name': name,
    'state': state,
  };
}

class CircleModel {
  final String circleId;
  final String divisionId;
  final String name;

  CircleModel({
    required this.circleId,
    required this.divisionId,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'circleId': circleId,
    'divisionId': divisionId,
    'name': name,
  };
}

class RegionModel {
  final String regionId;
  final String circleId;
  final String name;

  RegionModel({
    required this.regionId,
    required this.circleId,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'regionId': regionId,
    'circleId': circleId,
    'name': name,
  };
}

class OfficeModel {
  final String officeId;
  final String regionId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final int capacity;

  OfficeModel({
    required this.officeId,
    required this.regionId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm, 
    this.capacity = 10,
  });

  Map<String, dynamic> toMap() => {
    'officeId': officeId,
    'regionId': regionId,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'radiusKm': radiusKm,
    'capacity': capacity,
  };
}

class ClusterModel {
  final String clusterId;
  final String regionId;
  final String officeId;
  final String category;
  final double centerLatitude;
  final double centerLongitude;
  final int ticketCount;
  final String status;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  ClusterModel({
    required this.clusterId,
    required this.regionId,
    required this.officeId,
    required this.category,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.ticketCount,
    required this.status,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  Map<String, dynamic> toMap() => {
    'clusterId': clusterId,
    'regionId': regionId,
    'officeId': officeId,
    'category': category,
    'centerLatitude': centerLatitude,
    'centerLongitude': centerLongitude,
    'ticketCount': ticketCount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
  };
}


