import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  print("Starting Export Office Data...");
  
  // Initialize Firebase (simulated environment)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase already initialized or skipped: $e");
  }

  final firestore = FirebaseFirestore.instance;
  
  print("Fetching USERS collection...");
  final querySnapshot = await firestore.collection('USERS').get();
  
  print("Found ${querySnapshot.docs.length} users.");
  
  final List<Map<String, dynamic>> officers = [];
  
  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final role = data['role']?.toString().toUpperCase() ?? '';
    if (role != 'CITIZEN' && role != 'USER') {
      officers.add(data);
    }
  }
  
  print("Identified ${officers.length} officers.");
  
  if (officers.isEmpty) {
    print("No officers found in database.");
    return;
  }
  
  // Create CSV String
  final headers = [
    'userId', 'name', 'email', 'phone', 'role', 'designation', 
    'divisionId', 'circleId', 'regionId', 'officeId', 'level', 
    'employeeId', 'password', 'departmentId', 'isActive', 'createdAt'
  ];
  
  final csvRows = [headers.join(',')];
  
  for (var officer in officers) {
    final row = headers.map((header) {
      var value = officer[header] ?? '';
      if (value is DateTime) {
        value = value.toIso8601String();
      } else if (value is Timestamp) {
        value = value.toDate().toIso8601String();
      }
      // Wrap in quotes if it contains commas
      String strValue = value.toString();
      if (strValue.contains(',')) {
        strValue = '"$strValue"';
      }
      return strValue;
    }).join(',');
    csvRows.add(row);
  }
  
  final csvContent = csvRows.join('\n');
  
  final file = File('officers_data.csv');
  await file.writeAsString(csvContent);
  
  print("Successfully exported ${officers.length} officers to officers_data.csv");
  exit(0);
}
