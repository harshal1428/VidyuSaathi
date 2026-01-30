import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

class EscalationsScreen extends StatelessWidget {
  const EscalationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Hosted in dashboard scaffold
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
                'Escalation Logs',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightPrimary),
             ),
             const SizedBox(height: 16),
             Expanded(
               child: StreamBuilder<QuerySnapshot>(
                 stream: FirebaseFirestore.instance.collection('ESCALATION_LOGS')
                     .orderBy('timestamp', descending: true)
                     .snapshots(),
                 builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                     return const Center(child: CircularProgressIndicator());
                   }
                   
                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                     return Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
                           const SizedBox(height: 16),
                           Text("No escalations recorded yet.", style: TextStyle(color: Colors.grey[500])),
                           const SizedBox(height: 8),
                           const Text("Logs appear here when SLA is breached.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                         ],
                       ),
                     );
                   }

                   final logs = snapshot.data!.docs;

                   return ListView.builder(
                     itemCount: logs.length,
                     itemBuilder: (context, index) {
                       final log = logs[index].data() as Map<String, dynamic>;
                       final ticketId = log['ticketId'] ?? 'Unknown';
                       final fromUser = log['fromUser'] ?? 'System';
                       final toUser = log['toUser'] ?? 'Unknown';
                       final reason = log['reason'] ?? 'SLA Breach';
                       final Timestamp? ts = log['timestamp'];
                       final dateStr = ts != null 
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(ts.toDate()) 
                          : 'Just now';

                       return Card(
                         elevation: 2,
                         margin: const EdgeInsets.only(bottom: 12),
                         child: ListTile(
                           leading: CircleAvatar(
                             backgroundColor: Colors.red[100],
                             child: const Icon(Icons.arrow_upward, color: Colors.red),
                           ),
                           title: Text("Escalated Ticket #$ticketId", style: const TextStyle(fontWeight: FontWeight.bold)),
                           subtitle: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const SizedBox(height: 4),
                               Text("From: $fromUser  →  To: $toUser"),
                               Text("Reason: $reason", style: const TextStyle(color: Colors.red)),
                               Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                             ],
                           ),
                         ),
                       );
                     },
                   );
                 },
               ),
             ),
          ],
        ),
      ),
    );
  }
}
