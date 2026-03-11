import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = AppConstants.roleCitizen;
  String? _selectedDesignation;
  
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    super.initState();
    // Auto-redirect removed to allow explicit login/account switching
  }
  
  void _redirectUser(UserModel user) {
      if (user.role == AppConstants.roleCitizen) {
        Navigator.pushReplacementNamed(context, '/citizen_dashboard');
      } else if (user.role == AppConstants.roleAdmin) {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/officer_dashboard');
      }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        
        bool isOfficer = _selectedRole == AppConstants.roleOfficer || _selectedRole == AppConstants.roleAdmin;
        
        await authService.login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          isOfficer: isOfficer,
        );

        if (mounted) {
          // Route based on role
          final user = authService.currentUser;
          if (user != null) {
            if (user.role == AppConstants.roleCitizen) {
              Navigator.pushReplacementNamed(context, '/citizen_dashboard');
            } else if (user.role == AppConstants.roleAdmin || user.role == 'OFFICE_ADMIN' || user.designation == 'Admin') {
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/officer_dashboard');
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Logo
              Center(
                child: Image.asset(
                  'assets/images/mahavitaran_logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.electric_bolt, size: 60),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Role Selector
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Login As'),
                      items: [
                        AppConstants.roleCitizen,
                        AppConstants.roleOfficer,
                        AppConstants.roleAdmin,
                      ].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRole = val!;
                          if (_selectedRole != AppConstants.roleOfficer) {
                            _selectedDesignation = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Officer Designation Selector
                    if (_selectedRole == AppConstants.roleOfficer)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedDesignation,
                          decoration: const InputDecoration(labelText: 'Designation'),
                          items: AppConstants.officerDesignations
                              .map((des) => DropdownMenuItem(value: des, child: Text(des)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedDesignation = val),
                          validator: (val) => val == null ? 'Please select designation' : null,
                        ),
                      ),

                    // Credentials
                    TextFormField(
                      controller: _identifierController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == AppConstants.roleCitizen ? 'Email' : 'Unique ID',
                        prefixIcon: Icon(_selectedRole == AppConstants.roleCitizen ? Icons.email : Icons.badge),
                      ),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign In'),
                      ),
                    ),
                    
                    // Sign Up Button (Citizen Only)
                    if (_selectedRole == AppConstants.roleCitizen)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('New User? Sign Up'),
                        ),
                      )
                    else 
                       Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextButton(
                          onPressed: () {
                             Navigator.pop(context);
                          },
                          child: const Text('Back to Home'),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Dev Tool: Seeder Shortcut
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/seeder'),
                  icon: const Icon(Icons.dataset, size: 16),
                  label: const Text('Dev: Seed Database'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


