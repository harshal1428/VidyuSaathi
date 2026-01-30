import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'dashboards/ce_dashboard_screen.dart';
import 'dashboards/se_dashboard_screen.dart';
import 'dashboards/ee_dashboard_screen.dart';
import 'dashboards/dyee_dashboard_screen.dart';
import 'dashboards/je_dashboard_screen.dart';
import 'dashboards/ae_dashboard_screen.dart';
import 'dashboards/fe_dashboard_screen.dart';

import '../../widgets/common/logout_confirmation_wrapper.dart';

class OfficerDashboard extends StatelessWidget {
  const OfficerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    // Dispatch based on Role or Designation
    final role = (user.role ?? '').toUpperCase();
    final desig = (user.designation ?? '').toUpperCase();
    
    Widget dashboardWidget;

    // Map roles to dashboard widgets
    if (desig.contains('CHIEF') || desig == 'CE' || role == 'CE') {
      dashboardWidget = CEDashboardScreen(userRole: user.role ?? 'CE', userName: user.name ?? 'Chief Engineer');
    } else if (desig.contains('SUPERINTEND') || desig == 'SE' || role == 'SE') {
      dashboardWidget = SEDashboardScreen(userRole: user.role ?? 'SE', userName: user.name ?? 'Superintending Engineer');
    } else if (desig.contains('DEPUTY') || desig == 'DYEE' || desig == 'DE' || role == 'DYEE' || role == 'DE') {
       // Check DyEE BEFORE EE to match "Deputy Executive Engineer" correctly
       dashboardWidget = DyEEDashboardScreen(userRole: user.role ?? 'DyEE', userName: user.name ?? 'Deputy Executive Engineer');
    } else if (desig.contains('EXECUTIVE') || desig == 'EE' || role == 'EE') {
       dashboardWidget = EEDashboardScreen(userRole: user.role ?? 'EE', userName: user.name ?? 'Executive Engineer');
    } else if (desig.contains('ASSISTANT') || desig == 'AE' || role == 'AE') {
       dashboardWidget = AEDashboardScreen(userRole: user.role ?? 'AE', userName: user.name ?? 'Assistant Engineer');
    } else if (desig.contains('JUNIOR') || desig == 'JE' || role == 'JE') {
       dashboardWidget = JEDashboardScreen(userRole: user.role ?? 'JE', userName: user.name ?? 'Junior Engineer');
    } else if (desig.contains('FIELD') || desig == 'FE' || desig == 'TECHNICIAN' || role == 'FE') {
       dashboardWidget = FEDashboardScreen(userRole: user.role ?? 'FE', userName: user.name ?? 'Field Engineer');
    } else {
       // Default Fallback
       dashboardWidget = Scaffold(
        appBar: AppBar(title: const Text('Officer Dashboard')),
        body: Center(
          child: Text('Unknown Officer Role: ${user.designation}'),
        ),
      );
    }
    
    return LogoutConfirmationWrapper(child: dashboardWidget);
  }
}

abstract class OfficerDashboardTemplate extends StatefulWidget {
  final String userRole;
  final String userName;

  const OfficerDashboardTemplate({
    Key? key,
    required this.userRole,
    required this.userName,
  }) : super(key: key);

  Widget buildRoleSpecificContent(BuildContext context);
  String getDashboardTitle();
}


