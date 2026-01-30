import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../models/user_model.dart';

class OfficerProfileScreen extends StatelessWidget {
  const OfficerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final user = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please login to view profile")));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: AppFontSizes.xl,
                      fontWeight: AppFontWeights.bold,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.designation ?? user.role ?? 'Officer',
                    style: TextStyle(
                      fontSize: AppFontSizes.sm,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: AppSpacing.xl),

             // Profile Details
             Container(
               padding: const EdgeInsets.all(AppSpacing.lg),
               decoration: BoxDecoration(
                 color: isDark ? AppColors.darkCard : AppColors.lightCard,
                 borderRadius: BorderRadius.circular(AppRadius.lg),
                 border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
               ),
               child: Column(
                 children: [
                   _buildProfileItem(Icons.email, 'Email', user.email, isDark),
                   const Divider(),
                   _buildProfileItem(Icons.phone, 'Phone', user.phoneNumber ?? 'N/A', isDark),
                   const Divider(),
                   _buildProfileItem(Icons.badge, 'Employee ID', user.userId, isDark), // Using userId as Emp ID for now
                   const Divider(),
                   _buildProfileItem(Icons.location_city, 'Office', user.officeId ?? 'Region/Circle Office', isDark),
                 ],
               ),
             ),
             
             const SizedBox(height: AppSpacing.xl),
             
             // Team Section
             Align(
               alignment: Alignment.centerLeft,
               child: Text(
                 "My Team",
                 style: TextStyle(
                   fontSize: AppFontSizes.lg, 
                   fontWeight: FontWeight.bold,
                   color: isDark ? AppColors.darkForeground : AppColors.lightForeground
                 ),
               ),
             ),
             const SizedBox(height: AppSpacing.md),
             
             StreamBuilder<List<UserModel>>(
               stream: dbService.getSubordinateStaff(user),
               builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                 }
                 final team = snapshot.data ?? [];
                 
                 if (team.isEmpty) {
                   return Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Text("No immediate subordinates found.", style: TextStyle(color: Colors.grey[600])),
                   );
                 }
                 
                 return ListView.builder(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: team.length,
                   itemBuilder: (context, index) {
                     final member = team[index];
                     return Card(
                       margin: const EdgeInsets.only(bottom: 8),
                       elevation: 0,
                       color: isDark ? AppColors.darkCard : Colors.white,
                       shape: RoundedRectangleBorder(
                         side: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: ListTile(
                         leading: CircleAvatar(
                           child: Text(member.name.isNotEmpty ? member.name[0] : 'S'),
                         ),
                         title: Text(member.name, style: TextStyle(color: isDark ? AppColors.darkForeground : AppColors.lightForeground)),
                         subtitle: Text(member.designation ?? member.role ?? 'Staff', style: TextStyle(color: Colors.grey[600])),
                       ),
                     );
                   },
                 );
               },
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
           const SizedBox(width: AppSpacing.lg),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   label,
                   style: TextStyle(
                     fontSize: AppFontSizes.xs,
                     color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                   ),
                 ),
                 const SizedBox(height: 2),
                 Text(
                   value,
                   style: TextStyle(
                     fontSize: AppFontSizes.base,
                     color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }
}


