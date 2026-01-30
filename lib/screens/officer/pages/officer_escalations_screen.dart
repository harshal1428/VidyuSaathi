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
    return t.priority.toLowerCase() == 'critical' || t.status.toLowerCase() == 'escalated' || t.escalationLevel > 0;
  }
}
