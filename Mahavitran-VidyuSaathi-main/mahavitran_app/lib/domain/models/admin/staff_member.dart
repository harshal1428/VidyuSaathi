class StaffMember {
  final int id;
  final String name;
  final String role;
  final String email;
  final int activeComplaints;
  final int resolvedComplaints;
  final int escalations;
  final String status;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.activeComplaints,
    required this.resolvedComplaints,
    required this.escalations,
    required this.status,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      activeComplaints: json['activeComplaints'] as int,
      resolvedComplaints: json['resolvedComplaints'] as int,
      escalations: json['escalations'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'activeComplaints': activeComplaints,
      'resolvedComplaints': resolvedComplaints,
      'escalations': escalations,
      'status': status,
    };
  }
}
