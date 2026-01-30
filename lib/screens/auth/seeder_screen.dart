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
  
  // Data for Display Only (Verification)
  final List<Map<String, String>> _hierarchyData = [
    {'Role': 'CE', 'ID': '10000001', 'Name': 'Sanjay Patil', 'Loc': 'Pune HQ'},
    {'Role': 'SE', 'ID': '10000002', 'Name': 'Milind Deshmukh', 'Loc': 'Circle 1'},
    {'Role': 'EE', 'ID': '10000003', 'Name': 'Pravin Kulkarni', 'Loc': 'Region 1'},
    {'Role': 'DyEE', 'ID': '10000004', 'Name': 'Sachin Joshi', 'Loc': 'Region 1'},
    {'Role': 'JE', 'ID': '10000005', 'Name': 'Rohit Bhosale', 'Loc': 'Office 1'},
    {'Role': 'AE', 'ID': '10000006', 'Name': 'Amol Jadhav', 'Loc': 'Office 1'},
    {'Role': 'JE', 'ID': '10000016', 'Name': 'Kunal Desai', 'Loc': 'Office 4 (Reg 2)'},
    {'Role': 'SE', 'ID': '10000019', 'Name': 'Anil Phadke', 'Loc': 'Circle 2'},
    {'Role': 'EE', 'ID': '10000020', 'Name': 'Vijay Chavan', 'Loc': 'Region 3'},
    {'Role': 'JE', 'ID': '10000035', 'Name': 'Rohan Pawar', 'Loc': 'Office 8 (Reg 4)'},
  ];

  void _runSeeder() async {
    setState(() {
      _isLoading = true;
      _status = 'Running Hierarchical Seeder...';
    });

    try {
      final seeder = SeederService();
      await seeder.seedHierarchicalData();
      
      setState(() {
        _status = 'Success! Full Structure (Pune Division) seeded.\n\nCREATE AUTH ACCOUNTS MANUALLY (Password 123456).';
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
            const Text(
              'Warning: This will overwrite existing users and structure data.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _runSeeder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Seed Full Hierarchy (Pune)'),
            ),
            const SizedBox(height: 16),
             ElevatedButton(
              onPressed: _isLoading ? null : () async {
                 setState(() {
                  _isLoading = true;
                  _status = 'Seeding Complaints...';
                });
                try {
                  await SeederService().seedHierarchicalData();
                  await SeederService().seedComplaintTypes();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seeding Complete!")));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              child: _isLoading ? const CircularProgressIndicator() : const Text("Run Database Seeder"),
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
            
            const Text('Sample of Seeded Data (Total 35 Users)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildTable(_hierarchyData),
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
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: const [
            Padding(padding: EdgeInsets.all(8), child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.all(8), child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            Padding(padding: EdgeInsets.all(8), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ]),
        ...data.map((c) => TableRow(children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(c['Role']!, style: const TextStyle(fontSize: 12))),
          Padding(padding: const EdgeInsets.all(8), child: Text(c['ID']!, style: const TextStyle(fontSize: 12))),
          Padding(padding: const EdgeInsets.all(8), child: Text(c['Name']!, style: const TextStyle(fontSize: 12))),
        ])),
      ],
    );
  }
}


