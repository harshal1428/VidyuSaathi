import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart'; // Ensure correct import path
import '../../../models/ticket_model.dart';
import 'officer_all_tickets_screen.dart';

class OfficerActiveComplaintsScreen extends OfficerAllTicketsScreen {
  const OfficerActiveComplaintsScreen({Key? key}) : super(
    key: key,
    pageTitle: 'Active Complaints',
    filter: _isActive,
  );
  
  static bool _isActive(TicketModel t) {
    final s = t.status.toLowerCase();
    return s != 'resolved' && s != 'closed';
  }
}
