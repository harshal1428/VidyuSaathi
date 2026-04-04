import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../core/constants.dart';
import 'officer_ticket_detail_screen.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  List<TicketModel> _filterTicketsForType(List<TicketModel> tickets, String type) {
    switch (type) {
      case 'pending':
        return tickets
            .where((t) =>
                t.status == AppConstants.statusCreated ||
                t.status == AppConstants.statusAssigned)
            .toList();
      case 'in_progress':
        return tickets
            .where((t) =>
                t.status == AppConstants.statusInProgress ||
                t.status == AppConstants.statusSupervisorReview)
            .toList();
      case 'completed':
        return tickets
            .where((t) =>
                t.status == AppConstants.statusResolved ||
                t.status == AppConstants.statusClosed)
            .toList();
      default:
        return tickets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final type = args['type'] as String;
    
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    String title = 'Tasks';
    Stream<List<TicketModel>>? stream;

    switch (type) {
      case 'pending':
        title = 'Pending Tasks';
        break;
      case 'escalated':
        title = 'Escalated';
        stream = dbService.getOpenEscalatedTickets(user!);
        break;
      case 'in_progress':
        title = 'In Progress';
        break;
      case 'completed':
        title = 'Resolved';
        break;
      case 'my_tasks':
      default:
        title = 'My Tasks';
        break;
    }

    stream ??= dbService.getOfficerTickets(user!);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<TicketModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sourceTickets = snapshot.data ?? [];
          final tickets = type == 'escalated'
              ? sourceTickets
              : _filterTicketsForType(sourceTickets, type);
          
          if (tickets.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }
          
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OfficerTicketDetailScreen(ticket: ticket)),
          );
        },
        child: const Text('Upload Proof & Submit'),
      ));
    } else if (ticket.status == AppConstants.statusCompleted) {
      buttons.add(ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OfficerTicketDetailScreen(ticket: ticket)),
          );
        },
        child: const Text('Open Details'),
      ));
    } else if (ticket.status == AppConstants.statusSupervisorReview) {
      buttons.add(OutlinedButton(
        onPressed: null,
        child: const Text('Awaiting Citizen Verification'),
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons.map((b) => Padding(padding: const EdgeInsets.only(left: 8), child: b)).toList(),
    );
  }
}


