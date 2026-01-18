import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

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
        createdAt: DateTime.now(),
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

      // 3. Authenticate with Firebase Auth
      try {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          throw Exception('User "$email" not found in Authentication System. \n\nIMPORTANT: You must manually create this user in Firebase Console > Authentication with password "$password".');
        }
        rethrow;
      }

      // 4. Fetch User Data to confirm and get Role
      // Use the Auth UID here, because we need to map Auth User -> Firestore User
      // But wait... for officers, we just found their Firestore Doc (which has DocID = SE001).
      // The Auth UID (random) MUST match a Firestore doc...
      // PROBLEM:
      // If we create a user in Auth, they get a Random UID (e.g. "Abs7...").
      // Our Firestore Doc is "SE001".
      // They are NOT linked.
      // When we login with Auth, `cred.user!.uid` will be "Abs7...".
      // We explicitly check `_firestore.collection('USERS').doc(cred.user!.uid)`.
      // It will NOT exist.
      
      // SOLUTION:
      // We need to link them.
      // Option A: Update the Firestore Doc ID to match Auth UID on first login.
      // Option B: Store Auth UID in the existing "SE001" doc? No.
      // Option C: Update the `userId` field to match Auth UID? No.
      
      // FIX logic:
      // If we are Officer, we know the firestore doc is at `identifier` (e.g. SE001).
      // We should use THAT document.
      // We don't need to re-fetch by Auth UID.
      
      if (isOfficer) {
         // Re-fetch strictly to ensure variable assignment
         DocumentSnapshot doc = await _firestore.collection('USERS').doc(identifier).get();
         _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
         // Citizen: DocID = Auth UID
         User? u = _auth.currentUser;
         DocumentSnapshot doc = await _firestore.collection('USERS').doc(u!.uid).get();
         if (doc.exists) {
           _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
         } else {
             // Citizen registered but no data?
             throw Exception('Citizen profile not found.');
         }
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
  
  // Initialize (check current user)
  Future<void> initialize() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('USERS').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    }
  }
}
