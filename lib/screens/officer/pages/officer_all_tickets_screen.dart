import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../constants/app_colors.dart';
import '../../../models/ticket_model.dart';
import '../../../models/user_model.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/smart_ticket_card.dart';

class OfficerAllTicketsScreen extends StatefulWidget {
  final String pageTitle;
  final bool Function(TicketModel)? filter;
  final String? statusQuery; // For database level optimisation if needed

  const OfficerAllTicketsScreen({
    Key? key, 
    this.pageTitle = 'All Tickets',
    this.filter,
    this.statusQuery,
  }) : super(key: key);

  @override
  State<OfficerAllTicketsScreen> createState() => _OfficerAllTicketsScreenState();
}

class _OfficerAllTicketsScreenState extends State<OfficerAllTicketsScreen> {
  bool _isMapView = false;
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final dbService = Provider.of<DatabaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.pageTitle),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSidebar : const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: dbService.getOfficerTickets(user, status: widget.statusQuery), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          var tickets = snapshot.data ?? [];
          
          if (widget.filter != null) {
            tickets = tickets.where(widget.filter!).toList();
          }

          // Apply UI Filters
          if (_selectedFilter != 'All') {
            tickets = tickets.where((t) {
              if (_selectedFilter == 'Pending') {
                return t.status == 'Created' || t.status == 'Assigned';
              } else if (_selectedFilter == 'In Progress') {
                return t.status == 'In Progress';
              } else if (_selectedFilter == 'Resolved') {
                 // Labelled as "Solved" in user request, matching "Accepted" or "Resolved"
                 return t.status == 'Resolved' || t.status == 'Completed'; 
              } else if (_selectedFilter == 'Rejected') {
                return t.status == 'Rejected';
              }
              return true;
            }).toList();
          }

          final pendingCount = tickets.where((t) => t.status == 'Created' || t.status == 'Assigned').length;
          final criticalCount = tickets.where((t) => t.priority == 'Critical').length;
          final totalCount = tickets.length;

          if (_isMapView) {
             return _buildMapView(tickets);
          }

          return RefreshIndicator(
            onRefresh: () async {
               setState(() {});
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'].map((filter) {
                         final isSelected = _selectedFilter == filter;
                         return Container(
                           margin: const EdgeInsets.only(right: 8),
                           child: ChoiceChip(
                             label: Text(filter == 'Resolved' ? 'Solved' : filter),
                             selected: isSelected,
                             onSelected: (bool selected) {
                               setState(() {
                                 _selectedFilter = selected ? filter : 'All';
                               });
                             },
                             selectedColor: Colors.blue.withOpacity(0.2),
                             backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                             labelStyle: TextStyle(
                               color: isSelected ? Colors.blue : (isDark ? Colors.white : Colors.black),
                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                             ),
                           ),
                         );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Summary Cards (Keep logically relevant to filtered view or total view?
                  // Generally simpler to show stats for the filtered view or keep as overview.
                  // User didn't specify, but filtering usually affects list. 
                  // Let's keep summary for *current filtered list* to be dynamic.
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Total',
                          value: totalCount.toString(),
                          icon: Icons.description_outlined,
                          color: AppColors.statusInfo,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Pending',
                          value: pendingCount.toString(),
                          icon: Icons.access_time,
                          color: AppColors.statusOverloaded,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'Critical',
                          value: criticalCount.toString(),
                          icon: Icons.warning_amber_outlined,
                          color: AppColors.statusCritical,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Complaints List
                  _ComplaintsList(
                    tickets: tickets,
                    onComplaintClick: (t) => _showTicketDetails(context, t),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView(List<TicketModel> tickets) {
      if (tickets.isEmpty) return const Center(child: Text("No tickets to display on map"));
      
      // Calculate center? or use first ticket? or fixed?
      // Use Pune default if none.
      double lat = 18.5204;
      double lng = 73.8567;
      
      final ticketsWithLoc = tickets.where((t) => t.latitude != null && t.longitude != null).toList();
      
      if (ticketsWithLoc.isNotEmpty) {
         lat = ticketsWithLoc.first.latitude!;
         lng = ticketsWithLoc.first.longitude!;
      }

      return FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.civiccore.app',
          ),
          MarkerLayer(
            markers: ticketsWithLoc.map((t) => Marker(
              point: LatLng(t.latitude!, t.longitude!),
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: () => _showTicketDetails(context, t),
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            )).toList(),
          ),
        ],
      );
  }

  void _showTicketDetails(BuildContext context, TicketModel ticket) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          final user = Provider.of<AuthService>(context, listen: false).currentUser;
          final dbService = Provider.of<DatabaseService>(context, listen: false);
          
          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(ticket.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(ticket.description),
                    const SizedBox(height: 20),
                    _buildDetailRow(Icons.info, 'Status', ticket.status),
                    _buildDetailRow(Icons.priority_high, 'Priority', ticket.priority),
                    if (ticket.citizenId != null) 
                       _buildDetailRow(Icons.person, 'Citizen ID', ticket.citizenId),
                    
                    const Spacer(),
                    
                    if (ticket.status != 'Resolved' && ticket.status != 'Closed') ...[
                      Row(
                        children: [
                          if (ticket.status == AppConstants.statusCreated ||
                              ticket.status == AppConstants.statusAssigned ||
                              ticket.status == AppConstants.statusAcknowledged)
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start Work'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                onPressed: () {
                                  dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusInProgress, officerId: user?.userId);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Solve'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () {
                                dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusResolved, officerId: user?.userId);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                                _showRejectDialog(context, ticket, user, dbService);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close')
                      ),
                    )
                ]
            )
          );
        }
      );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    TicketModel ticket,
    UserModel? user,
    DatabaseService dbService,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Complaint'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Enter reason for rejection',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter rejection reason')),
                );
                return;
              }
              dbService.updateTicketStatus(
                ticket.ticketId,
                'Rejected',
                officerId: user?.userId,
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSizes.sm,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.xxxl,
              fontWeight: AppFontWeights.semiBold,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintsList extends StatelessWidget {
  final List<TicketModel> tickets;
  final Function(TicketModel) onComplaintClick;

  const _ComplaintsList({
    Key? key,
    required this.tickets,
    required this.onComplaintClick,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    if (priority.contains('Critical')) return AppColors.statusCritical;
    if (priority.contains('High')) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Complaints List',
              style: TextStyle(
                fontSize: AppFontSizes.base,
                fontWeight: AppFontWeights.semiBold,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          if (tickets.isEmpty) 
             const Padding(padding: EdgeInsets.all(16), child: Text("No tickets found.")),
          ListView.builder( // Changed to builder for better performance
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return SmartTicketCard(
                ticket: ticket, 
                isDark: isDark, 
                onTap: () => onComplaintClick(ticket)
              );
            },
          ),
        ],
      ),
    );
  }
}
