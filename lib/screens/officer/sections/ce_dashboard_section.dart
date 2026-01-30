import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/dashboard_stats_model.dart';
import '../../../models/user_model.dart';
import '../pages/officer_team_screen.dart';
import '../../../widgets/smart_ticket_card.dart';
import '../officer_ticket_detail_screen.dart';
// For this MVP, we might display simplified or aggregated stats.

/// CE (Chief Engineer) Dashboard Section
/// Connected to Firebase via DatabaseService
class CEDashboardSection extends StatefulWidget {
  const CEDashboardSection({Key? key}) : super(key: key);

  @override
  State<CEDashboardSection> createState() => _CEDashboardSectionState();
}

class _CEDashboardSectionState extends State<CEDashboardSection> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row (Aggregated)
          // Stats Row (Aggregated)
          StreamBuilder<List<UserModel>>(
            stream: dbService.getSubordinateStaff(user),
            builder: (context, staffSnapshot) {
              final staffCount = staffSnapshot.data?.length ?? 0;
              
              return StreamBuilder<DashboardStats>(
                stream: dbService.getTicketStats(user),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? DashboardStats(total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0, critical: 0, high: 0, medium: 0, low: 0);
                  return _buildStatsRow(isDark, stats, staffCount);
                }
              );
            }
          ),
          const SizedBox(height: 20),

          // Circles Overview (Hierarchy)
          _buildCirclesOverview(isDark), // This might still be static for now or fetch structure if possible
          const SizedBox(height: 20),

          // Organization Tickets (Detailed breakdown)
          StreamBuilder<DashboardStats>(
            stream: dbService.getTicketStats(user),
             builder: (context, snapshot) {
              final stats = snapshot.data ?? DashboardStats(total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0, critical: 0, high: 0, medium: 0, low: 0);
              return _buildOrganizationTickets(isDark, stats);
            }
          ),

          const SizedBox(height: 20),
          _buildAllOfficesOverview(isDark),

          const SizedBox(height: 20),
          _buildEscalationsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, DashboardStats stats, int staffCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Critical',
            value: '${stats.critical}',
            icon: Icons.warning,
            color: Colors.red,
            isDark: isDark,
            onTap: () => _navigateToTickets(status: 'Critical'), // Filtering to be implemented or just go to list
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Direct Reports',
            value: '$staffCount', 
            icon: Icons.people_alt,
            color: Colors.orange,
            isDark: isDark,
            onTap: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => const OfficerTeamScreen())
               );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCirclesOverview(bool isDark) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: AppColors.lightPrimary),
              const SizedBox(width: 8),
              const Text(
                'Superintending Engineers (Circle Heads)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          StreamBuilder<List<UserModel>>(
            stream: dbService.getSubordinateStaff(user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              
              final staff = snapshot.data ?? [];
              
              if (staff.isEmpty) {
                 return const Center(child: Text("No Superintending Engineers found in this division."));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: staff.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final officer = staff[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                      child: Text(officer.name.isNotEmpty ? officer.name[0] : 'S', style: const TextStyle(color: Colors.indigo)),
                    ),
                    title: Text('${officer.name} (SE)'),
                    subtitle: Text('Circle ID: ${officer.circleId ?? 'N/A'}'),
                    trailing: const Icon(Icons.info_outline, size: 20),
                    onTap: () {
                      _showOfficerDetails(context, officer);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showOfficerDetails(BuildContext context, UserModel officer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                officer.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(officer.role ?? 'Officer', style: const TextStyle(color: Colors.grey)),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(officer.phone),
                onTap: () {
                  // Launch dialer
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(officer.email),
                onTap: () {
                  // Launch email
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToTickets({String? status}) {
     String type = 'my_tasks';
     if (status == 'Pending') type = 'pending';
     else if (status == 'In Progress') type = 'in_progress';
     else if (status == 'Resolved') type = 'completed';
     else if (status == 'Critical') type = 'critical';

     Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': type}); 
  }

  Widget _buildOrganizationTickets(bool isDark, DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.statusInfo),
              const SizedBox(width: 8),
              Text(
                'Organization-wide Tickets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pending',
                  value: '${stats.pending}',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  isDark: isDark,
                  onTap: () => _navigateToTickets(status: 'Pending'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'In Progress',
                  value: '${stats.inProgress}',
                  icon: Icons.hourglass_top,
                  color: Colors.blue,
                  isDark: isDark,
                  onTap: () => _navigateToTickets(status: 'In Progress'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
           Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Completed',
                  value: '${stats.resolved}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                  onTap: () => _navigateToTickets(status: 'Resolved'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: '${stats.total}',
                  icon: Icons.assignment,
                  color: Colors.purple,
                  isDark: isDark,
                  onTap: () => _navigateToTickets(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllOfficesOverview(bool isDark) {
     // Removed hardcoded counts. 
     // For now, we'll hide this widget or return SizedBox until we have real structure counts.
     return const SizedBox.shrink(); 
  }

  Widget _buildEscalationsSection(bool isDark) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    // Dynamic Escalations
    return StreamBuilder<List<dynamic>>( // Using ticket stream but filtering
      stream: dbService.getOfficerTickets(user!, status: 'Escalated'), // Assuming status or we just fetch all and filter
      builder: (context, snapshot) {
         final tickets = snapshot.data ?? [];
         final criticalTickets = tickets.where((t) => t.priority.toLowerCase().contains('critical')).toList();
         
         if (criticalTickets.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: const Center(child: Text("No critical escalations.")),
            );
         }

         return Container(
           padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
             color: isDark ? AppColors.darkCard : AppColors.lightCard,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.red.withOpacity(0.5)),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Critical Escalations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                ...criticalTickets.take(3).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SmartTicketCard(
                    ticket: t,
                    isDark: isDark,
                    onTap: () {
                       // Navigate to detail
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => OfficerTicketDetailScreen(ticket: t)),
                       );
                    },
                  ),
                )),
             ],
           ),
         );
      }
    );
  }
}
