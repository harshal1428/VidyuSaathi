import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/smart_ticket_card.dart';
import '../../../models/ticket_model.dart';
import '../../../models/dashboard_stats_model.dart';

/// FE (Field Officer) Dashboard Section
/// Field operations focused - Active complaints, escalations, ticket management
/// Data fields aligned with database schema
class FEDashboardSection extends StatefulWidget {
  const FEDashboardSection({Key? key}) : super(key: key);

  @override
  State<FEDashboardSection> createState() => _FEDashboardSectionState();
}

class _FEDashboardSectionState extends State<FEDashboardSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(isDark),
          const SizedBox(height: 20),

          // My Tickets Overview
          _buildMyTicketsOverview(isDark),
          const SizedBox(height: 20),

          // Active Complaints
          _buildActiveComplaints(isDark),
          const SizedBox(height: 20),

          // Escalations
          _buildEscalationsSection(isDark),
          const SizedBox(height: 20),

          // Notifications
          _buildNotificationsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
              : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Field Officer Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Field operations and complaint resolution',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTicketsOverview(bool isDark) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);
    
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DashboardStats>(
      stream: dbService.getTicketStats(user),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? DashboardStats(total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0, critical: 0, high: 0, medium: 0, low: 0);

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

              // Tickets by Status
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
                      title: 'Completed',
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

  void _navigateToTickets({String? status}) {
    String type = 'my_tasks';
    if (status == 'Pending') type = 'pending';
    else if (status == 'In Progress') type = 'in_progress';
    else if (status == 'Resolved') type = 'completed';
    else if (status == 'Escalated') type = 'escalated';

    Navigator.pushNamed(context, '/officer_tasks', arguments: {'type': type});
  }

  Widget _buildActiveComplaints(bool isDark) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<TicketModel>>(
      stream: dbService.getOfficerTickets(user), // Fetch current tickets for FE
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final tickets = snapshot.data!;
        
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
                        'Active Complaints',
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
                  child: Center(child: Text("No active tickets.")),
                ),

              ...tickets.take(5).map((ticket) => SmartTicketCard(
                ticket: ticket,
                isDark: isDark,
                onTap: () {
                   showDialog(
                     context: context, 
                     builder: (context) => AlertDialog(
                       title: Text(ticket.title),
                       content: Text(ticket.description),
                       actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))],
                     )
                   );
                },
              )),
            ],
          ),
        );
      }
    );
  }

  Widget _buildComplaintItem({
    required String ticketId,
    required String description,
    required String category,
    required String status,
    required String citizenName,
    required String date,
    required bool isDark,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        break;
      case 'assigned':
        statusColor = Colors.purple;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

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
              Row(
                children: [
                  Text(
                    ticketId,
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
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Delete/Reject button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    onPressed: () => _showRejectDialog(ticketId),
                    tooltip: 'Reject Ticket',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                category,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                citizenName,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String ticketId) {
    final reasonController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Text(
              'Reject Ticket',
              style: TextStyle(
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject ticket $ticketId?',
              style: TextStyle(
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for Rejection *',
                hintText: 'Please provide a reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              dbService.updateTicketStatus(
                ticketId,
                'Rejected',
                officerId: user?.userId,
                rejectionReason: reasonController.text.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket $ticketId rejected successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationsSection(bool isDark) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<TicketModel>>(
      stream: dbService.getOpenEscalatedTickets(user),
      builder: (context, snapshot) {
        final escalatedTickets = snapshot.data ?? [];

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
                  Text(
                    'Escalations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${escalatedTickets.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (escalatedTickets.isEmpty)
                const Center(child: Text('No recent escalations.')),
              ...escalatedTickets.take(3).map(
                (ticket) => SmartTicketCard(
                  ticket: ticket,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/officer_tasks',
                      arguments: {'type': 'escalated'},
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSection(bool isDark) {
    final user = Provider.of<AuthService>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

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
            Text(
            'Notifications',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
             ),
          ),
           const SizedBox(height: 16),
           StreamBuilder<int>(
             stream: Provider.of<NotificationService>(context).getUnreadCount(user.userId),
             builder: (context, snapshot) {
               final unread = snapshot.data ?? 0;
               if (unread == 0) {
                 return const Center(child: Text("No new notifications."));
               }
               return Row(
                 children: [
                   const Icon(Icons.notifications_active, color: Colors.orange),
                   const SizedBox(width: 8),
                   Text('$unread unread notification(s)'),
                 ],
               );
             },
           ),
        ],
      ),
    );
  }
}




