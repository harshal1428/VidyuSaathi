import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/models/citizen/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// Authentication service for handling user login, registration, and session management
class AuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isFirebaseInitialized = false;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _isFirebaseInitialized && _auth?.currentUser != null;
  
  User? get firebaseUser => _auth?.currentUser;
  
  bool get isFirebaseReady => _isFirebaseInitialized;

  AuthService() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        _isFirebaseInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firebase not initialized: $e');
      _isFirebaseInitialized = false;
    }
  }

  /// Set a mock user for testing without Firebase
  void setMockUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Register a new citizen user
  Future<void> registerCitizen({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    String? consumerNumber,
  }) async {
    if (!_isFirebaseInitialized || _auth == null || _firestore == null) {
      throw Exception('Firebase is not initialized. Please initialize Firebase first.');
    }
    
    try {
      // 1. Create Auth User
      UserCredential cred = await _auth!.createUserWithEmailAndPassword(
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
      await _firestore!
          .collection('USERS')
          .doc(cred.user!.uid)
          .set(newUser.toMap());

      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Login user with identifier (email for citizen, unique ID for officer)
  Future<void> login({
    required String identifier,
    required String password,
    required bool isOfficer,
  }) async {
    if (!_isFirebaseInitialized || _auth == null || _firestore == null) {
      throw Exception('Firebase is not initialized. Please initialize Firebase first.');
    }
    
    try {
      String email = identifier;

      if (isOfficer) {
        // Try fetching directly by Document ID
        DocumentSnapshot doc =
            await _firestore!.collection('USERS').doc(identifier).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          email = data['email'] ?? '';
        } else {
          // Fallback: Query by fields
          QuerySnapshot query = await _firestore!
              .collection('USERS')
              .where('userId', isEqualTo: identifier)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            email = query.docs.first.get('email');
          } else {
            throw Exception(
                'User ID "$identifier" not found in database. Please run the Seed Data tool first.');
          }
        }

        if (email.isEmpty) {
          throw Exception('Email not found for User ID "$identifier".');
        }
      }

      // Authenticate with Firebase Auth
      try {
        await _auth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          throw Exception(
              'User "$email" not found in Authentication System. '
              '\n\nIMPORTANT: You must manually create this user in '
              'Firebase Console > Authentication with password "$password".');
        }
        rethrow;
      }

      // Fetch User Data
      if (isOfficer) {
        DocumentSnapshot doc =
            await _firestore!.collection('USERS').doc(identifier).get();
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        User? u = _auth!.currentUser;
        DocumentSnapshot doc =
            await _firestore!.collection('USERS').doc(u!.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          throw Exception('Citizen profile not found.');
        }
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }

  /// Initialize and check for existing session
  Future<void> initialize() async {
    if (!_isFirebaseInitialized || _auth == null || _firestore == null) {
      return;
    }
    
    User? user = _auth!.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore!.collection('USERS').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null || _firestore == null) return;

    Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;

    if (updates.isNotEmpty) {
      await _firestore!
          .collection('USERS')
          .doc(_currentUser!.userId)
          .update(updates);

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
      );
      notifyListeners();
    }
  }
}
