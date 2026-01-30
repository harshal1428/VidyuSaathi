import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

// Models for Escalated Tickets
class EscalatedTicket {
  final String id;
  final String priority;
  final String status;
  final DateTime escalatedAt;
  final String description;
  final String location;

  EscalatedTicket({
    required this.id,
    required this.priority,
    required this.status,
    required this.escalatedAt,
    required this.description,
    required this.location,
  });
}

class EscalationsScreen extends StatefulWidget {
  const EscalationsScreen({Key? key}) : super(key: key);

  @override
  State<EscalationsScreen> createState() => _EscalationsScreenState();
}

class _EscalationsScreenState extends State<EscalationsScreen> {
  bool _isRefreshing = false;

  // Mock escalated tickets data
  final List<EscalatedTicket> escalatedTickets = [
    EscalatedTicket(
      id: '2024-001',
      priority: 'Critical',
      status: 'In Progress',
      escalatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      description: 'Power outage affecting entire residential area for over 12 hours. Multiple complaints received from residents.',
      location: 'Pune - Kothrud',
    ),
    EscalatedTicket(
      id: '2024-002',
      priority: 'High',
      status: 'Pending',
      escalatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      description: 'Frequent voltage fluctuations causing damage to household appliances. Reported by multiple users.',
      location: 'Mumbai - Andheri West',
    ),
    EscalatedTicket(
      id: '2024-003',
      priority: 'Critical',
      status: 'In Progress',
      escalatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      description: 'Transformer malfunction with sparking. Safety concern for nearby residents and businesses.',
      location: 'Nashik - College Road',
    ),
    EscalatedTicket(
      id: '2024-004',
      priority: 'Medium',
      status: 'Resolved',
      escalatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 14)),
      description: 'Incorrect billing for commercial unit. Amount charged is significantly higher than usual.',
      location: 'Aurangabad - MIDC Area',
    ),
    EscalatedTicket(
      id: '2024-005',
      priority: 'High',
      status: 'Pending',
      escalatedAt: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Street light pole damaged in accident. Live wires exposed creating safety hazard.',
      location: 'Nagpur - Dharampeth',
    ),
    EscalatedTicket(
      id: '2024-006',
      priority: 'Critical',
      status: 'Pending',
      escalatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      description: 'Complete power failure in commercial complex affecting multiple businesses. Emergency situation.',
      location: 'Mumbai - Bandra East',
    ),
    EscalatedTicket(
      id: '2024-007',
      priority: 'High',
      status: 'In Progress',
      escalatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      description: 'Repeated cable theft causing frequent outages in residential area. Community concern.',
      location: 'Pune - Hadapsar',
    ),
    EscalatedTicket(
      id: '2024-008',
      priority: 'Medium',
      status: 'Resolved',
      escalatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      description: 'Billing discrepancy for industrial unit. Overcharged by 40%.',
      location: 'Nashik - Satpur',
    ),
  ];

  int get escalatedCount => escalatedTickets.where((t) => t.status != 'Resolved').length;

  void _handleRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  void _showTicketDetails(EscalatedTicket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketDetailsModal(ticket: ticket),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationPanel(
        tickets: escalatedTickets.where((t) => t.status != 'Resolved').toList(),
        onTicketClick: _showTicketDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        _handleRefresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title and Refresh Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escalated Complaints',
                      style: TextStyle(
                        fontSize: AppFontSizes.xl,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 80,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.statusOverloaded,
                        borderRadius: const BorderRadius.all(Radius.circular(1)),
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _handleRefresh,
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            ),
                          ),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Escalated Tickets List
            EscalatedTicketsTable(
              tickets: escalatedTickets,
              onTicketClick: _showTicketDetails,
            ),
          ],
        ),
      ),
    );
  }
}

// Escalated Tickets Table/List
class EscalatedTicketsTable extends StatelessWidget {
  final List<EscalatedTicket> tickets;
  final Function(EscalatedTicket) onTicketClick;

  const EscalatedTicketsTable({
    Key? key,
    required this.tickets,
    required this.onTicketClick,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFB91C1C);
      case 'High':
        return const Color(0xFFEA580C);
      case 'Medium':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFFEF2F2);
      case 'High':
        return const Color(0xFFFFF7ED);
      case 'Medium':
        return const Color(0xFFFEFCE8);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF16A34A);
      case 'In Progress':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFFF0FDF4);
      case 'In Progress':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFF9FAFB);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Escalated Complaints',
                  style: TextStyle(
                    fontSize: AppFontSizes.base,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 64,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.statusOverloaded,
                    borderRadius: const BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return InkWell(
                onTap: () => onTicketClick(ticket),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${ticket.id}',
                            style: TextStyle(
                              fontSize: AppFontSizes.sm,
                              fontWeight: AppFontWeights.medium,
                              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityBgColor(ticket.priority),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getPriorityColor(ticket.priority).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  ticket.priority,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: AppFontWeights.medium,
                                    color: _getPriorityColor(ticket.priority),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(ticket.status),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getStatusColor(ticket.status).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  ticket.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: AppFontWeights.medium,
                                    color: _getStatusColor(ticket.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        ticket.location,
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeAgo(ticket.escalatedAt),
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        ticket.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Ticket Details Modal
class TicketDetailsModal extends StatelessWidget {
  final EscalatedTicket ticket;

  const TicketDetailsModal({Key? key, required this.ticket}) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFB91C1C);
      case 'High':
        return const Color(0xFFEA580C);
      case 'Medium':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFFEF2F2);
      case 'High':
        return const Color(0xFFFFF7ED);
      case 'Medium':
        return const Color(0xFFFEFCE8);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF16A34A);
      case 'In Progress':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFFF0FDF4);
      case 'In Progress':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFF9FAFB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket Details',
                          style: TextStyle(
                            fontSize: AppFontSizes.base,
                            fontWeight: AppFontWeights.semiBold,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 48,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.statusOverloaded,
                            borderRadius: const BorderRadius.all(Radius.circular(1)),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket ID',
                                style: TextStyle(
                                  fontSize: AppFontSizes.xs,
                                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${ticket.id}',
                                style: TextStyle(
                                  fontSize: AppFontSizes.lg,
                                  fontWeight: AppFontWeights.semiBold,
                                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getPriorityBgColor(ticket.priority),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getPriorityColor(ticket.priority).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  ticket.priority,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.xs,
                                    fontWeight: AppFontWeights.medium,
                                    color: _getPriorityColor(ticket.priority),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(ticket.status),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getStatusColor(ticket.status).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  ticket.status,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.xs,
                                    fontWeight: AppFontWeights.medium,
                                    color: _getStatusColor(ticket.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          fontWeight: AppFontWeights.medium,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          ticket.description,
                          style: TextStyle(
                            fontSize: AppFontSizes.sm,
                            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.xs,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ticket.location,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.sm,
                                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Escalated At',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.xs,
                                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(ticket.escalatedAt),
                                  style: TextStyle(
                                    fontSize: AppFontSizes.sm,
                                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          fontWeight: AppFontWeights.medium,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoRow(Icons.person_outline, 'Rajesh Kumar', isDark),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(Icons.phone_outlined, '+91 98765 43210', isDark),
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(Icons.email_outlined, 'rajesh.kumar@email.com', isDark),
                      const SizedBox(height: AppSpacing.xl),
                      Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Assigned Officer',
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          fontWeight: AppFontWeights.medium,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.person, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Officer Sharma',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.sm,
                                      fontWeight: AppFontWeights.medium,
                                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Field Officer - Zone 3',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.xs,
                                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '+91 87654 32109',
                                    style: TextStyle(
                                      fontSize: AppFontSizes.xs,
                                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
        const SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: TextStyle(
            fontSize: AppFontSizes.sm,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ],
    );
  }
}

// Notification Panel
class NotificationPanel extends StatelessWidget {
  final List<EscalatedTicket> tickets;
  final Function(EscalatedTicket) onTicketClick;

  const NotificationPanel({
    Key? key,
    required this.tickets,
    required this.onTicketClick,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFB91C1C);
      case 'High':
        return const Color(0xFFEA580C);
      case 'Medium':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFFEF2F2);
      case 'High':
        return const Color(0xFFFFF7ED);
      case 'Medium':
        return const Color(0xFFFEFCE8);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_outlined, size: 20, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Escalated Tickets',
                      style: TextStyle(
                        fontSize: AppFontSizes.base,
                        fontWeight: AppFontWeights.semiBold,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 48,
                              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No escalated tickets',
                              style: TextStyle(
                                fontSize: AppFontSizes.sm,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: tickets.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              onTicketClick(ticket);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '#${ticket.id}',
                                        style: TextStyle(
                                          fontSize: AppFontSizes.sm,
                                          fontWeight: AppFontWeights.medium,
                                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getPriorityBgColor(ticket.priority),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: _getPriorityColor(ticket.priority).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          ticket.priority,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: AppFontWeights.medium,
                                            color: _getPriorityColor(ticket.priority),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    ticket.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.sm,
                                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ticket.location,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.xs,
                                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                        ),
                                      ),
                                      Text(
                                        _formatTimeAgo(ticket.escalatedAt),
                                        style: TextStyle(
                                          fontSize: AppFontSizes.xs,
                                          color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
}
