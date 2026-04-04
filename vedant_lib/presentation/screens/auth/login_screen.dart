import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth/auth_service.dart';

/// Login screen for all user types
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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Builds the Pune Municipal Corporation logo widget with fallback
  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        // Custom styled logo placeholder when image is not available
        return Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.electric_bolt,
            size: 50,
            color: Colors.white,
          ),
        );
      },
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = Provider.of<AuthService>(context, listen: false);

        bool isOfficer = _selectedRole == AppConstants.roleOfficer ||
            _selectedRole == AppConstants.roleAdmin;

        await authService.login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          isOfficer: isOfficer,
        );

        if (mounted) {
          final user = authService.currentUser;
          if (user != null) {
            if (user.role == AppConstants.roleCitizen) {
              Navigator.pushReplacementNamed(
                context,
                AppConstants.routeCitizenDashboard,
              );
            } else if (user.role == AppConstants.roleAdmin) {
              Navigator.pushReplacementNamed(
                context,
                AppConstants.routeAdminDashboard,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                AppConstants.routeOfficerDashboard,
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login Failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
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
              Center(child: _buildLogo(context)),
              const SizedBox(height: 24),
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Role Selector
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Login As',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        AppConstants.roleCitizen,
                        AppConstants.roleOfficer,
                        AppConstants.roleAdmin,
                      ]
                          .map((role) =>
                              DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
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
                          decoration: const InputDecoration(
                            labelText: 'Designation',
                            prefixIcon: Icon(Icons.work_outline),
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.officerDesignations
                              .map((des) =>
                                  DropdownMenuItem(value: des, child: Text(des)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedDesignation = val),
                          validator: (val) =>
                              val == null ? 'Please select designation' : null,
                        ),
                      ),

                    // Credentials
                    TextFormField(
                      controller: _identifierController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == AppConstants.roleCitizen
                            ? 'Email'
                            : 'Unique ID',
                        prefixIcon: Icon(
                          _selectedRole == AppConstants.roleCitizen
                              ? Icons.email
                              : Icons.badge,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: _selectedRole == AppConstants.roleCitizen
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Registration link
                    if (_selectedRole == AppConstants.roleCitizen)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeRegister,
                              );
                            },
                            child: const Text('Register'),
                          ),
                        ],
                      ),

                    // Back button
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
