import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/ticket_model.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  bool _isRefreshing = false;

  void _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    // In a real stream scenario, the stream updates automatically. 
    // This might be used to trigger a manual fetch if we weren't using streams, 
    // or to show a visual indicator while we verify data.
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showComplaintDetails(TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ComplaintDetailsModal(ticket: ticket),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<TicketModel>>(
      stream: dbService.getTicketsForAdmin(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final complaints = snapshot.data ?? [];
        final totalComplaints = complaints.length;
        final pendingComplaints = complaints.where((c) => c.status.toLowerCase() != 'resolved' && c.status.toLowerCase() != 'closed').length;
        final criticalComplaints = complaints.where((c) => c.priority.toLowerCase() == 'critical').length;

        return RefreshIndicator(
          onRefresh: () async {
            _handleRefresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Complaints',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ],
                    ),
                    if (_isRefreshing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _handleRefresh,
                        tooltip: 'Refresh',
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(child: _buildSummaryCard("Total", "$totalComplaints", Icons.assignment, Colors.blue, isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSummaryCard("Pending", "$pendingComplaints", Icons.access_time, Colors.orange, isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSummaryCard("Critical", "$criticalComplaints", Icons.warning, Colors.red, isDark)),
                  ],
                ),
                const SizedBox(height: 24),

                // List
                _buildComplaintsList(complaints, isDark),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(List<TicketModel> complaints, bool isDark) {
    if (complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.assignment_turned_in, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text("No complaints found", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final ticket = complaints[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          color: isDark ? AppColors.darkCard : Colors.white,
          child: InkWell(
            onTap: () => _showComplaintDetails(ticket),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.ticketId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                      _buildStatusBadge(ticket.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                         ticket.currentOwnerId != null ? "Assigned: ${ticket.currentOwnerId}" : "Unassigned",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      _buildPriorityBadge(ticket.priority),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        color = Colors.green;
        break;
      case 'in progress':
        color = Colors.blue;
        break;
      case 'escalated':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    if (priority.toLowerCase() == 'critical') color = Colors.red;
    else if (priority.toLowerCase() == 'high') color = Colors.orange;
    else color = Colors.green;

    return Row(
      children: [
        Icon(Icons.flag, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          priority,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class ComplaintDetailsModal extends StatelessWidget {
  final TicketModel ticket;

  const ComplaintDetailsModal({Key? key, required this.ticket}) : super(key: key);

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
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      ticket.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text(ticket.status)),
                        const SizedBox(width: 8),
                        Chip(label: Text(ticket.priority)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                         color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                         color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow("Ticket ID", ticket.ticketId),
                    _buildDetailRow("Category", ticket.category),
                    _buildDetailRow("Consumer ID", ticket.citizenId),
                    _buildDetailRow("Created At", DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt)),
                    if (ticket.status == 'Escalated' || ticket.currentOwnerRole != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                           padding: const EdgeInsets.all(8),
                           color: Colors.red.withOpacity(0.1),
                           child: Row(children: [
                             const Icon(Icons.trending_up, color: Colors.red),
                             const SizedBox(width: 8),
                             Expanded(child: Text("Escalated to: ${ticket.currentOwnerRole ?? 'Superior'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))
                           ]),
                        ),
                      ),
                    
                    const SizedBox(height: 24),

                    // Admin Actions
                    if (ticket.status != 'Resolved' && ticket.status != 'Closed') ...[
                      Row(
                        children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                onPressed: () {
                                  final changedBy = Provider.of<AuthService>(context, listen: false).currentUser?.userId ?? 'ADMIN';
                                  // Simplified database update via provider
                                  Provider.of<DatabaseService>(context, listen: false).updateTicketStatus(ticket.ticketId, 'In Progress', officerId: changedBy);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Resolve'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () {
                                final changedBy = Provider.of<AuthService>(context, listen: false).currentUser?.userId ?? 'ADMIN';
                                Provider.of<DatabaseService>(context, listen: false).updateTicketStatus(ticket.ticketId, 'Resolved', officerId: changedBy);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
