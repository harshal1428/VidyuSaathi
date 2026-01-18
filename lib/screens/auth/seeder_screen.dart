import 'package:flutter/material.dart';
import '../../utils/seeder_service.dart';

class SeederScreen extends StatefulWidget {
  const SeederScreen({super.key});

  @override
  State<SeederScreen> createState() => _SeederScreenState();
}

class _SeederScreenState extends State<SeederScreen> {
  bool _isLoading = false;
  String _status = '';
  
  // Pune Data
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

  // Swargate Data
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

  void _runSeeder() async {
    setState(() {
      _isLoading = true;
      _status = 'Running Seeder...';
    });

    try {
      final seeder = SeederService();
      await seeder.seedPuneDivision();
      
      setState(() {
        _status = 'Success! Data seeded in Firestore.\n\nIMPORTANT: You must manually create these users in Firebase Console > Authentication with the emails below and password "123456".';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev: Seed Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runSeeder,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Seed Pune & Swargate Data'),
            ),
            const SizedBox(height: 24),
            if (_status.isNotEmpty) ...[
               Container(
                 padding: const EdgeInsets.all(8),
                 color: Colors.yellow[100],
                 child: Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
               ),
               const SizedBox(height: 24),
            ],
            
            const Text('Pune Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            _buildTable(_puneData),
            
            const SizedBox(height: 24),
            const Text('Swargate Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            _buildTable(_swargateData),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, String>> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(2.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: const [
            Padding(padding: EdgeInsets.all(8), child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.all(8), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.all(8), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.all(8), child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ]),
        ...data.map((c) => TableRow(children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(c['Role']!, style: const TextStyle(fontSize: 12))),
          Padding(padding: const EdgeInsets.all(8), child: Text(c['ID']!, style: const TextStyle(fontSize: 12))),
          Padding(padding: const EdgeInsets.all(8), child: Text(c['Name']!, style: const TextStyle(fontSize: 12))),
          Padding(padding: const EdgeInsets.all(8), child: Text(c['Email']!, style: const TextStyle(fontSize: 12))),
        ])),
      ],
    );
  }
}
