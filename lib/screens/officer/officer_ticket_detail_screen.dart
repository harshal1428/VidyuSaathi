import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
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
    final isPendingOrNew = ticket.status == AppConstants.statusCreated ||
      ticket.status == AppConstants.statusAssigned;
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
                          userAgentPackageName: 'com.civiccore.app',
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

                  if (isPendingOrNew) ...[
                    const Text(
                      "Previously Solved Nearby/Similar Complaints",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<TicketModel>>(
                      future: dbService.getPreviouslySolvedComplaints(sourceTicket: ticket, limit: 8),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Could not load historical resolved complaints.',
                              style: TextStyle(color: Colors.orange.shade800),
                            ),
                          );
                        }

                        final solved = snapshot.data ?? [];
                        if (solved.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('No similar resolved complaints found for this location/title.'),
                          );
                        }

                        return Column(
                          children: solved.map((resolvedTicket) {
                            final resolvedOn = resolvedTicket.resolvedAt ?? resolvedTicket.createdAt;
                            final distanceText = _buildDistanceText(ticket, resolvedTicket);
                            final hasProofImage = resolvedTicket.resolutionImageUrls.isNotEmpty;
                            final hasProofText = resolvedTicket.resolutionDescription != null &&
                                resolvedTicket.resolutionDescription!.trim().isNotEmpty;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OfficerTicketDetailScreen(ticket: resolvedTicket),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.history_toggle_off, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              resolvedTicket.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${resolvedTicket.category} • Resolved ${formatDate(resolvedOn)}${distanceText.isEmpty ? '' : ' • $distanceText'}',
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                      if (hasProofText) ...[
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Earlier Officer Resolution:',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          resolvedTicket.resolutionDescription!,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      if (hasProofImage) ...[
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            resolvedTicket.resolutionImageUrls.first,
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

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
                  if (ticket.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 200, // Larger for officer to see details
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ticket.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                 // Fullscreen view logic could go here
                                 showDialog(
                                   context: context,
                                   builder: (ctx) => Dialog(child: Image.network(ticket.imageUrls[index])),
                                 );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                     Image.network(ticket.imageUrls[index], height: 200, width: 200, fit: BoxFit.cover),
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
      if (ticket.status == AppConstants.statusResolved || ticket.status == AppConstants.statusClosed || ticket.status == 'Rejected') {
         // If rejected, show reason
         if (ticket.status == 'Rejected' && ticket.rejectionReason != null) {
            return Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ticket Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Reason: ${ticket.rejectionReason}"),
                ],
              ),
            );
         }
         return const SizedBox.shrink();
      }

      return Column(
        children: [
          // Main Action (Advance Status)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                 // Logic to update status
                 if (ticket.status == AppConstants.statusAssigned || ticket.status == AppConstants.statusCreated) {
                     dbService.updateTicketStatus(ticket.ticketId, AppConstants.statusInProgress, officerId: user.userId);
                 } else if (ticket.status == AppConstants.statusInProgress) {
                   _showResolutionSubmissionDialog(context, ticket, user, dbService);
                   return;
                 }
                 Navigator.pop(context);
              },
              icon: const Icon(Icons.update),
                label: Text(ticket.status == AppConstants.statusAssigned || ticket.status == AppConstants.statusCreated ? "Mark In Progress" : (ticket.status == AppConstants.statusInProgress ? "Submit Resolution Proof" : "Update Status")),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Reject Action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, ticket, user, dbService),
              icon: const Icon(Icons.cancel),
              label: const Text("Reject Complaint"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      );
  }

  String _buildDistanceText(TicketModel source, TicketModel candidate) {
    if (source.latitude == null ||
        source.longitude == null ||
        candidate.latitude == null ||
        candidate.longitude == null) {
      return '';
    }

    final distanceKm = const Distance().as(
      LengthUnit.Kilometer,
      LatLng(source.latitude!, source.longitude!),
      LatLng(candidate.latitude!, candidate.longitude!),
    );

    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }
    return '${distanceKm.toStringAsFixed(2)} km away';
  }

  Future<List<String>> _uploadResolutionImages(String ticketId, List<XFile> images) async {
    final List<String> uploaded = [];
    for (int i = 0; i < images.length; i++) {
      final x = images[i];
      final ext = x.path.contains('.') ? x.path.split('.').last : 'jpg';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
      final ref = FirebaseStorage.instance
          .ref()
          .child('resolution_images')
          .child(ticketId)
          .child(fileName);
      await ref.putFile(File(x.path));
      uploaded.add(await ref.getDownloadURL());
    }
    return uploaded;
  }

  void _showResolutionSubmissionDialog(
    BuildContext context,
    TicketModel ticket,
    UserModel user,
    DatabaseService dbService,
  ) {
    final descriptionController = TextEditingController();
    final picker = ImagePicker();
    final List<XFile> selectedImages = [];
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickImage(ImageSource source) async {
              final x = await picker.pickImage(
                source: source,
                imageQuality: 65,
                maxWidth: 1600,
                maxHeight: 1600,
              );
              if (x != null) {
                setDialogState(() => selectedImages.add(x));
              }
            }

            return AlertDialog(
              title: const Text('Submit Resolution Proof'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add what work was completed and upload solved-site image(s). Citizen will be notified with this proof.'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Resolution Description',
                        hintText: 'Example: Replaced damaged cable and restored streetlight connection.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting ? null : () => pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting ? null : () => pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedImages.isEmpty)
                      const Text('No solved image selected yet.')
                    else
                      SizedBox(
                        height: 88,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(selectedImages.length, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(selectedImages[i].path),
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        cacheWidth: 176,
                                        cacheHeight: 176,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: isSubmitting
                                            ? null
                                            : () => setDialogState(() => selectedImages.removeAt(i)),
                                        child: Container(
                                          color: Colors.black54,
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final description = descriptionController.text.trim();
                          if (description.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Resolution description is required.')),
                            );
                            return;
                          }
                          if (selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Upload at least one solved image.')),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            final imageUrls = await _uploadResolutionImages(ticket.ticketId, selectedImages);
                            await dbService.submitResolutionForVerification(
                              ticketId: ticket.ticketId,
                              officerId: user.userId,
                              resolutionDescription: description,
                              resolutionImageUrls: imageUrls,
                            );

                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Work marked resolved and citizen notified with proof.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to submit proof: $e')),
                              );
                            }
                            setDialogState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, TicketModel ticket, UserModel user, DatabaseService dbService) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Complaint"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please provide a reason for rejecting this complaint. The citizen will be notified."),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Rejection Reason",
                border: OutlineInputBorder(),
                hintText: "e.g., Fake details, Duplicate, Not in jurisdiction",
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reason is required")),
                );
                return;
              }
              dbService.updateTicketStatus(
                ticket.ticketId, 
                'Rejected', 
                officerId: user.userId,
                rejectionReason: reasonController.text.trim(),
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Reject"),
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
