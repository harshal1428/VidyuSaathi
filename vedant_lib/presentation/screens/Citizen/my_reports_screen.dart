import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/services/auth/auth_service.dart';
import '../../../data/services/citizen/citizen_database_service.dart';
import '../../../domain/models/citizen/ticket_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/citizen/citizen_app_drawer.dart';

/// Screen to display all reports/tickets submitted by the citizen
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    // Show demo mode content if Firebase is not ready
    if (!authService.isFirebaseReady) {
      return _buildDemoModeScreen(context);
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view reports')),
      );
    }

    final dbService = CitizenDatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        centerTitle: true,
      ),
      drawer: const CitizenAppDrawer(),
      body: StreamBuilder<List<TicketModel>>(
        stream: dbService.getCitizenTickets(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reports found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your submitted reports will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/report_issue');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Report an Issue'),
                  ),
                ],
              ),
            );
          }

          final tickets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _TicketCard(
                ticket: ticket,
                onTap: () => _showTicketDetails(context, ticket),
              );
            },
          );
        },
      ),
    );
  }

  void _showTicketDetails(BuildContext context, TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _StatusChip(status: ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ticket ID: ${ticket.ticketId.substring(0, 8)}...',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(ticket.description),
              const SizedBox(height: 16),

              // Details Grid
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.category,
                        label: 'Category',
                        value: ticket.category,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.priority_high,
                        label: 'Priority',
                        value: ticket.priority,
                      ),
                      const Divider(),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Submitted',
                        value: DateFormat('dd MMM yyyy, hh:mm a')
                            .format(ticket.createdAt),
                      ),
                      if (ticket.assignedOfficerId != null) ...[
                        const Divider(),
                        _DetailRow(
                          icon: Icons.person,
                          label: 'Assigned To',
                          value: ticket.assignedRole ?? 'Officer',
                        ),
                      ],
                      if (ticket.latitude != null &&
                          ticket.longitude != null) ...[
                        const Divider(),
                        _DetailRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value:
                              '${ticket.latitude!.toStringAsFixed(4)}, ${ticket.longitude!.toStringAsFixed(4)}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Images
              if (ticket.imageUrls != null && ticket.imageUrls!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Attached Images',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ticket.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ticket.imageUrls![index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Status Timeline
              const SizedBox(height: 24),
              Text(
                'Status Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildTimeline(ticket),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(TicketModel ticket) {
    final events = <Map<String, dynamic>>[
      {
        'status': 'Created',
        'date': ticket.createdAt,
        'completed': true,
      },
      {
        'status': 'Assigned',
        'date': ticket.assignedAt,
        'completed': ticket.assignedAt != null,
      },
      {
        'status': 'In Progress',
        'date': null,
        'completed': ticket.status == 'In Progress' ||
            ticket.status == 'Completed' ||
            ticket.status == 'Resolved',
      },
      {
        'status': 'Resolved',
        'date': ticket.resolvedAt,
        'completed': ticket.resolvedAt != null,
      },
    ];

    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final isLast = index == events.length - 1;
        final isCompleted = event['completed'] as bool;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color:
                        isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['status'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (event['date'] != null)
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(event['date'] as DateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Build demo mode screen with sample tickets
  Widget _buildDemoModeScreen(BuildContext context) {
    final demoTickets = [
      TicketModel(
        ticketId: 'DEMO-001',
        title: 'Power Outage',
        description: 'Complete power outage in the area since morning',
        category: 'Power Outage',
        priority: 'High',
        status: AppConstants.statusInProgress,
        citizenId: 'demo_user',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        latitude: 18.5204,
        longitude: 73.8567,
      ),
      TicketModel(
        ticketId: 'DEMO-002',
        title: 'Street Light Not Working',
        description: 'Street light near main road junction not working',
        category: 'Street Light Issue',
        priority: 'Medium',
        status: AppConstants.statusAssigned,
        citizenId: 'demo_user',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        latitude: 18.5304,
        longitude: 73.8467,
      ),
      TicketModel(
        ticketId: 'DEMO-003',
        title: 'Voltage Fluctuation',
        description: 'Frequent voltage fluctuation causing appliance damage',
        category: 'Voltage Issue',
        priority: 'High',
        status: AppConstants.statusResolved,
        citizenId: 'demo_user',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        latitude: 18.5104,
        longitude: 73.8667,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        centerTitle: true,
      ),
      drawer: const CitizenAppDrawer(),
      body: Column(
        children: [
          // Demo mode banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode - Showing sample reports',
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: demoTickets.length,
              itemBuilder: (context, index) {
                final ticket = demoTickets[index];
                return _TicketCard(
                  ticket: ticket,
                  onTap: () => _showTicketDetails(context, ticket),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _StatusChip(status: ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(ticket.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Created':
        return Colors.blue;
      case 'Assigned':
        return Colors.orange;
      case 'In Progress':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      case 'Resolved':
        return Colors.green.shade700;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
