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
      identifier = identifier.trim();
      String email = identifier;

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
           // JIT Migration: Resolve seeded officer by email after authentication.
           print('Performing JIT Migration for Officer ${cred.user!.uid} from $email');
           
           QuerySnapshot seededQuery = await _firestore
               .collection('USERS')
               .where('email', isEqualTo: email)
               .limit(1)
               .get();

           final DocumentSnapshot? seededDoc = seededQuery.docs.isNotEmpty ? seededQuery.docs.first : null;
           if (seededDoc != null && seededDoc.exists) {
             Map<String, dynamic> data = seededDoc.data() as Map<String, dynamic>;
             
             // Update userId to match Auth UID
             data['userId'] = cred.user!.uid;
             
             // Save to new location
             try {
               await _firestore.collection('USERS').doc(cred.user!.uid).set(data);
             } on FirebaseException catch (e) {
               if (e.code == 'permission-denied') {
                 throw Exception('Profile migration denied by Firestore rules. Please deploy updated firestore.rules and retry.');
               }
               rethrow;
             }
             
             // Delete the old seeded doc to prevent duplicate claims.
             // Do not fail login if cleanup delete is denied.
             try {
               await seededDoc.reference.delete();
             } on FirebaseException catch (e) {
               if (e.code == 'permission-denied') {
                 print('Seeded profile cleanup skipped due to Firestore rules.');
               } else {
                 rethrow;
               }
             }
             
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

  // Dev/testing helper: open admin portal without credential-based login.
  Future<void> openAdminDirect({String? officeId}) async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      final cred = await _auth.signInAnonymously();
      firebaseUser = cred.user;
    }

    if (firebaseUser == null) {
      throw Exception('Unable to initialize admin session.');
    }

    final now = DateTime.now();
    final adminUser = UserModel(
      userId: firebaseUser.uid,
      name: 'Admin User',
      email: 'admin.direct@local',
      phone: '',
      role: 'OFFICE_ADMIN',
      designation: 'Admin',
      officeId: officeId,
      isActive: true,
      createdAt: now,
    );

    await _firestore.collection('USERS').doc(firebaseUser.uid).set(
      adminUser.toMap(),
      SetOptions(merge: true),
    );

    _currentUser = adminUser;
    _isInitializing = false;
    _escalationService.startMonitoring();
    notifyListeners();
  }
  
}


