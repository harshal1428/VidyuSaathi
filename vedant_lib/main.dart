import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase here when ready
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  runApp(const MahavitranApp(
    // Change startMode to test different flows:
    // 'auth' - Start with login screen (production)
    // 'admin' - Jump to admin dashboard
    // 'citizen' - Jump to citizen dashboard  
    // 'officer' - Jump to officer dashboard
    startMode: 'citizen',
  ));
}

