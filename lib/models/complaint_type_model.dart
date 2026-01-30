import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintTypeModel {
  final String title;
  final String category; // e.g. A1 (High)
  final String priority; // e.g. High
  final String slaResponse;
  final String slaResolution;

  ComplaintTypeModel({
    required this.title,
    required this.category,
    required this.priority,
    required this.slaResponse,
    required this.slaResolution,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'priority': priority,
      'slaResponse': slaResponse,
      'slaResolution': slaResolution,
    };
  }
  
  factory ComplaintTypeModel.fromMap(Map<String, dynamic> map) {
    return ComplaintTypeModel(
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? 'Medium',
      slaResponse: map['slaResponse'] ?? '',
      slaResolution: map['slaResolution'] ?? '',
    );
  }
}


