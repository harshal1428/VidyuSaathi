import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Pune Municipal Corporation Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo Image
                    Image.asset(
                      'assets/images/civic.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                         return Icon(
                          Icons.electric_bolt,
                          size: 80,
                          color: Theme.of(context).colorScheme.secondary,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'Official Application of\n${AppConstants.organizationName}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('User Login'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Citizen Registration'),
              ),
              
              // Seed Data Button (Hidden/Dev feature)
              if (kDebugMode)
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                       // TODO: Trigger seeder
                       Navigator.pushNamed(context, '/seeder');
                    },
                    child: const Text('Dev: Seed Data', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


