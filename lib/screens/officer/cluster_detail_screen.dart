import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/cluster_model.dart';
import '../../models/ticket_model.dart';

class ClusterDetailScreen extends StatefulWidget {
  final ComplaintClusterModel cluster;

  const ClusterDetailScreen({Key? key, required this.cluster}) : super(key: key);

  @override
  State<ClusterDetailScreen> createState() => _ClusterDetailScreenState();
}

class _ClusterDetailScreenState extends State<ClusterDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      if (widget.cluster.ticketIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Firestore 'in' query supports up to 10 items.
      // If cluster has more, we need to batch or fetch individually.
      // For now, assuming batching logic or simpler loop if list is large.
      // Or simply iterating since we have IDs.
      
      List<TicketModel> loadedTickets = [];
      
      // Fetch in chunks of 10
      for (var i = 0; i < widget.cluster.ticketIds.length; i += 10) {
        var end = (i + 10 < widget.cluster.ticketIds.length) ? i + 10 : widget.cluster.ticketIds.length;
        var subList = widget.cluster.ticketIds.sublist(i, end);
        
        final querySnapshot = await _firestore
            .collection('TICKETS')
            .where(FieldPath.documentId, whereIn: subList)
            .get();
            
        final chunk = querySnapshot.docs.map((doc) => TicketModel.fromMap(doc.data())).toList();
        loadedTickets.addAll(chunk);
      }

      if (mounted) {
        setState(() {
          _tickets = loadedTickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cluster.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Resolve Cluster',
            onPressed: () {
               _showResolveConfirmation();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Map Section (unchanged)
          SizedBox(
            height: 250,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.cluster.centroidLatitude, widget.cluster.centroidLongitude),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vidyusaathi.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.cluster.centroidLatitude, widget.cluster.centroidLongitude),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                    ..._tickets.where((t) => t.latitude != null && t.longitude != null).map((t) => 
                      Marker(
                        point: LatLng(t.latitude!, t.longitude!),
                        width: 40,
                        height: 40,
                        child: Icon(Icons.circle, color: Colors.blue.withOpacity(0.7), size: 12),
                      )
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(widget.cluster.centroidLatitude, widget.cluster.centroidLongitude),
                      radius: widget.cluster.radiusMeters,
                      useRadiusInMeter: true,
                      color: Colors.red.withOpacity(0.2),
                      borderColor: Colors.red,
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_tickets.length} Tickets', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Status: ${widget.cluster.status}'),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _tickets.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          return Card(
                             margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             child: ExpansionTile(
                               leading: CircleAvatar(
                                  backgroundColor: AppTheme.getPriorityColor(ticket.priority).withOpacity(0.2),
                                  child: Icon(Icons.confirmation_number, size: 16, color: AppTheme.getPriorityColor(ticket.priority)),
                                ),
                                title: Text(ticket.title.isNotEmpty ? ticket.title : ticket.category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${DateFormat('MMM d, h:mm a').format(ticket.createdAt)} • ${ticket.status}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                children: [
                                   Padding(
                                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                          const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(ticket.description),
                                          const SizedBox(height: 8),
                                          if (ticket.imageUrls.isNotEmpty) ...[
                                             const Text("Images:", style: TextStyle(fontWeight: FontWeight.bold)),
                                             const SizedBox(height: 8),
                                             SizedBox(
                                               height: 100,
                                               child: ListView(
                                                 scrollDirection: Axis.horizontal,
                                                 children: ticket.imageUrls.map((url) => Padding(
                                                   padding: const EdgeInsets.only(right: 8),
                                                   child: Image.network(url, height: 100, width: 100, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.error)),
                                                 )).toList(),
                                               ),
                                             )
                                          ] else 
                                             const Text("No images attached.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                                       ],
                                     ),
                                   )
                                ],
                             ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  void _showResolveConfirmation() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Resolve Cluster?'),
        content: const Text('This will mark all tickets in this cluster as Resolved. Continue?'),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
           ElevatedButton(
             onPressed: () {
               Navigator.pop(context);
               _resolveCluster();
             }, 
             style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
             child: const Text('Resolve All')
           ),
        ],
      )
    );
  }

  Future<void> _resolveCluster() async {
    setState(() => _isLoading = true);
    try {
        // We use DatabaseService for this to ensure consistency via our new sync method
        // But DatabaseService updateTicketStatus updates ONE ticket.
        // We can just manually trigger the ClusteringService sync.
        // OR better: Update one ticket (the first one) to Resolved, and let the sync logic handle the rest!
        // This ensures code reuse.
        
        if (_tickets.isEmpty) return;
        
        // Find a ticket to trigger the update
        String triggerTicketId = _tickets.first.ticketId;
        
        // We need AuthService to get officer ID
        // Assuming we are logged in officer. 
        // Since we are in ClusterDetailScreen, we might not have direct access to Provider<AuthService> if not passed.
        // But we can try Provider.of.
        
        // Note: Adding Provider import is needed.
        // But to be safe and quick, let's just use Firestore batch update here if we want absolute control,
        // OR rely on the service we just wrote.
        // Let's use the service we wrote by updating the cluster directly? No, the service syncs FROM ticket TO cluster.
        // So we update the ticket.
        
        await _firestore.collection('TICKETS').doc(triggerTicketId).update({
           'status': 'Resolved',
           'resolvedAt': FieldValue.serverTimestamp(),
        });
        
        // Trigger sync manually just to be sure, or rely on DatabaseService wrapper.
        // Since we didn't inject DatabaseService, calling update on Firestore directly.
        // So we MUST call sync manually.
        
        // Dynamic import logic is tricky in replace_file_content if imports are missing.
        // I'll add imports in a separate block if needed.
        // For now, I'll basically replicate the sync logic or assume ClusteringService is available if I import it.
        // I will implement a local batch update here to be absolutely sure + UI update.
        
        WriteBatch batch = _firestore.batch();
        
        // Query current cluster to be sure
        batch.update(_firestore.collection('CLUSTERS').doc(widget.cluster.clusterId), {
           'status': 'Resolved',
           'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
        
        for (var t in _tickets) {
           batch.update(_firestore.collection('TICKETS').doc(t.ticketId), {
             'status': 'Resolved',
             'resolvedAt': FieldValue.serverTimestamp(),
           });
        }
        
        await batch.commit();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cluster and all tickets resolved.')));
          Navigator.pop(context); // Go back
        }

    } catch (e) {
      debugPrint("Error resolving cluster: $e");
      if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
