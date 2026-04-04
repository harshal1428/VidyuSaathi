import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';
import '../lib/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🚀 Initializing CivicCore Export Tool...");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("❌ Firebase Initialization Failed: $e");
    exit(1);
  }
  
  print("📦 Fetching officer data from USERS collection...");
  final snapshot = await FirebaseFirestore.instance.collection('USERS').get();
  
  if (snapshot.docs.isEmpty) {
    print("⚠️ No users found in database.");
    exit(0);
  }

  final List<String> csvLines = [];
  // Header
  csvLines.add("EmployeeID,Name,Designation,DepartmentID,Role,Level,Email,Phone,OfficeID,DivisionID,RegionID,CircleID,DocID,IsActive");

  int count = 0;
  for (var doc in snapshot.docs) {
    final data = doc.data();
    // Only export officers (those with role and employeeId)
    // Some seeded users might only have employeeId or role, let's be inclusive
    if (data.containsKey('employeeId') || (data.containsKey('role') && data['role'] != 'CITIZEN')) {
      final line = [
        _escapeCsv(data['employeeId']?.toString() ?? ''),
        _escapeCsv(data['name']?.toString() ?? ''),
        _escapeCsv(data['designation']?.toString() ?? ''),
        _escapeCsv(data['departmentId']?.toString() ?? ''),
        _escapeCsv(data['role']?.toString() ?? ''),
        _escapeCsv(data['level']?.toString() ?? ''),
        _escapeCsv(data['email']?.toString() ?? ''),
        _escapeCsv(data['phone']?.toString() ?? ''),
        _escapeCsv(data['officeId']?.toString() ?? ''),
        _escapeCsv(data['divisionId']?.toString() ?? ''),
        _escapeCsv(data['regionId']?.toString() ?? ''),
        _escapeCsv(data['circleId']?.toString() ?? ''),
        _escapeCsv(doc.id),
        _escapeCsv(data['isActive']?.toString() ?? 'true'),
      ].join(",");
      csvLines.add(line);
      count++;
    }
  }

  final csvContent = csvLines.join("\n");
  final file = File('officer_data_export.csv');
  await file.writeAsString(csvContent);
  
  print("\n✅ Export successful!");
  print("----------------------------------");
  print("Total Officers Exported: $count");
  print("Saved to: ${file.absolute.path}");
  print("----------------------------------\n");
  
  // Also print content to console for easy copy-paste just in case
  print("CSV CONTENT PREVIEW (First 5 lines):");
  print(csvLines.take(6).join("\n"));
  
  exit(0);
}

String _escapeCsv(String val) {
  if (val.contains(',') || val.contains('"') || val.contains('\n')) {
    return '"' + val.replaceAll('"', '""') + '"';
  }
  return val;
}
