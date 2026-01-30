import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket_model.dart';
import '../../constants/app_colors.dart';

class SmartTicketCard extends StatefulWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final bool isDark;

  const SmartTicketCard({
    Key? key,
    required this.ticket,
    required this.onTap,
    required this.isDark,
  }) : super(key: key);

  @override
  State<SmartTicketCard> createState() => _SmartTicketCardState();
}

class _SmartTicketCardState extends State<SmartTicketCard> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isEscalated = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SmartTicketCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticket.ticketId != widget.ticket.ticketId) {
       _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    
    // SLA Logic
    // If ticket is resolved, no timer
    if (widget.ticket.status == 'Resolved' || widget.ticket.status == 'Closed') {
      _timer?.cancel();
      return;
    }

    if (widget.ticket.assignedAt == null) {
      // Default to created at if not assigned yet (rare but possible)
      return; 
    }

    // Determine SLA duration based on current owner role (simplified for UI)
    // Should ideally match EscalationService logic
    int slaHours = widget.ticket.slaHours ?? 24;
    // Or dynamic based on role if needed
    
    final deadline = widget.ticket.assignedAt!.add(Duration(hours: slaHours));
    final now = DateTime.now();
    
    if (now.isAfter(deadline)) {
      setState(() {
        _timeLeft = Duration.zero;
        _isEscalated = true; // Visually overdue
      });
      _timer?.cancel();
    } else {
      setState(() {
        _timeLeft = deadline.difference(now);
        _isEscalated = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Color _getPriorityColor(String priority) {
    if (priority.contains('Critical')) return AppColors.statusCritical;
    if (priority.contains('High')) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.ticket.status);
    
    return Card(
      color: widget.isDark ? AppColors.darkCard : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.blue.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(4),
                     ),
                     child: Text(
                        widget.ticket.ticketId.substring(0, 8).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                     ),
                   ),
                   _buildStatusBadge(widget.ticket.status, statusColor),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                widget.ticket.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Category & Priority
              Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(widget.ticket.category, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 12),
                  Icon(Icons.flag, size: 14, color: _getPriorityColor(widget.ticket.priority)),
                  const SizedBox(width: 4),
                  Text(widget.ticket.priority, style: TextStyle(color: _getPriorityColor(widget.ticket.priority), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              // Timer / Escalation Status
              if (widget.ticket.status != 'Resolved' && widget.ticket.status != 'Closed')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _isEscalated ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _isEscalated ? Colors.red : Colors.orange),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEscalated ? Icons.warning : Icons.timer, 
                        color: _isEscalated ? Colors.red : Colors.orange
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEscalated 
                            ? "SLA BREACHED - Escalated"
                            : "Time Remaining: ${_formatDuration(_timeLeft)}",
                        style: TextStyle(
                          color: _isEscalated ? Colors.red : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'
                        ),
                      ),
                    ],
                  ),
                ),
              
               if (widget.ticket.currentOwnerRole != null && widget.ticket.status != 'Resolved')
                 Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: Text("Current Owner: ${widget.ticket.currentOwnerRole}", style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                 ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'in progress': return Colors.blue;
      case 'escalated': return Colors.red;
      case 'assigned': return Colors.purple;
      default: return Colors.orange;
    }
  }
}
