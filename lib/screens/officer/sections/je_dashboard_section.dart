import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../models/ticket_model.dart';
import '../../../models/dashboard_stats_model.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/smart_ticket_card.dart';
import '../officer_ticket_detail_screen.dart';
import '../cluster_list_screen.dart';

/// JE (Junior Engineer) Dashboard Section
/// Connected to Firebase via DatabaseService
class JEDashboardSection extends StatefulWidget {
  const JEDashboardSection({Key? key}) : super(key: key);

  @override
  State<JEDashboardSection> createState() => _JEDashboardSectionState();
}

class _JEDashboardSectionState extends State<JEDashboardSection> {
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
          // Welcome Header
          _buildWelcomeHeader(isDark, user),
          const SizedBox(height: 20),

          // My Tickets Overview (Stats)
          StreamBuilder<DashboardStats>(
            stream: dbService.getTicketStats(user),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? DashboardStats(total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0, critical: 0, high: 0, medium: 0, low: 0);
              return _buildMyTicketsOverview(isDark, stats);
            }
          ),
          const SizedBox(height: 20),

          // Field Officers Under JE
          StreamBuilder<List<UserModel>>(
            stream: dbService.getSubordinateStaff(user),
            builder: (context, snapshot) {
              final staff = snapshot.data ?? [];
              return _buildFieldOfficersSection(isDark, staff);
            }
          ),
          const SizedBox(height: 20),


          // Complaint Clusters Link
          _buildClusterOverview(isDark, context),
          const SizedBox(height: 20),

          // Active Complaints (Recent)
          StreamBuilder<List<TicketModel>>(
            stream: dbService.getRecentTickets(user, limit: 5),
            builder: (context, snapshot) {
              final tickets = snapshot.data ?? [];
              return _buildActiveComplaints(isDark, tickets);
            }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
              : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Junior Engineer Dashboard',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome, ${user.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Managing ${user.officeId ?? "Office"}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTicketsOverview(bool isDark, DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: isDark ? AppColors.darkSidebarPrimary : Colors.blue),
              const SizedBox(width: 8),
              Text(
                'My Tickets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tickets byStatus
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
              const SizedBox(width: 12),
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
                  title: 'Resolved',
                  value: '${stats.resolved}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                  onTap: () => _navigateToTickets(status: 'Resolved'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Escalated',
                  value: '${stats.escalated}',
                  icon: Icons.upload,
                  color: Colors.red,
                  isDark: isDark,
                  onTap: () => _navigateToTickets(status: 'Escalated'),
                ),
              ),
            ],
          ),
        ],
      ),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldOfficersSection(bool isDark, List<UserModel> staff) {
    // Filter for Field Officers only if needed, but getSubordinateStaff should usually handle it.
    // Assuming staff list contains FEs.
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: isDark ? Colors.purple[300] : Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Team Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${staff.length} Staff',
                  style: TextStyle(
                    color: isDark ? Colors.purple[300] : Colors.purple.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (staff.isEmpty)
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text("No field staff assigned.", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])),
             ),
          ...staff.map((member) => Column(
            children: [
              _buildFieldOfficerItem(
                name: member.name,
                officerId: member.userId,
                designation: member.designation ?? member.role ?? 'Staff',
                isDark: isDark,
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
                                 title: Text(member.phone),
                                 onTap: () {}, 
                               ),
                               ListTile(
                                 leading: const Icon(Icons.email),
                                 title: Text(member.email),
                                 onTap: () {}, 
                               ),
                             ],
                           ),
                         ),
                       );
                }
              ),
              const SizedBox(height: 8),
            ],
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
     else if (status == 'Escalated') type = 'escalated'; // TaskManagement update needed if we want this exact filter, but consistent arg passing

     Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': type}); 
  }

  Widget _buildFieldOfficerItem({
    required String name,
    required String officerId,
    required String designation,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  color: isDark ? Colors.purple[300] : Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$designation • $officerId',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
             const Icon(Icons.info_outline, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveComplaints(bool isDark, List<TicketModel> tickets) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: isDark ? Colors.orange[300] : Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Complaints',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (tickets.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 20),
               child: Center(child: Text("No tickets found.")),
             ),

          ...tickets.map((ticket) => SmartTicketCard(
            ticket: ticket,
            isDark: isDark,
            onTap: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => OfficerTicketDetailScreen(ticket: ticket)),
               );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildComplaintItem({
    required TicketModel ticket,
    required bool isDark,
  }) {
    Color statusColor;
    switch (ticket.status.toLowerCase()) {
      case 'pending':
      case 'created':
        statusColor = Colors.orange;
        break;
      case 'in progress':
      case 'assigned':
        statusColor = Colors.blue;
        break;
      case 'resolved':
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'rejected':
      case 'escalated':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    final dateStr = DateFormat('dd MMM yyyy').format(ticket.createdAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      shortenId(ticket.ticketId),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkSidebarPrimary : Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        ticket.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.title,
             style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                ticket.category,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              if (ticket.officeId != null) ...[
                Icon(Icons.business, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ticket.officeId ?? '',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
  
  String shortenId(String id) {
    if (id.length > 8) return id.substring(0, 8) + '...';
    return id;
  }

  Widget _buildClusterOverview(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
         border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Colors.orange.withOpacity(0.1),
               shape: BoxShape.circle,
             ),
             child: const Icon(Icons.hub, color: Colors.orange, size: 28),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Complaint Clusters',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                   ),
                 ),
                 const SizedBox(height: 4),
                 Text(
                   'View and resolve grouped complaints',
                   style: TextStyle(
                     fontSize: 12,
                     color: isDark ? Colors.grey[400] : Colors.grey[600],
                   ),
                 ),
               ],
             ),
           ),
           TextButton(
             onPressed: () {
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const ClusterListScreen()),
               );
             },
             child: const Text('View All'),
           )
        ],
      ),
    );
  }
}
