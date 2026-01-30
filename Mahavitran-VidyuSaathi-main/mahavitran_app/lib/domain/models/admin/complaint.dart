class Complaint {
  final String id;
  final String assignedTo;
  final String priority;
  final int pendingDays;

  Complaint({
    required this.id,
    required this.assignedTo,
    required this.priority,
    required this.pendingDays,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      assignedTo: json['assignedTo'] as String,
      priority: json['priority'] as String,
      pendingDays: json['pendingDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignedTo': assignedTo,
      'priority': priority,
      'pendingDays': pendingDays,
    };
  }
}
