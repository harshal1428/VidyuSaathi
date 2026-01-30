import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/admin/theme_provider.dart';
import '../../../constants/app_colors.dart';

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
                  value: '8',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'In Progress',
                  value: '5',
                  icon: Icons.hourglass_top,
                  color: Colors.blue,
                  isDark: isDark,
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
                  value: '32',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Rejected',
                  value: '3',
                  icon: Icons.cancel,
                  color: Colors.red,
                  isDark: isDark,
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
  }) {
    return Container(
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
    );
  }

  Widget _buildActiveComplaints(bool isDark) {
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
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: isDark ? AppColors.darkSidebarPrimary : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildComplaintItem(
            ticketId: 'TKT-2024-001',
            description: 'Power outage in residential area',
            category: 'Power Failure',
            status: 'In Progress',
            citizenName: 'Rajesh Kumar',
            date: '21 Jan 2026',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildComplaintItem(
            ticketId: 'TKT-2024-002',
            description: 'Voltage fluctuation causing appliance damage',
            category: 'Voltage Fluctuation',
            status: 'Pending',
            citizenName: 'Priya Sharma',
            date: '20 Jan 2026',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildComplaintItem(
            ticketId: 'TKT-2024-003',
            description: 'Street light not working',
            category: 'Street Light',
            status: 'Assigned',
            citizenName: 'Amit Patel',
            date: '19 Jan 2026',
            isDark: isDark,
          ),
        ],
      ),
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
              // TODO: Implement soft delete with reason
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
              Icon(Icons.trending_up, color: isDark ? Colors.red[300] : Colors.red),
              const SizedBox(width: 8),
              Text(
                'Escalations',
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2 pending',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildEscalationItem(
            ticketId: 'TKT-2024-004',
            reason: 'SLA breach - 48 hours exceeded',
            escalatedTo: 'JE',
            time: '2 hours ago',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildEscalationItem(
            ticketId: 'TKT-2024-005',
            reason: 'Citizen complaint escalation',
            escalatedTo: 'JE',
            time: '5 hours ago',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationItem({
    required String ticketId,
    required String reason,
    required String escalatedTo,
    required String time,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ticketId,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.red[300] : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '→ $escalatedTo',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(bool isDark) {
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
                  Icon(Icons.notifications, color: isDark ? Colors.orange[300] : Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '2 new',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildNotificationItem(
            type: 'Assignment',
            message: 'New ticket #1245 assigned to you',
            seen: false,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildNotificationItem(
            type: 'Update',
            message: 'Ticket #1230 status updated by citizen',
            seen: false,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildNotificationItem(
            type: 'Reminder',
            message: 'Ticket #1220 SLA deadline approaching',
            seen: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String type,
    required String message,
    required bool seen,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: seen 
            ? (isDark ? AppColors.darkSurface : Colors.grey.shade50)
            : (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: seen 
              ? (isDark ? AppColors.darkBorder : Colors.grey.shade200)
              : (isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            seen ? Icons.mark_email_read : Icons.mark_email_unread,
            color: seen 
                ? (isDark ? Colors.grey[500] : Colors.grey)
                : (isDark ? AppColors.darkSidebarPrimary : Colors.blue),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: seen 
                        ? (isDark ? Colors.grey[400] : Colors.grey[700])
                        : (isDark ? Colors.blue[200] : Colors.blue[900]),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: seen 
                        ? (isDark ? Colors.grey[500] : Colors.grey[600])
                        : (isDark ? Colors.grey[300] : Colors.grey[800]),
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
