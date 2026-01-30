import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants.dart';

class OfficerTicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const OfficerTicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Helper to format date
    String formatDate(DateTime dt) => DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    final hasLocation = ticket.latitude != null && ticket.longitude != null;
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket ${ticket.ticketId.substring(0, 8)}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Status
            Container(
              padding: const EdgeInsets.all(16),
              color: _getStatusColor(ticket.status).withOpacity(0.1),
              child: Row(
                children: [
                   Icon(_getStatusIcon(ticket.status), color: _getStatusColor(ticket.status), size: 32),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           "Status: ${ticket.status}",
                           style: TextStyle(
                             fontSize: 18, 
                             fontWeight: FontWeight.bold, 
                             color: _getStatusColor(ticket.status)
                           ),
                         ),
                         Text("Reference: ${ticket.ticketId}"),
                       ],
                     ),
                   )
                ],
              ),
            ),

            // Map Section (OSM) - Crucial for Officer
            if (hasLocation)
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(ticket.latitude!, ticket.longitude!),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.vidyusaathi.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(ticket.latitude!, ticket.longitude!),
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                  child: FloatingActionButton.small(
                    heroTag: "maps_btn",
                    onPressed: () async {
                      final Uri googleMapsUrl = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${ticket.latitude},${ticket.longitude}');
                      if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
                         // Show error or silent fail
                         debugPrint('Could not launch maps');
                      }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.map, color: Colors.blue),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.all(4),
                    child: Text("Lat: ${ticket.latitude!.toStringAsFixed(5)}, Long: ${ticket.longitude!.toStringAsFixed(5)}"),
                  ),
                ), // Close Positioned
              ],  // Close Stack children
            ),    // Close Stack
          )       // Close SizedBox
            else
              Container(
                height: 150,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Text("No location data available"),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Description
                  Text(
                    ticket.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.description,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  // Metadata
                  Row(
                    children: [
                        Expanded(child: _buildInfoCard(Icons.category, "Category", ticket.category)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildInfoCard(Icons.priority_high, "Priority", ticket.priority, color: _getPriorityColor(ticket.priority))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                   // Dates
                  const Divider(),
                  _buildDetailRow(Icons.person, "Citizen ID", ticket.citizenId),
                  _buildDetailRow(Icons.calendar_today, "Created On", formatDate(ticket.createdAt)),
                  if (ticket.resolvedAt != null)
                    _buildDetailRow(Icons.check_circle_outline, "Resolved On", formatDate(ticket.resolvedAt!)),
                  
                  const Divider(height: 32),

                  // Images - VITAL for checking fake complaints
                  const Text("Attached Images (Evidence)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (ticket.imageUrls != null && ticket.imageUrls!.isNotEmpty)
                    SizedBox(
                      height: 200, // Larger for officer to see details
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ticket.imageUrls!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                 // Fullscreen view logic could go here
                                 showDialog(
                                   context: context,
                                   builder: (ctx) => Dialog(child: Image.network(ticket.imageUrls![index])),
                                 );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                     Image.network(ticket.imageUrls![index], height: 200, width: 200, fit: BoxFit.cover),
                                     Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black54, padding: const EdgeInsets.all(4), child: const Text("Tap to Enlarge", style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center)))
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: const Row(children: [Icon(Icons.image_not_supported), SizedBox(width: 8), Text("No images attached by citizen")]),
                    ),

                  const SizedBox(height: 32),
                  
                  // Action Buttons (Only if officer is entitled)
                  if (user != null) 
                    _buildActionButtons(context, ticket, user, dbService),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: color?.withOpacity(0.1) ?? Colors.grey.shade50,
      ),
      child: Column(
        children: [
           Icon(icon, color: color ?? Colors.black54),
           const SizedBox(height: 4),
           Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
           Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TicketModel ticket, UserModel user, DatabaseService dbService) {
      if (ticket.status == AppConstants.statusResolved || ticket.status == AppConstants.statusClosed) {
         return const SizedBox.shrink();
      }

      // Simple status flow for demo
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
             // Logic to update status
             if (ticket.status == AppConstants.statusAssigned) {
                 dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusInProgress, officerId: user.userId);
             } else if (ticket.status == AppConstants.statusInProgress) {
                 dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusResolved, officerId: user.userId);
             }
             Navigator.pop(context);
          },
          icon: const Icon(Icons.update),
          label: Text(ticket.status == AppConstants.statusAssigned ? "Start Work" : (ticket.status == AppConstants.statusInProgress ? "Resolve Issue" : "Update Status")),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Created': return Colors.blue;
      case 'Assigned': return Colors.orange;
      case 'In Progress': return Colors.purple;
      case 'Resolved': return Colors.green[800]!;
      case 'Closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Created': return Icons.new_releases;
      case 'Assigned': return Icons.assignment_ind;
      case 'In Progress': return Icons.engineering;
      case 'Resolved': return Icons.check_circle;
      default: return Icons.info;
    }
  }
  
  Color _getPriorityColor(String priority) {
     if (priority.toLowerCase() == 'high') return Colors.red;
     if (priority.toLowerCase() == 'medium') return Colors.orange;
     return Colors.green;
  }
}
