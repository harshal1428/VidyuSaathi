import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../models/ticket_model.dart';

class CitizenTicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const CitizenTicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Helper to format date
    String formatDate(DateTime dt) => DateFormat('dd MMM yyyy, hh:mm a').format(dt);

    final hasLocation = ticket.latitude != null && ticket.longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
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
                         Text("Reference ID: ${ticket.ticketId.substring(0, 8)}"),
                       ],
                     ),
                   )
                ],
              ),
            ),

            // Map Section (OSM)
            if (hasLocation)
              SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(ticket.latitude!, ticket.longitude!),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.civiccore.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(ticket.latitude!, ticket.longitude!),
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              )
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

                  // Dates
                  _buildDetailRow(Icons.calendar_today, "Submitted On", formatDate(ticket.createdAt)),
                  if (ticket.assignedAt != null)
                    _buildDetailRow(Icons.assignment_ind, "Assigned On", formatDate(ticket.assignedAt!)),
                  if (ticket.resolvedAt != null)
                    _buildDetailRow(Icons.check_circle_outline, "Resolved On", formatDate(ticket.resolvedAt!)),
                  
                  const Divider(height: 32),

                  // Images
                  if (ticket.imageUrls.isNotEmpty) ...[
                    const Text("Attached Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ticket.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(ticket.imageUrls[index], height: 120, width: 120, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Assignment Detail
                  if (ticket.officeId != null)
                     _buildDetailRow(Icons.business, "Assigned Office", ticket.officeId!),

                  const SizedBox(height: 16),
                  if ((ticket.resolutionDescription != null && ticket.resolutionDescription!.trim().isNotEmpty) ||
                      ticket.resolutionImageUrls.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text("Officer Resolution Proof", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (ticket.resolutionDescription != null && ticket.resolutionDescription!.trim().isNotEmpty)
                      _buildDetailRow(Icons.description_outlined, "Work Done", ticket.resolutionDescription!.trim()),
                    if (ticket.resolutionImageUrls.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ticket.resolutionImageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  ticket.resolutionImageUrls[index],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Created': return Colors.blue;
      case 'Assigned': return Colors.orange;
      case 'In Progress': return Colors.purple;
      case 'Completed': return Colors.green;
      case 'Resolved': return Colors.green[800]!;
      case 'Closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Created': return Icons.new_releases;
      case 'Assigned': return Icons.assignment_ind;
      case 'Resolved': return Icons.check_circle;
      default: return Icons.info;
    }
  }
}
