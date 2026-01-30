import 'package:flutter/material.dart';
import '../../../domain/models/admin/staff_member.dart';
import '../../../domain/models/admin/complaint.dart';
import '../../../data/services/admin/mock_data_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  List<StaffMember> _staffMembers = [];
  List<Complaint> _complaints = [];
  List<Map<String, dynamic>> _escalationData = [];
  String _searchQuery = '';
  String _roleFilter = 'All';

  List<StaffMember> get staffMembers => _staffMembers;
  List<Complaint> get complaints => _complaints;
  List<Map<String, dynamic>> get escalationData => _escalationData;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;

  AnalyticsProvider() {
    _loadData();
  }

  void _loadData() {
    _staffMembers = MockDataService.staffData;
    _complaints = MockDataService.activeAssignments;
    _escalationData = MockDataService.escalationChartData;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    notifyListeners();
  }

  List<StaffMember> getFilteredStaff() {
    return _staffMembers.where((staff) {
      final matchesSearch = staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'All' || staff.role == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  List<String> getUniqueRoles() {
    final roles = <String>{'All'};
    roles.addAll(_staffMembers.map((staff) => staff.role));
    return roles.toList();
  }

  void reassignComplaint(String complaintId, String newStaff) {
    final complaintIndex = _complaints.indexWhere((c) => c.id == complaintId);
    if (complaintIndex != -1) {
      _complaints[complaintIndex] = Complaint(
        id: _complaints[complaintIndex].id,
        assignedTo: newStaff,
        priority: _complaints[complaintIndex].priority,
        pendingDays: _complaints[complaintIndex].pendingDays,
      );
      notifyListeners();
    }
  }
}
