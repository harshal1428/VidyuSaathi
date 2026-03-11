import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
import 'escalation_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  // Initialization Logic
  // Initialization Logic
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;
  
  final EscalationService _escalationService = EscalationService();

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentUser = null;
        _isInitializing = false;
        _escalationService.stopMonitoring(); // Stop on logout
        notifyListeners();
      } else {
        _fetchUser(user.uid);
      }
    });
  }
  
  Future<void> _fetchUser(String uid) async {
      try {
        DocumentSnapshot doc = await _firestore.collection('USERS').doc(uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          
          if (_currentUser?.role != AppConstants.roleCitizen) {
             _escalationService.startMonitoring();
          }
        }
      } catch (e) {
        print("Error fetching user: $e");
      } finally {
        _isInitializing = false;
        notifyListeners();
      }
  }



  // Citizen Registration
  Future<void> registerCitizen({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    String? consumerNumber,
  }) async {
    try {
      // 1. Create Auth User
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create User Model
      UserModel newUser = UserModel(
        userId: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: AppConstants.roleCitizen,
        designation: 'Citizen', // Default for citizens
        createdAt: DateTime.now(),
        isActive: true,
        address: address,
        consumerNumber: consumerNumber,
      );

      // 3. Store in Firestore
      await _firestore.collection('USERS').doc(cred.user!.uid).set(newUser.toMap());
      
      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<void> login({
    required String identifier, // Email for Citizen, Unique ID for Officer
    required String password,
    required bool isOfficer,
  }) async {
    try {
      String email = identifier;
      
      if (isOfficer) {
        // 1. Try fetching directly by Document ID (Most efficient since we seed DocID = UserID)
        DocumentSnapshot doc = await _firestore.collection('USERS').doc(identifier).get();
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          email = data['email'] ?? '';
        } else {
          // 2. Fallback: Query by fields (in case DocID != UserID)
          QuerySnapshot query = await _firestore
              .collection('USERS')
              .where('userId', isEqualTo: identifier)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
             email = query.docs.first.get('email');
          } else {
             throw Exception('User ID "$identifier" not found in database. Please run the Seed Data tool first.');
          }
        }
        
        if (email.isEmpty) throw Exception('Email not found for User ID "$identifier".');
      }

      // 3. Authenticate
      UserCredential cred;
      try {
        cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // AUTO-REGISTRATION FOR SEEDED OFFICERS
          if (isOfficer) {
             print("User not found in Auth. Attempting auto-registration for seeded officer: $email");
             try {
                cred = await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                // Continue to migration logic below
             } catch (regError) {
                print("Auto-registration failed: $regError");
                throw Exception('Login Failed: $regError'); 
             }
          } else {
             throw Exception('User "$email" not found. Please register first.');
          }
        } else {
          rethrow;
        }
      }

      // 4. Fetch/Migrate User Data
      if (isOfficer) {
         // Check if the Auth UID document already exists
         DocumentSnapshot authDoc = await _firestore.collection('USERS').doc(cred.user!.uid).get();
         
         if (authDoc.exists) {
           _currentUser = UserModel.fromMap(authDoc.data() as Map<String, dynamic>);
         } else {
           // JIT Migration: Copy seeded data (at 'identifier') to Auth UID location
           print('Performing JIT Migration for Officer ${cred.user!.uid} from $identifier');
           
           DocumentSnapshot seededDoc = await _firestore.collection('USERS').doc(identifier).get();
           if (seededDoc.exists) {
             Map<String, dynamic> data = seededDoc.data() as Map<String, dynamic>;
             
             // Update userId to match Auth UID
             data['userId'] = cred.user!.uid;
             
             // Save to new location
             await _firestore.collection('USERS').doc(cred.user!.uid).set(data);
             
             // Delete old doc to prevent duplicate claims and ensure queries find the migrated user (if query uses limit(1))
             await _firestore.collection('USERS').doc(identifier).delete(); 
             
             _currentUser = UserModel.fromMap(data);
           } else {
             // Fallback if neither exist (shouldn't happen if identifier check passed)
              throw Exception('Officer profile data lost.');
           }
         }
      } else {
         // Citizen
         DocumentSnapshot doc = await _firestore.collection('USERS').doc(cred.user!.uid).get();
         if (doc.exists) {
           _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
         } else {
             throw Exception('Citizen profile not found.');
         }
      }
      
      if (_currentUser != null && _currentUser!.role != AppConstants.roleCitizen) {
          _escalationService.startMonitoring();
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _escalationService.stopMonitoring();
    notifyListeners();
  }
  
}


