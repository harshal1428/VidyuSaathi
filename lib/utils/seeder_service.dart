import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/structure_models.dart';
import '../core/constants.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedPuneDivision() async {
    print("Starting Pune & Swargate Data Seeding...");
    
    try {
      // Create Regions/Offices hierarchy for Pune and Swargate
      // For simplicity in this flat list request, we will create two main Office structures.
      // 1. Pune Region
      // 2. Swargate Region (as per user request treating them parallel)

      await _seedStructure(
        regionName: 'Pune',
        regionId: 'region_pune',
        users: [
          _UserSeed('10000001', 'Sanjay Patil', 'sanjay.patil@mahavitaran.in', AppConstants.desCE),
          _UserSeed('10000002', 'Milind Deshmukh', 'milind.deshmukh@mahavitaran.in', AppConstants.desSE),
          _UserSeed('10000003', 'Pravin Kulkarni', 'pravin.kulkarni@mahavitaran.in', AppConstants.desEE),
          _UserSeed('10000004', 'Sachin Joshi', 'sachin.joshi@mahavitaran.in', AppConstants.desDYEE),
          _UserSeed('10000005', 'Amol Jadhav', 'amol.jadhav@mahavitaran.in', AppConstants.desAE),
          _UserSeed('10000006', 'Rohit Bhosale', 'rohit.bhosale@mahavitaran.in', AppConstants.desJE),
          _UserSeed('10000007', 'Nilesh Pawar', 'nilesh.pawar@mahavitaran.in', AppConstants.desFieldEngineer),
          _UserSeed('10000008', 'Sunita Shinde', 'sunita.shinde@mahavitaran.in', AppConstants.roleAdmin, isAdmin: true),
        ]
      );

      await _seedStructure(
        regionName: 'Swargate',
        regionId: 'region_swargate',
        users: [
          _UserSeed('10000009', 'Vijay Chavan', 'vijay.chavan@mahavitaran.in', AppConstants.desCE),
          _UserSeed('10000010', 'Anil Phadke', 'anil.phadke@mahavitaran.in', AppConstants.desSE),
          _UserSeed('10000011', 'Mahesh Gokhale', 'mahesh.gokhale@mahavitaran.in', AppConstants.desEE),
          _UserSeed('10000012', 'Kiran Kulkarni', 'kiran.kulkarni@mahavitaran.in', AppConstants.desDYEE),
          _UserSeed('10000013', 'Swapnil More', 'swapnil.more@mahavitaran.in', AppConstants.desAE),
          _UserSeed('10000014', 'Akshay Gaikwad', 'akshay.gaikwad@mahavitaran.in', AppConstants.desJE),
          _UserSeed('10000015', 'Suresh Kapse', 'suresh.kapse@mahavitaran.in', AppConstants.desFieldEngineer),
          _UserSeed('10000016', 'Rekha Kale', 'rekha.kale@mahavitaran.in', AppConstants.roleAdmin, isAdmin: true),
        ]
      );

      print("Seeding Complete.");
    } catch (e) {
      print("Seeding Error: $e");
      rethrow;
    }
  }

  Future<void> _seedStructure({required String regionName, required String regionId, required List<_UserSeed> users}) async {
    // Create Region
    final region = RegionModel(
      regionId: regionId,
      name: '$regionName Region',
      latitude: 18.52,
      longitude: 73.85,
      radiusKm: 50,
    );
    await _firestore.collection('REGIONS').doc(regionId).set(region.toMap());

    // Create Main Office (e.g. Pune Circle/Zone office)
    final mainOfficeId = 'office_${regionName.toLowerCase()}';
    final office = OfficeModel(
      officeId: mainOfficeId,
      name: '$regionName Main Office',
      level: 'Circle',
      latitude: 18.52,
      longitude: 73.85,
      radiusKm: 20,
      regionId: regionId,
    );
    await _firestore.collection('OFFICES').doc(mainOfficeId).set(office.toMap());

    // Create Users
    for (var u in users) {
      final user = UserModel(
        userId: u.id,
        name: u.name,
        email: u.email,
        phone: '9800000000', // Dummy
        role: u.isAdmin ? AppConstants.roleAdmin : AppConstants.roleOfficer,
        designation: u.isAdmin ? 'Admin' : u.designation,
        officeId: mainOfficeId,
        regionId: regionId,
        createdAt: DateTime.now(),
        isActive: true,
      );
      await _firestore.collection('USERS').doc(u.id).set(user.toMap());
    }
  }
}

class _UserSeed {
  final String id;
  final String name;
  final String email;
  final String designation;
  final bool isAdmin;

  _UserSeed(this.id, this.name, this.email, this.designation, {this.isAdmin = false});
}
