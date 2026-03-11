import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/cluster_model.dart';
import 'cluster_detail_screen.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class ClusterListScreen extends StatefulWidget {
  const ClusterListScreen({Key? key}) : super(key: key);

  @override
  State<ClusterListScreen> createState() => _ClusterListScreenState();
}

class _ClusterListScreenState extends State<ClusterListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Clusters'),
      ),
      body: FutureBuilder<List<ComplaintClusterModel>>(
        future: Provider.of<DatabaseService>(context, listen: false).getClustersForOfficer(
            Provider.of<AuthService>(context, listen: false).currentUser!
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active clusters found for your jurisdiction.'));
          }

          final clusters = snapshot.data!
              .where((c) => c.ticketCount >= 1) // User requested to see clusters even if count is 1
              .toList();
          
          if (clusters.isEmpty) {
             return const Center(child: Text('No active complaint clusters found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clusters.length,
            itemBuilder: (context, index) {
              final cluster = clusters[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClusterDetailScreen(cluster: cluster),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.hub, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cluster.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Updated: ${DateFormat.yMMMd().add_jm().format(cluster.lastUpdatedAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${cluster.ticketCount} Tickets',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
