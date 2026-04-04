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
    {'Role': 'CE', 'ID': 'ce_elec_pune@civiccore.pune.gov.in', 'Name': 'Chief Engineer', 'Loc': 'Pune Zone'},
    {'Role': 'SE', 'ID': 'se_elec_urbn@civiccore.pune.gov.in', 'Name': 'Superintending Engineer', 'Loc': 'Pune Urban Circle'},
    {'Role': 'EE', 'ID': 'ee_elec_swgt@civiccore.pune.gov.in', 'Name': 'Executive Engineer', 'Loc': 'Swargate Region'},
    {'Role': 'DyEE', 'ID': 'dee_elec_swgt@civiccore.pune.gov.in', 'Name': 'Deputy Executive Engineer', 'Loc': 'Swargate Region'},
    {'Role': 'AE', 'ID': 'ae_elec_swgt@civiccore.pune.gov.in', 'Name': 'Assistant Engineer', 'Loc': 'Swargate Division Office'},
    {'Role': 'JE', 'ID': 'je_elec_swgt@civiccore.pune.gov.in', 'Name': 'Junior Engineer', 'Loc': 'Swargate Division Office'},
    {'Role': 'L1', 'ID': 'lineman_swgt@civiccore.pune.gov.in', 'Name': 'Lineman', 'Loc': 'Swargate Division Office'},
  ];

  void _runSeeder() async {
    setState(() {
      _isLoading = true;
      _status = 'Running Hierarchical Seeder...';
    });

    try {
      final seeder = SeederService();
      await seeder.performSafetyCheckAndSeed(context);
      
      setState(() {
        _status = 'Success! Seeding Process finished.\n\nLogin with employee ID accounts or seeded officer emails (Password 123456).';
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
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Run Full CivicCore Seeder'),
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


