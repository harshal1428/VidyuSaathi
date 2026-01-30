import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/dashboard_stats_model.dart';
import '../../../models/user_model.dart';
import '../../../widgets/smart_ticket_card.dart';
import '../../../models/ticket_model.dart';
import '../officer_ticket_detail_screen.dart';

/// EE (Executive Engineer) Dashboard Section
class EEDashboardSection extends StatefulWidget {
  const EEDashboardSection({Key? key}) : super(key: key);

  @override
  State<EEDashboardSection> createState() => _EEDashboardSectionState();
}

class _EEDashboardSectionState extends State<EEDashboardSection> {
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
          _buildWelcomeHeader(isDark),
          const SizedBox(height: 20),


          // Circle Tickets (Data-driven)
          StreamBuilder<DashboardStats>(
            stream: dbService.getTicketStats(user),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? DashboardStats(total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0, critical: 0, high: 0, medium: 0, low: 0);
              return _buildCircleTickets(isDark, stats);
            }
          ),
          const SizedBox(height: 20),
          
          // Division Escalations
           StreamBuilder<List<TicketModel>>(
            stream: dbService.getOfficerTickets(user, status: 'Escalated'), 
            builder: (context, snapshot) {
              final tickets = snapshot.data ?? [];
              final criticalTickets = tickets.where((t) => t.priority == 'Critical' || t.status == 'Escalated').take(3).toList();
              
              if (criticalTickets.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('Priority Attention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                    const SizedBox(height: 12),
                    ...criticalTickets.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SmartTicketCard(
                        ticket: t,
                        isDark: isDark,
                        onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => OfficerTicketDetailScreen(ticket: t)),
                           );
                        },
                      ),
                    )),
                    const SizedBox(height: 20),
                ],
              );
            }
          ),

          // Circle Officers (Subordinate Staff)
          StreamBuilder<List<UserModel>>(
             stream: dbService.getSubordinateStaff(user),
             builder: (context, snapshot) {
               final staff = snapshot.data ?? [];
               return _buildCircleOfficersOverview(isDark, staff);
             }
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executive Engineer Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Circle management and coordination',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleTickets(bool isDark, DashboardStats stats) {
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
          const Text('Circle Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        ],
      ),
    );
  }

  Widget _buildCircleOfficersOverview(bool isDark, List<UserModel> staff) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subordinate Officers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${staff.length} Staff', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          if (staff.isEmpty) const Text("No subordinate staff found."),
          ...staff.map((s) => ListTile(
            title: Text(s.name),
            subtitle: Text(s.designation ?? s.role ?? ''),
            leading: CircleAvatar(child: Text(s.name.isNotEmpty ? s.name[0] : 'U')),
            contentPadding: EdgeInsets.zero,
            trailing: const Icon(Icons.info_outline, size: 20),
            onTap: () {
               showModalBottomSheet(
                 context: context,
                 builder: (context) => Container(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       ListTile(
                         leading: const Icon(Icons.phone),
                         title: Text(s.phone),
                         onTap: () {}, 
                       ),
                       ListTile(
                         leading: const Icon(Icons.email),
                         title: Text(s.email),
                         onTap: () {}, 
                       ),
                     ],
                   ),
                 ),
               );
             },
          )),
        ],
      ),
    );
  }

  void _navigateToTickets({String? status}) {
     String type = 'my_tasks';
     if (status == 'Pending') type = 'pending';
     else if (status == 'In Progress') type = 'in_progress';
     else if (status == 'Resolved') type = 'completed';

     Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': type}); 
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
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
             const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
