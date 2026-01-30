import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyusaathi/constants/app_colors.dart';
import 'package:vidyusaathi/models/ticket_model.dart';
import 'package:vidyusaathi/services/auth_service.dart';
import 'package:vidyusaathi/services/database_service.dart';
import 'package:vidyusaathi/widgets/smart_ticket_card.dart';
import '../officer_ticket_detail_screen.dart';

class OfficerTaskManagementScreen extends StatelessWidget {
  const OfficerTaskManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Task Management'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: dbService.getOfficerTickets(user), // Fetch tickets for this officer
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.assignment_turned_in, size: 80, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text("No tasks assigned", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return SmartTicketCard(
                ticket: ticket,
                isDark: isDark,
                onTap: () {
                   // Navigate to Detail Screen
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => OfficerTicketDetailScreen(ticket: ticket)),
                   );
                },
              );
            },
          );
        },
      ),
    );
  }
}
