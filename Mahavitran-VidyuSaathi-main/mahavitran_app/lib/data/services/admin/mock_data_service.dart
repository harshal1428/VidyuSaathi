import '../../../domain/models/admin/staff_member.dart';
import '../../../domain/models/admin/complaint.dart';

class MockDataService {
  static final List<StaffMember> staffData = [
    StaffMember(
      id: 1,
      name: 'Rajesh Kumar',
      role: 'Officer',
      email: 'rajesh.kumar@mahavitaran.gov.in',
      activeComplaints: 12,
      resolvedComplaints: 45,
      escalations: 3,
      status: 'Normal',
    ),
    StaffMember(
      id: 2,
      name: 'Priya Sharma',
      role: 'Field Officer',
      email: 'priya.sharma@mahavitaran.gov.in',
      activeComplaints: 18,
      resolvedComplaints: 62,
      escalations: 7,
      status: 'Overloaded',
    ),
    StaffMember(
      id: 3,
      name: 'Amit Deshmukh',
      role: 'Officer',
      email: 'amit.deshmukh@mahavitaran.gov.in',
      activeComplaints: 8,
      resolvedComplaints: 38,
      escalations: 2,
      status: 'Normal',
    ),
    StaffMember(
      id: 4,
      name: 'Sneha Patil',
      role: 'Field Officer',
      email: 'sneha.patil@mahavitaran.gov.in',
      activeComplaints: 15,
      resolvedComplaints: 51,
      escalations: 5,
      status: 'Overloaded',
    ),
    StaffMember(
      id: 5,
      name: 'Vikram Joshi',
      role: 'Officer',
      email: 'vikram.joshi@mahavitaran.gov.in',
      activeComplaints: 10,
      resolvedComplaints: 42,
      escalations: 1,
      status: 'Normal',
    ),
    StaffMember(
      id: 6,
      name: 'Anjali Mehta',
      role: 'Field Officer',
      email: 'anjali.mehta@mahavitaran.gov.in',
      activeComplaints: 14,
      resolvedComplaints: 48,
      escalations: 4,
      status: 'Normal',
    ),
  ];

  static final List<Complaint> activeAssignments = [
    Complaint(
      id: 'C2024-001',
      assignedTo: 'Rajesh Kumar',
      priority: 'High',
      pendingDays: 3,
    ),
    Complaint(
      id: 'C2024-002',
      assignedTo: 'Priya Sharma',
      priority: 'Critical',
      pendingDays: 5,
    ),
    Complaint(
      id: 'C2024-003',
      assignedTo: 'Amit Deshmukh',
      priority: 'Medium',
      pendingDays: 2,
    ),
    Complaint(
      id: 'C2024-004',
      assignedTo: 'Sneha Patil',
      priority: 'High',
      pendingDays: 4,
    ),
    Complaint(
      id: 'C2024-005',
      assignedTo: 'Vikram Joshi',
      priority: 'Low',
      pendingDays: 1,
    ),
    Complaint(
      id: 'C2024-006',
      assignedTo: 'Anjali Mehta',
      priority: 'Medium',
      pendingDays: 3,
    ),
    Complaint(
      id: 'C2024-007',
      assignedTo: 'Priya Sharma',
      priority: 'High',
      pendingDays: 6,
    ),
    Complaint(
      id: 'C2024-008',
      assignedTo: 'Sneha Patil',
      priority: 'Critical',
      pendingDays: 7,
    ),
  ];

  static final List<Map<String, dynamic>> escalationChartData = [
    {'day': 'Mon', 'escalations': 4},
    {'day': 'Tue', 'escalations': 6},
    {'day': 'Wed', 'escalations': 3},
    {'day': 'Thu', 'escalations': 8},
    {'day': 'Fri', 'escalations': 5},
    {'day': 'Sat', 'escalations': 2},
    {'day': 'Sun', 'escalations': 3},
  ];
}
