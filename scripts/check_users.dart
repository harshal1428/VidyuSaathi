import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:civic_core/firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  print("Checking JEs in sub_div_shivajinagar...");
  final snapshot = await firestore.collection('USERS')
      .where('officeId', isEqualTo: 'sub_div_shivajinagar')
      .where('role', whereIn: ['JE', 'Junior Engineer', 'Junior Engineer (JE)'])
      .get();

  print("Found ${snapshot.docs.length} users.");
  for (var doc in snapshot.docs) {
    print("DocID: ${doc.id} | UserID: ${doc.data()['userId']} | Role: ${doc.data()['role']} | Name: ${doc.data()['name']}");
  }
}
