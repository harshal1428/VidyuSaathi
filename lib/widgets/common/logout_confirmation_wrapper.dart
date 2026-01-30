import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LogoutConfirmationWrapper extends StatelessWidget {
  final Widget child;
  const LogoutConfirmationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Do you want to log out before exiting?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'), 
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('exit'), // Just Exit
                child: const Text('Exit (Keep Signed In)', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('logout'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Log Out'),
              ),
            ],
          ),
        );

        if (result == 'logout') {
          await Provider.of<AuthService>(context, listen: false).logout();
          // AuthWrapper will handle navigation
        } else if (result == 'exit') {
           SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
