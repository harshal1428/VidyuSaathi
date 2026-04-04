import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_core/constants/app_colors.dart';
import 'package:civic_core/models/user_model.dart';
import 'package:civic_core/services/database_service.dart';
import 'package:civic_core/services/auth_service.dart';

class OfficerTeamScreen extends StatefulWidget {
  const OfficerTeamScreen({Key? key}) : super(key: key);

  @override
  State<OfficerTeamScreen> createState() => _OfficerTeamScreenState();
}

class _OfficerTeamScreenState extends State<OfficerTeamScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Team'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: dbService.getSubordinateStaff(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          final staffList = snapshot.data ?? [];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                 if (staffList.isEmpty)
                    const Text('No subordinate staff found.'),
                 ...staffList.map((staff) => _buildStaffCard(context, staff, isDark)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, UserModel staff, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: InkWell(
        onTap: () {
           showModalBottomSheet(
             context: context,
             builder: (ctx) => Container(
               padding: const EdgeInsets.all(24),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(staff.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   Text(staff.designation ?? 'Staff'),
                   const SizedBox(height: 16),
                   ListTile(
                     leading: const Icon(Icons.phone),
                     title: Text(staff.phone),
                     onTap: () { /* Call Logic */ },
                   ),
                   ListTile(
                     leading: const Icon(Icons.email),
                     title: Text(staff.email),
                   ),
                 ],
               ),
             ),
           );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               CircleAvatar(
                 child: Text(staff.name.isNotEmpty ? staff.name[0] : 'U'),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(staff.designation ?? 'Staff'),
                      Text(staff.phone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                   ],
                 ),
               ),
               const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
