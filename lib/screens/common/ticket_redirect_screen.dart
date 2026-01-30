import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/ticket_model.dart';
import '../../core/constants.dart';
import '../officer/officer_ticket_detail_screen.dart';
import '../citizen/my_reports_screen.dart';

class TicketRedirectScreen extends StatefulWidget {
  final String ticketId;

  const TicketRedirectScreen({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<TicketRedirectScreen> createState() => _TicketRedirectScreenState();
}

class _TicketRedirectScreenState extends State<TicketRedirectScreen> {

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('TICKETS').doc(widget.ticketId).get();
      if (!doc.exists) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket not found')));
           Navigator.pop(context);
        }
        return;
      }

      final ticket = TicketModel.fromMap(doc.data() as Map<String, dynamic>);
      
      if (!mounted) return;
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        Navigator.pop(context); // Should not happen if behind AuthWrapper
        return;
      }

      if (user.role == AppConstants.roleCitizen) {
         // Navigate to My Reports (Citizen view doesn't have a standalone detail screen yet, usually)
         // Assuming MyReportsScreen lists them. Or we could pass ticket to show dialog?
         // For now, go to MyReports.
         // Actually, if we have a detailed view for Citizen, use it. But we only have OfficerTicketDetailScreen.
         // Let's just go to MyReportsScreen.
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => const MyReportsScreen()),
         );
      } else {
         // Officer or Admin
         // Use Officer Ticket Detail Screen
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => OfficerTicketDetailScreen(ticket: ticket)),
         );
      }

    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
