import 'package:flutter/material.dart';
import '../../../models/ticket_model.dart';
import 'officer_all_tickets_screen.dart';

class OfficerEscalationsScreen extends OfficerAllTicketsScreen {
  const OfficerEscalationsScreen({Key? key}) : super(
    key: key,
    pageTitle: 'Escalations / Critical',
    filter: _isCriticalOrEscalated,
  );
  
  static bool _isCriticalOrEscalated(TicketModel t) {
    final isClosed = t.status.toLowerCase() == 'resolved' ||
        t.status.toLowerCase() == 'closed' ||
        t.status.toLowerCase() == 'rejected';
    final isEscalatedNow = t.status.toLowerCase() == 'escalated' || t.escalationLevel > 0;
    return t.priority.toLowerCase() == 'critical' || (!isClosed && isEscalatedNow);
  }
}
