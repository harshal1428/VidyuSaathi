import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// A widget that allows switching between different user roles (Admin, Officer, Citizen)
/// This is useful for development/testing purposes to quickly switch between different views
class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horiz,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Switch Role',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEV',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RoleButton(
                  icon: Icons.admin_panel_settings,
                  label: 'Admin',
                  color: Colors.purple,
                  onTap: () => _switchToAdmin(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RoleButton(
                  icon: Icons.engineering,
                  label: 'Officer',
                  color: Colors.blue,
                  onTap: () => _showOfficerRoleSelector(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RoleButton(
                  icon: Icons.person,
                  label: 'Citizen',
                  color: Colors.green,
                  onTap: () => _switchToCitizen(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _switchToAdmin(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppConstants.routeAdminDashboard,
      (route) => false,
    );
  }

  void _switchToCitizen(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppConstants.routeCitizenDashboard,
      (route) => false,
    );
  }

  void _showOfficerRoleSelector(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _OfficerRoleSelectorSheet(),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficerRoleSelectorSheet extends StatelessWidget {
  const _OfficerRoleSelectorSheet();

  @override
  Widget build(BuildContext context) {
    // Officer Hierarchy: CE (District) -> SE (Circle) -> EE/DyEE (Region) -> AE/JE/FE (Office)
    final officerRoles = [
      {'role': 'CE', 'title': 'Chief Engineer', 'icon': Icons.account_balance, 'level': 'District Level'},
      {'role': 'SE', 'title': 'Superintending Engineer', 'icon': Icons.admin_panel_settings, 'level': 'Circle Level'},
      {'role': 'EE', 'title': 'Executive Engineer', 'icon': Icons.manage_accounts, 'level': 'Region Level'},
      {'role': 'DYEE', 'title': 'Dy. Executive Engineer', 'icon': Icons.supervisor_account, 'level': 'Region Level'},
      {'role': 'AE', 'title': 'Assistant Engineer', 'icon': Icons.assignment_ind, 'level': 'Office Level'},
      {'role': 'JE', 'title': 'Junior Engineer', 'icon': Icons.engineering, 'level': 'Office Level'},
      {'role': 'FE', 'title': 'Field Officer', 'icon': Icons.work, 'level': 'Office Level'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.engineering,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Officer Role',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: officerRoles.length,
            itemBuilder: (context, index) {
              final role = officerRoles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(
                    role['icon'] as IconData,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: Text(
                  role['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      role['role'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role['level'] as String,
                        style: TextStyle(color: Colors.blue.shade600, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToOfficerDashboard(
                    context,
                    role['role'] as String,
                    role['title'] as String,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToOfficerDashboard(BuildContext context, String role, String title) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppConstants.routeOfficerDashboard,
      (route) => false,
      arguments: {'role': role, 'name': title},
    );
  }
}

/// A compact inline role switcher for app bars
class CompactRoleSwitcher extends StatelessWidget {
  const CompactRoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.swap_horiz),
      tooltip: 'Switch Role',
      onSelected: (value) => _handleSelection(context, value),
      itemBuilder: (context) => [
        _buildPopupItem(context, 'admin', Icons.admin_panel_settings, 'Admin', Colors.purple),
        const PopupMenuDivider(),
        _buildPopupItem(context, 'citizen', Icons.person, 'Citizen', Colors.green),
        const PopupMenuDivider(),
        _buildPopupItem(context, 'officer_ce', Icons.account_balance, 'Chief Engineer', Colors.blue),
        _buildPopupItem(context, 'officer_se', Icons.admin_panel_settings, 'Superintending Engineer', Colors.blue),
        _buildPopupItem(context, 'officer_ee', Icons.manage_accounts, 'Executive Engineer', Colors.blue),
        _buildPopupItem(context, 'officer_dyee', Icons.supervisor_account, 'Dy. Executive Engineer', Colors.blue),
        _buildPopupItem(context, 'officer_ae', Icons.assignment_ind, 'Assistant Engineer', Colors.blue),
        _buildPopupItem(context, 'officer_je', Icons.engineering, 'Junior Engineer', Colors.blue),
        _buildPopupItem(context, 'officer_fe', Icons.work, 'Field Officer', Colors.blue),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    BuildContext context,
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  void _handleSelection(BuildContext context, String value) {
    if (value == 'admin') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppConstants.routeAdminDashboard,
        (route) => false,
      );
    } else if (value == 'citizen') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppConstants.routeCitizenDashboard,
        (route) => false,
      );
    } else if (value.startsWith('officer_')) {
      final role = value.replaceFirst('officer_', '').toUpperCase();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppConstants.routeOfficerDashboard,
        (route) => false,
        arguments: {'role': role, 'name': 'Test Officer'},
      );
    }
  }
}
