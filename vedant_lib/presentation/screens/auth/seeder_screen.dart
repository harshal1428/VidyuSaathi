import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/citizen/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// Development screen for seeding test data
class SeederScreen extends StatefulWidget {
  const SeederScreen({super.key});

  @override
  State<SeederScreen> createState() => _SeederScreenState();
}

class _SeederScreenState extends State<SeederScreen> {
  bool _isLoading = false;
  String _status = '';

  // Pune Region Data
  final List<Map<String, String>> _puneData = [
    {'Role': 'CE', 'ID': '10000001', 'Name': 'Sanjay Patil', 'Email': 'sanjay.patil@mahavitaran.in'},
    {'Role': 'SE', 'ID': '10000002', 'Name': 'Milind Deshmukh', 'Email': 'milind.deshmukh@mahavitaran.in'},
    {'Role': 'EE', 'ID': '10000003', 'Name': 'Pravin Kulkarni', 'Email': 'pravin.kulkarni@mahavitaran.in'},
    {'Role': 'DyEE', 'ID': '10000004', 'Name': 'Sachin Joshi', 'Email': 'sachin.joshi@mahavitaran.in'},
    {'Role': 'AE', 'ID': '10000005', 'Name': 'Amol Jadhav', 'Email': 'amol.jadhav@mahavitaran.in'},
    {'Role': 'JE', 'ID': '10000006', 'Name': 'Rohit Bhosale', 'Email': 'rohit.bhosale@mahavitaran.in'},
    {'Role': 'Field Eng', 'ID': '10000007', 'Name': 'Nilesh Pawar', 'Email': 'nilesh.pawar@mahavitaran.in'},
    {'Role': 'Admin', 'ID': '10000008', 'Name': 'Sunita Shinde', 'Email': 'sunita.shinde@mahavitaran.in'},
  ];

  // Swargate Region Data
  final List<Map<String, String>> _swargateData = [
    {'Role': 'CE', 'ID': '10000009', 'Name': 'Vijay Chavan', 'Email': 'vijay.chavan@mahavitaran.in'},
    {'Role': 'SE', 'ID': '10000010', 'Name': 'Anil Phadke', 'Email': 'anil.phadke@mahavitaran.in'},
    {'Role': 'EE', 'ID': '10000011', 'Name': 'Mahesh Gokhale', 'Email': 'mahesh.gokhale@mahavitaran.in'},
    {'Role': 'DyEE', 'ID': '10000012', 'Name': 'Kiran Kulkarni', 'Email': 'kiran.kulkarni@mahavitaran.in'},
    {'Role': 'AE', 'ID': '10000013', 'Name': 'Swapnil More', 'Email': 'swapnil.more@mahavitaran.in'},
    {'Role': 'JE', 'ID': '10000014', 'Name': 'Akshay Gaikwad', 'Email': 'akshay.gaikwad@mahavitaran.in'},
    {'Role': 'Field Eng', 'ID': '10000015', 'Name': 'Suresh Kapse', 'Email': 'suresh.kapse@mahavitaran.in'},
    {'Role': 'Admin', 'ID': '10000016', 'Name': 'Rekha Kale', 'Email': 'rekha.kale@mahavitaran.in'},
  ];

  Future<void> _runSeeder() async {
    setState(() {
      _isLoading = true;
      _status = 'Running Seeder...';
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Seed Pune Region
      await _seedRegion(
        firestore: firestore,
        regionName: 'Pune',
        regionId: 'region_pune',
        users: _puneData,
      );

      // Seed Swargate Region
      await _seedRegion(
        firestore: firestore,
        regionName: 'Swargate',
        regionId: 'region_swargate',
        users: _swargateData,
      );

      setState(() {
        _status = 'Success! Data seeded in Firestore.\n\n'
            'IMPORTANT: You must manually create these users in '
            'Firebase Console > Authentication with the emails below '
            'and password "123456".';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seedRegion({
    required FirebaseFirestore firestore,
    required String regionName,
    required String regionId,
    required List<Map<String, String>> users,
  }) async {
    // Create Region
    await firestore.collection('REGIONS').doc(regionId).set({
      'regionId': regionId,
      'name': '$regionName Region',
      'latitude': 18.52,
      'longitude': 73.85,
      'radiusKm': 50,
    });

    // Create Main Office
    final mainOfficeId = 'office_${regionName.toLowerCase()}';
    await firestore.collection('OFFICES').doc(mainOfficeId).set({
      'officeId': mainOfficeId,
      'name': '$regionName Main Office',
      'level': 'Circle',
      'latitude': 18.52,
      'longitude': 73.85,
      'radiusKm': 20,
      'regionId': regionId,
    });

    // Create Users
    for (var u in users) {
      final isAdmin = u['Role'] == 'Admin';
      final user = UserModel(
        userId: u['ID']!,
        name: u['Name']!,
        email: u['Email']!,
        phone: '9800000000',
        role: isAdmin ? AppConstants.roleAdmin : AppConstants.roleOfficer,
        designation: isAdmin ? 'Admin' : _mapRoleToDesignation(u['Role']!),
        officeId: mainOfficeId,
        regionId: regionId,
        createdAt: DateTime.now(),
        isActive: true,
      );
      await firestore.collection('USERS').doc(u['ID']).set(user.toMap());
    }
  }

  String _mapRoleToDesignation(String role) {
    switch (role) {
      case 'CE': return AppConstants.desCE;
      case 'SE': return AppConstants.desSE;
      case 'EE': return AppConstants.desEE;
      case 'DyEE': return AppConstants.desDYEE;
      case 'AE': return AppConstants.desAE;
      case 'JE': return AppConstants.desJE;
      case 'Field Eng': return AppConstants.desFE;
      default: return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev: Seed Data'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.electric_bolt,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Warning Card
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Development Only',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'This tool seeds test data into Firestore.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seed Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runSeeder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.rocket_launch),
              label: Text(_isLoading ? 'Seeding...' : 'Seed Pune & Swargate Data'),
            ),
            const SizedBox(height: 16),

            // Status Message
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _status.contains('Error')
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status.contains('Error')
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _status.contains('Error')
                        ? Colors.red.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Pune Region Table
            const Text(
              'Pune Region',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            _buildDataTable(_puneData),

            const SizedBox(height: 24),

            // Swargate Region Table
            const Text(
              'Swargate Region',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            _buildDataTable(_swargateData),

            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Login Credentials',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Use the ID as login identifier for officers'),
                    Text('• Default password: 123456'),
                    Text('• Create users in Firebase Auth Console first'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Back Button
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, String>> data) {
    return Card(
      elevation: 1,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: data.map((row) {
            return DataRow(cells: [
              DataCell(Text(row['Role']!, style: const TextStyle(fontSize: 12))),
              DataCell(
                SelectableText(
                  row['ID']!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              DataCell(Text(row['Name']!, style: const TextStyle(fontSize: 12))),
              DataCell(
                SelectableText(
                  row['Email']!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
