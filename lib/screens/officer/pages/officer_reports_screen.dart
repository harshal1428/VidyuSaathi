import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:civic_core/constants/app_colors.dart';
import 'package:civic_core/core/constants.dart';
import 'package:civic_core/models/dashboard_stats_model.dart';
import 'package:civic_core/models/ticket_model.dart';
import 'package:civic_core/models/user_model.dart';
import 'package:civic_core/models/structure_models.dart';
import 'package:civic_core/services/auth_service.dart';
import 'package:civic_core/services/database_service.dart';
import 'package:civic_core/widgets/smart_ticket_card.dart';

class OfficerReportsScreen extends StatefulWidget {
  const OfficerReportsScreen({Key? key}) : super(key: key);

  @override
  State<OfficerReportsScreen> createState() => _OfficerReportsScreenState();
}

class _OfficerReportsScreenState extends State<OfficerReportsScreen> {
  late final Future<List<OfficeModel>> _officesFuture;
  bool _isExportingCsv = false;

  @override
  void initState() {
    super.initState();
    _officesFuture = context.read<DatabaseService>().getAllOffices();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
         title: const Text('Reports & Analytics'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DashboardStats>(
        stream: dbService.getTicketStats(user),
        builder: (context, statsSnapshot) {
          final stats = statsSnapshot.data ??
              DashboardStats(
                total: 0,
                pending: 0,
                inProgress: 0,
                resolved: 0,
                escalated: 0,
                critical: 0,
                high: 0,
                medium: 0,
                low: 0,
              );

          return StreamBuilder<List<TicketModel>>(
            stream: dbService.getOfficerTickets(user),
            builder: (context, ticketsSnapshot) {
              final tickets = ticketsSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: AppFontWeights.semiBold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Live complaint metrics and actions',
                      style: TextStyle(
                        fontSize: AppFontSizes.sm,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.5,
                      children: [
                        _buildMetricCard('Total Tickets', '${stats.total}', Icons.description, AppColors.statusInfo, isDark),
                        _buildMetricCard('Critical', '${stats.critical}', Icons.error, AppColors.statusCritical, isDark),
                        _buildMetricCard('Solved', '${stats.resolved}', Icons.check_circle, AppColors.statusNormal, isDark),
                        _buildMetricCard('Escalated', '${stats.escalated}', Icons.trending_up, Colors.red, isDark),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    _buildCsvExportCard(dbService),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'All Office Heatmap',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: AppFontWeights.semiBold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Live density of complaints by office across all backend office data.',
                      style: TextStyle(
                        fontSize: AppFontSizes.sm,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    StreamBuilder<List<TicketModel>>(
                      stream: dbService.getAllTickets(),
                      builder: (context, allTicketsSnapshot) {
                        final allTickets = allTicketsSnapshot.data ?? const <TicketModel>[];
                        return FutureBuilder<List<OfficeModel>>(
                          future: _officesFuture,
                          builder: (context, officesSnapshot) {
                            if (officesSnapshot.connectionState == ConnectionState.waiting ||
                                allTicketsSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (officesSnapshot.hasError) {
                              return _buildHeatmapInfoCard(
                                isDark,
                                'Unable to load office map data.',
                              );
                            }

                            final offices = officesSnapshot.data ?? const <OfficeModel>[];
                            if (offices.isEmpty) {
                              return _buildHeatmapInfoCard(
                                isDark,
                                'No office coordinates are configured yet.',
                              );
                            }

                            final officeCounts = _buildOfficeCounts(allTickets, offices);
                            return Column(
                              children: [
                                _buildOfficeHeatmapMap(offices, officeCounts, isDark),
                                const SizedBox(height: AppSpacing.md),
                                _buildHeatLegend(officeCounts, isDark),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: AppFontWeights.semiBold),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (tickets.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No tickets available'))),

                    ...tickets.take(8).map((ticket) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            children: [
                              SmartTicketCard(ticket: ticket, isDark: isDark, onTap: () {}),
                              _buildActionRow(user, ticket, dbService),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCsvExportCard(DatabaseService dbService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.download_for_offline_outlined),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Download complaint analytics CSV (all office data)',
              maxLines: 2,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: _isExportingCsv ? null : () => _downloadComplaintAnalyticsCsv(dbService),
            icon: _isExportingCsv
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download),
            label: Text(_isExportingCsv ? 'Exporting...' : 'Download CSV'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapInfoCard(bool isDark, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Text(text),
    );
  }

  Map<String, int> _buildOfficeCounts(List<TicketModel> tickets, List<OfficeModel> offices) {
    final counts = <String, int>{for (final office in offices) office.officeId: 0};
    for (final ticket in tickets) {
      final officeId = ticket.officeId;
      if (officeId == null || officeId.isEmpty) {
        continue;
      }
      counts[officeId] = (counts[officeId] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildOfficeHeatmapMap(List<OfficeModel> offices, Map<String, int> counts, bool isDark) {
    final center = _computeMapCenter(offices);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 320,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 11,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.civicsense.app',
            ),
            CircleLayer(
              circles: offices.map((office) {
                final count = counts[office.officeId] ?? 0;
                final color = _heatColor(count);
                final radius = _heatRadius(count);

                return CircleMarker(
                  point: LatLng(office.latitude, office.longitude),
                  radius: radius,
                  color: color.withValues(alpha: 0.35),
                  borderColor: color,
                  borderStrokeWidth: 2,
                  useRadiusInMeter: false,
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: offices.map((office) {
                final count = counts[office.officeId] ?? 0;
                return Marker(
                  point: LatLng(office.latitude, office.longitude),
                  width: 120,
                  height: 30,
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black87 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _heatColor(count), width: 1),
                    ),
                    child: Text(
                      '${office.name} ($count)',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatLegend(Map<String, int> counts, bool isDark) {
    final maxCount = counts.values.fold<int>(0, (acc, value) => value > acc ? value : acc);
    return Row(
      children: [
        _legendChip('Low', _heatColor(1), isDark),
        const SizedBox(width: 8),
        _legendChip('Medium', _heatColor((maxCount / 2).round()), isDark),
        const SizedBox(width: 8),
        _legendChip('High', _heatColor(maxCount), isDark),
      ],
    );
  }

  Widget _legendChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  LatLng _computeMapCenter(List<OfficeModel> offices) {
    if (offices.isEmpty) {
      return const LatLng(18.5204, 73.8567);
    }

    double latTotal = 0;
    double lngTotal = 0;
    for (final office in offices) {
      latTotal += office.latitude;
      lngTotal += office.longitude;
    }

    return LatLng(latTotal / offices.length, lngTotal / offices.length);
  }

  Color _heatColor(int count) {
    if (count <= 0) {
      return Colors.green;
    }
    if (count <= 5) {
      return Colors.lightGreen;
    }
    if (count <= 12) {
      return Colors.orange;
    }
    return Colors.red;
  }

  double _heatRadius(int count) {
    if (count <= 0) {
      return 8;
    }
    if (count <= 5) {
      return 12;
    }
    if (count <= 12) {
      return 16;
    }
    return 20;
  }

  Future<void> _downloadComplaintAnalyticsCsv(DatabaseService dbService) async {
    setState(() => _isExportingCsv = true);

    try {
      final tickets = await dbService.getAllTickets().first;
      final offices = await dbService.getAllOffices();
      final officeById = <String, OfficeModel>{for (final office in offices) office.officeId: office};

      final perOffice = <String, Map<String, int>>{};
      for (final ticket in tickets) {
        final officeId = (ticket.officeId ?? 'UNASSIGNED').trim().isEmpty
            ? 'UNASSIGNED'
            : ticket.officeId!.trim();

        perOffice.putIfAbsent(officeId, () => {
              'total': 0,
              'created': 0,
              'assigned': 0,
              'in_progress': 0,
              'resolved': 0,
              'closed': 0,
              'rejected': 0,
            });

        final bucket = perOffice[officeId]!;
        bucket['total'] = (bucket['total'] ?? 0) + 1;

        final status = ticket.status;
        if (status == AppConstants.statusCreated) bucket['created'] = (bucket['created'] ?? 0) + 1;
        if (status == AppConstants.statusAssigned) bucket['assigned'] = (bucket['assigned'] ?? 0) + 1;
        if (status == AppConstants.statusInProgress) bucket['in_progress'] = (bucket['in_progress'] ?? 0) + 1;
        if (status == AppConstants.statusResolved) bucket['resolved'] = (bucket['resolved'] ?? 0) + 1;
        if (status == AppConstants.statusClosed) bucket['closed'] = (bucket['closed'] ?? 0) + 1;
        if (status == 'Rejected') bucket['rejected'] = (bucket['rejected'] ?? 0) + 1;
      }

      final lines = <String>[];
      lines.add('officeId,officeName,latitude,longitude,total,created,assigned,inProgress,resolved,closed,rejected');

      final sortedKeys = perOffice.keys.toList()..sort();
      for (final officeId in sortedKeys) {
        final office = officeById[officeId];
        final metric = perOffice[officeId]!;
        lines.add([
          _escapeCsv(officeId),
          _escapeCsv(office?.name ?? 'Unknown Office'),
          _escapeCsv((office?.latitude ?? 0).toStringAsFixed(6)),
          _escapeCsv((office?.longitude ?? 0).toStringAsFixed(6)),
          metric['total'].toString(),
          metric['created'].toString(),
          metric['assigned'].toString(),
          metric['in_progress'].toString(),
          metric['resolved'].toString(),
          metric['closed'].toString(),
          metric['rejected'].toString(),
        ].join(','));
      }

      final now = DateTime.now();
      final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

      final fileName = 'complaint_analytics_$stamp.csv';
      final csvContent = lines.join('\n');

      File file;
      String? fallbackNote;

      if (Platform.isAndroid) {
        final publicDownloadsFile = File('/storage/emulated/0/Download/$fileName');
        try {
          await publicDownloadsFile.writeAsString(csvContent);
          file = publicDownloadsFile;
        } catch (_) {
          fallbackNote = 'Could not write to public Download folder; saved in app-accessible download directory.';

          final downloadDirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads,
          );
          final fallbackDir = (downloadDirs != null && downloadDirs.isNotEmpty)
              ? downloadDirs.first
              : await getApplicationDocumentsDirectory();

          if (!await fallbackDir.exists()) {
            await fallbackDir.create(recursive: true);
          }

          file = File('${fallbackDir.path.trim()}/$fileName');
          await file.writeAsString(csvContent);
        }
      } else {
        final downloadDir = await getDownloadsDirectory();
        final targetDir = downloadDir ?? await getApplicationDocumentsDirectory();
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        file = File('${targetDir.path.trim()}/$fileName');
        await file.writeAsString(csvContent);
      }

      if (!mounted) return;
      final shownPath = file.path.replaceAll('\\', '/');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fallbackNote == null
                ? 'CSV saved successfully\nPath: $shownPath'
                : 'CSV saved successfully\nPath: $shownPath\n$fallbackNote',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingCsv = false);
      }
    }
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Widget _buildActionRow(UserModel user, TicketModel ticket, DatabaseService dbService) {
    final isDone = ticket.status == AppConstants.statusResolved ||
        ticket.status == AppConstants.statusClosed ||
        ticket.status == 'Rejected';

    if (isDone) return const SizedBox.shrink();

    final canStart = ticket.status == AppConstants.statusCreated ||
        ticket.status == AppConstants.statusAssigned ||
        ticket.status == AppConstants.statusAcknowledged;

    return Row(
      children: [
        if (canStart)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => dbService.updateTicketStatus(
                ticket.ticketId,
                AppConstants.statusInProgress,
                officerId: user.userId,
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('In Progress'),
            ),
          ),
        if (canStart) const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => dbService.updateTicketStatus(
              ticket.ticketId,
              AppConstants.statusResolved,
              officerId: user.userId,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle),
            label: const Text('Solve'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showRejectDialog(ticket, user, dbService),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            icon: const Icon(Icons.cancel),
            label: const Text('Reject'),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(TicketModel ticket, UserModel user, DatabaseService dbService) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Complaint'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter rejection reason')),
                );
                return;
              }
              dbService.updateTicketStatus(
                ticket.ticketId,
                'Rejected',
                officerId: user.userId,
                rejectionReason: reason,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSizes.sm,
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.xxl,
              fontWeight: AppFontWeights.bold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }

}


