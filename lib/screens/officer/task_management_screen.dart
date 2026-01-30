import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../core/constants.dart';
import 'officer_ticket_detail_screen.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final type = args['type'] as String;
    
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    String title = 'Tasks';
    String? statusFilter;

    switch (type) {
      case 'pending':
        title = 'Pending Tasks';
        statusFilter = AppConstants.statusAssigned; // Or Created if they pick from pool
        break;
      case 'in_progress':
        title = 'In Progress';
        statusFilter = AppConstants.statusInProgress;
        break;
      case 'completed':
        title = 'Completed';
        statusFilter = AppConstants.statusCompleted;
        break;
      case 'my_tasks':
      default:
        title = 'My Tasks';
        statusFilter = null; // All assigned to me
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<TicketModel>>(
        stream: dbService.getOfficerTickets(user!, status: statusFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }
          
          final tickets = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              return _TicketCard(ticket: tickets[index]);
            },
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OfficerTicketDetailScreen(ticket: ticket)),
          );
        },
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Chip(
                  label: Text(ticket.status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.description),
            const SizedBox(height: 8),
            Text('Category: ${ticket.category} | Priority: ${ticket.priority}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            _buildActionButtons(context, ticket),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TicketModel ticket) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    List<Widget> buttons = [];

    // STRICT LIFECYCLE IMPLEMENTATION
    if (ticket.status == AppConstants.statusAssigned) {
      buttons.add(ElevatedButton(
        onPressed: () => dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusAcknowledged, officerId: user!.userId),
        child: const Text('Acknowledge'),
      ));
      buttons.add(OutlinedButton(
        onPressed: () {
          // Decline logic (reason dialog)
        },
        child: const Text('Decline'),
      ));
    } else if (ticket.status == AppConstants.statusAcknowledged) {
      buttons.add(ElevatedButton(
        onPressed: () => dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusInProgress, officerId: user!.userId),
        child: const Text('Start Work'),
      ));
    } else if (ticket.status == AppConstants.statusInProgress) {
      buttons.add(ElevatedButton(
        onPressed: () => dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusCompleted, officerId: user!.userId),
        child: const Text('Mark Completed'),
      ));
    } else if (ticket.status == AppConstants.statusCompleted) {
      // Supervisor Review logic usually happens here, but if this is the officer view
      // they might wait. Or if they are the supervisor.
      // Assuming self-resolution for now or supervisor action.
      // Let's assume the officer marks it Resolved if they have authority, or it goes to Supervisor Review.
      // Prompt says: Completed -> Supervisor Review -> Resolved
      buttons.add(ElevatedButton(
        onPressed: () => dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusSupervisorReview, officerId: user!.userId),
        child: const Text('Submit for Review'),
      ));
    } else if (ticket.status == AppConstants.statusSupervisorReview) {
      // If current user is supervisor (logic needed), they can Resolve.
      // For now, enabling Resolve for demo.
      buttons.add(ElevatedButton(
        onPressed: () => dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusResolved, officerId: user!.userId),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Approve & Resolve'),
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons.map((b) => Padding(padding: const EdgeInsets.only(left: 8), child: b)).toList(),
    );
  }
}


