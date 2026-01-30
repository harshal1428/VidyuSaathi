import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    // Determine if we should scope to office.
    final bool isOfficeAdmin = (user?.role == 'OFFICE_ADMIN' || user?.designation == 'Admin');
    final String? officeId = user?.officeId;

    Query query = FirebaseFirestore.instance.collection('USERS').where('role', isNotEqualTo: 'CITIZEN');
    
    // Note: Firestore inequality filter on 'role' prevents other inequality filters or sorting by other fields easily without composite index.
    // However, equality filter on 'officeId' is fine combined with inequality on 'role'.
    if (isOfficeAdmin && officeId != null) {
      query = query.where('officeId', isEqualTo: officeId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}"));
        }
        
        final staffDocs = snapshot.data?.docs ?? [];
        // Client-side filtering just in case, ensuring we only show relevant roles if needed
        var staff = staffDocs.map((d) => d.data() as Map<String, dynamic>).toList();
        
        if (isOfficeAdmin) {
             // Admin only sees JE, AE, Field Officer
             staff = staff.where((d) {
                 String r = (d['role'] ?? '').toString().toUpperCase();
                 String des = (d['designation'] ?? '').toString().toUpperCase();
                 return r.contains('JUNIOR') || r == 'JE' || 
                        r.contains('ASSISTANT') || r == 'AE' || 
                        r.contains('FIELD') || r == 'FE' || des.contains('FIELD OFFICER');
             }).toList();
        }

        final totalStaff = staff.length;
        final fieldForceCount = staff.where((d) => (d['role'] ?? '').toString().toUpperCase().contains('FIELD')).length;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Staff Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                  if (isOfficeAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _showAddStaffDialog(context, officeId),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Staff'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Metrics
              Row(
                children: [
                   Expanded(child: _StatCard(title: "Total Staff", value: "$totalStaff", icon: Icons.people, color: Colors.blue)),
                   const SizedBox(width: 16),
                   Expanded(child: _StatCard(title: "Field Force", value: "$fieldForceCount", icon: Icons.engineering, color: Colors.orange)), 
                   const SizedBox(width: 16),
                   // Admins count might be redundant if user is the admin
                   Expanded(child: _StatCard(title: "Active", value: "${staff.length}", icon: Icons.check_circle, color: Colors.green)), 
                ],
              ),
              const SizedBox(height: 24),
              
              // Staff List
              const Text("Staff List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              if (staff.isEmpty) 
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("No staff members found for your office.")),
                ),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: staff.length,
                itemBuilder: (context, index) {
                  final data = staff[index];
                  final name = data['name'] ?? 'Unknown';
                  final role = data['role'] ?? 'Staff';
                  final email = data['email'] ?? '';
                  final phone = data['phone'] ?? '';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                        child: Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?", 
                            style: const TextStyle(color: AppColors.lightPrimary)),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("$role", style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(email.isNotEmpty ? email : phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert), 
                        onPressed: (){}
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        );
      }
    );
  }

  void _showAddStaffDialog(BuildContext context, String? officeId) {
    if (officeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: You are not assigned to an office.")));
      return;
    }

    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Field Officer"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text("Role: Field Officer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("Office ID: $officeId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // Create User in Firestore (using email as ID for simplicity or auto-id)
                  // In real app, Auth Registration should happen here. 
                  // For prototype, we just add to USERS collection.
                  final newUserId = DateTime.now().millisecondsSinceEpoch.toString();
                  await FirebaseFirestore.instance.collection('USERS').doc(newUserId).set({
                      'userId': newUserId,
                      'name': _nameController.text.trim(),
                      'email': _emailController.text.trim(),
                      'phone': _phoneController.text.trim(),
                      'role': 'Field Engineer',
                      'designation': 'Field Officer',
                      'officeId': officeId,
                      'divisionId': 'zone_pune', // Inherit from admin ideally, defaulting for proto
                      'isActive': true,
                      'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff Added Successfully")));
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Add"),
          )
        ],
      )
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }
}
