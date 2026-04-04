import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/dashboard_stats_model.dart';
import '../../models/ticket_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isExporting = false;

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<Directory> _getPreferredDirectory() async {
    if (!kIsWeb && Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) {
        return downloads;
      }
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        return ext;
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  Future<void> _downloadTicketReport(
    BuildContext context,
    String reportKey,
    String title,
    List<TicketModel> tickets,
  ) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final now = DateTime.now();
      final fileName = 'admin_${reportKey}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.csv';
      final lines = <String>[
        'ticketId,title,status,priority,departmentId,officeId,regionId,circleId,divisionId,citizenId,currentOwnerId,createdAt',
      ];

      for (final t in tickets) {
        lines.add([
          _escapeCsv(t.ticketId),
          _escapeCsv(t.title),
          _escapeCsv(t.status),
          _escapeCsv(t.priority),
          _escapeCsv(t.departmentId),
          _escapeCsv(t.officeId ?? ''),
          _escapeCsv(t.regionId ?? ''),
          _escapeCsv(t.circleId ?? ''),
          _escapeCsv(t.divisionId ?? ''),
          _escapeCsv(t.citizenId),
          _escapeCsv(t.currentOwnerId ?? ''),
          _escapeCsv(t.createdAt.toIso8601String()),
        ].join(','));
      }

      final dir = await _getPreferredDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(lines.join('\n'));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title report downloaded: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download report: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
       body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
                'System Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightPrimary),
             ),
             const SizedBox(height: 16),
             Expanded(
               child: StreamBuilder<List<TicketModel>>(
                 stream: dbService.getTicketsForAdmin(user),
                 builder: (context, ticketSnapshot) {
                   if (!ticketSnapshot.hasData) {
                     return const Center(child: CircularProgressIndicator());
                   }

                   final tickets = ticketSnapshot.data!;

                   final pendingTickets = tickets.where((t) {
                     final s = t.status.toLowerCase();
                     return s != 'resolved' && s != 'closed' && s != 'rejected';
                   }).toList();
                   final resolvedTickets = tickets.where((t) {
                     final s = t.status.toLowerCase();
                     return s == 'resolved' || s == 'closed';
                   }).toList();
                   final escalatedTickets = tickets.where((t) {
                     return t.status.toLowerCase() == 'escalated' || t.escalationLevel > 0;
                   }).toList();

                   final stats = DashboardStats(
                     total: tickets.length,
                     pending: pendingTickets.length,
                     inProgress: tickets.where((t) => t.status.toLowerCase() == 'in progress').length,
                     resolved: resolvedTickets.length,
                     escalated: escalatedTickets.length,
                     critical: tickets.where((t) => t.priority.toLowerCase() == 'critical').length,
                     high: tickets.where((t) => t.priority.toLowerCase() == 'high').length,
                     medium: tickets.where((t) => t.priority.toLowerCase() == 'medium').length,
                     low: tickets.where((t) => t.priority.toLowerCase() == 'low').length,
                   );

                   return GridView.count(
                     crossAxisCount: 2,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                     children: [
                       _buildReportCard(
                         context: context,
                         icon: Icons.assignment_late,
                         title: 'Pending Tickets',
                         subtitle: '${stats.pending} Tickets',
                         color: Colors.red,
                         isBusy: _isExporting,
                         onTap: () => _downloadTicketReport(context, 'pending', 'Pending Tickets', pendingTickets),
                       ),
                       _buildReportCard(
                         context: context,
                         icon: Icons.check_circle,
                         title: 'Resolved Performance',
                         subtitle: '${stats.resolved} Resolved',
                         color: Colors.blue,
                         isBusy: _isExporting,
                         onTap: () => _downloadTicketReport(context, 'resolved', 'Resolved Performance', resolvedTickets),
                       ),
                       _buildReportCard(
                         context: context,
                         icon: Icons.pie_chart,
                         title: 'Total Volume',
                         subtitle: '${stats.total} Complaints',
                         color: Colors.orange,
                         isBusy: _isExporting,
                         onTap: () => _downloadTicketReport(context, 'total', 'Total Volume', tickets),
                       ),
                       _buildReportCard(
                         context: context,
                         icon: Icons.trending_up,
                         title: 'Escalations',
                         subtitle: '${stats.escalated} Escalated',
                         color: Colors.purple,
                         isBusy: _isExporting,
                         onTap: () => _downloadTicketReport(context, 'escalations', 'Escalations', escalatedTickets),
                       ),
                     ],
                   );
                 },
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isBusy,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                isBusy ? 'Downloading...' : 'Download CSV',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
