import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = AppConstants.roleCitizen;
  
  String? _selectedDepartmentId;
  String? _selectedOfficeId;
  String? _selectedDesignation;
  String? _selectedAccountId;
  
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _offices = [];
  List<Map<String, dynamic>> _hierarchyList = [];
  List<Map<String, dynamic>> _accountsList = [];
  bool _isLoadingDepts = false;
  bool _isLoadingAccounts = false;
  
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }
  
  Future<void> _fetchDepartments() async {
    setState(() => _isLoadingDepts = true);
    try {
      final snap = await FirebaseFirestore.instance.collection('DEPARTMENTS').get();
      if (mounted) {
        setState(() {
          _departments = snap.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print("Error loading departments: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDepts = false);
    }
  }

  void _onDepartmentChanged(String? deptId) {
    setState(() {
      _selectedDepartmentId = deptId;
      _selectedOfficeId = null;
      _selectedDesignation = null;
      _selectedAccountId = null;
      _offices = [];
      _hierarchyList = [];
      _accountsList = [];
      _identifierController.clear();
      if (deptId != null) {
        if (_selectedRole == AppConstants.roleOfficer) {
          var dept = _departments.firstWhere((d) => d['id'] == deptId, orElse: () => {});
          if (dept.isNotEmpty && dept['hierarchy'] != null) {
            _hierarchyList = List<Map<String, dynamic>>.from(dept['hierarchy']);
          }
        }
      }
    });

    if (deptId != null && _selectedRole == AppConstants.roleAdmin) {
      _fetchOfficesForDepartment(deptId);
    }
  }

  Future<void> _fetchOfficesForDepartment(String departmentId) async {
    setState(() {
      _isLoadingAccounts = true;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('OFFICES')
          .where('departmentId', isEqualTo: departmentId)
          .get();

      if (!mounted) return;
      setState(() {
        _offices = snap.docs.map((d) {
          final data = d.data();
          data['id'] = data['officeId'] ?? d.id;
          return data;
        }).toList();
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _offices = [];
      });
      final msg = e.code == 'permission-denied'
          ? 'Office list access denied. Deploy latest firestore.rules and try again.'
          : 'Failed to load offices. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      print('Error loading offices: $e');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _offices = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load offices. Please try again.')),
      );
      print('Error loading offices: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAccounts = false;
        });
      }
    }
  }

  Future<void> _onOfficeChanged(String? officeId) async {
    setState(() {
      _selectedOfficeId = officeId;
      _selectedAccountId = null;
      _accountsList = [];
      _identifierController.clear();
      if (officeId != null) {
        _isLoadingAccounts = true;
      }
    });

    if (officeId == null || _selectedDepartmentId == null) {
      if (mounted) {
        setState(() => _isLoadingAccounts = false);
      }
      return;
    }

    try {
      final officeAdminSnap = await FirebaseFirestore.instance
          .collection('USERS')
          .where('officeId', isEqualTo: officeId)
          .where('role', isEqualTo: 'OFFICE_ADMIN')
          .get();

      final adminRoleSnap = await FirebaseFirestore.instance
          .collection('USERS')
          .where('officeId', isEqualTo: officeId)
          .where('role', isEqualTo: AppConstants.roleAdmin)
          .get();

      if (!mounted) return;

      final combined = <String, Map<String, dynamic>>{};
      for (final doc in officeAdminSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        combined[doc.id] = data;
      }
      for (final doc in adminRoleSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        combined[doc.id] = data;
      }

      setState(() {
        _accountsList = combined.values
            .where((u) => (u['departmentId'] ?? '').toString() == _selectedDepartmentId)
            .toList();
      });
    } catch (e) {
      print('Error loading admin accounts: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAccounts = false);
    }
  }

  Future<void> _onDesignationChanged(String? designation) async {
    setState(() {
      _selectedDesignation = designation;
      _selectedAccountId = null;
      _accountsList = [];
      _identifierController.clear();
      if (designation != null) {
         _isLoadingAccounts = true;
      }
    });
    
    if (designation == null || _selectedDepartmentId == null) return;
    
    try {
      final snap = await FirebaseFirestore.instance.collection('USERS')
          .where('departmentId', isEqualTo: _selectedDepartmentId)
          .where('role', isEqualTo: designation)
          .get();
      if (mounted) {
        setState(() {
           _accountsList = snap.docs.map((d) {
             var data = d.data();
             data['id'] = d.id;
             return data;
           }).toList();
        });
      }
    } catch (e) {
      print("Error loading officers: $e");
    } finally {
      if (mounted) setState(() => _isLoadingAccounts = false);
    }
  }

  void _onAccountChanged(String? accountId) {
    setState(() {
      _selectedAccountId = accountId;
      if (accountId != null) {
        var off = _accountsList.firstWhere((o) => o['id'] == accountId);
        _identifierController.text = (off['email'] ?? '').toString();
      } else {
        _identifierController.clear();
      }
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (_selectedRole == AppConstants.roleAdmin) {
        await authService.openAdminDirect(officeId: _selectedOfficeId);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        }
        return;
      }

      if (_formKey.currentState!.validate()) {
        
        bool isOfficer = _selectedRole == AppConstants.roleOfficer || _selectedRole == AppConstants.roleAdmin;
        
        await authService.login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          isOfficer: isOfficer,
        );

        if (mounted) {
          final user = authService.currentUser;
          if (user != null) {
            if (_selectedRole == AppConstants.roleAdmin) {
              final role = user.role.toUpperCase();
              final designation = user.designation.toUpperCase();
              final isAdminUser = role == AppConstants.roleAdmin || role == 'OFFICE_ADMIN' || designation == 'ADMIN';
              final officeMatches = (_selectedOfficeId ?? '').isNotEmpty && user.officeId == _selectedOfficeId;
              if (!isAdminUser || !officeMatches) {
                await authService.logout();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selected office does not match this admin account.')),
                  );
                }
                return;
              }
            }

            if (user.role == AppConstants.roleCitizen) {
              Navigator.pushReplacementNamed(context, '/citizen_dashboard');
            } else if (user.role == AppConstants.roleAdmin || user.role == 'OFFICE_ADMIN' || user.designation == 'Admin') {
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/officer_dashboard');
            }
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
                  'assets/images/civic.png',
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
                      isExpanded: true,
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
                          _selectedDepartmentId = null;
                          _selectedOfficeId = null;
                          _selectedDesignation = null;
                          _selectedAccountId = null;
                          _accountsList = [];
                          _offices = [];
                          _hierarchyList = [];
                          _identifierController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Officer Specific Fields
                    if (_selectedRole == AppConstants.roleOfficer || _selectedRole == AppConstants.roleAdmin)
                      Column(
                        children: [
                          if (_isLoadingDepts)
                            const CircularProgressIndicator()
                          else
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedDepartmentId,
                              decoration: const InputDecoration(labelText: 'Department'),
                              items: _departments.map((dept) {
                                return DropdownMenuItem<String>(
                                  value: dept['id'],
                                  child: Text(dept['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: _onDepartmentChanged,
                              validator: (val) => val == null ? 'Please select department' : null,
                            ),
                          const SizedBox(height: 16),

                          if (_selectedRole == AppConstants.roleAdmin && _selectedDepartmentId != null)
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedOfficeId,
                              decoration: const InputDecoration(labelText: 'Office'),
                              items: _offices.map((office) {
                                return DropdownMenuItem<String>(
                                  value: office['id']?.toString(),
                                  child: Text((office['name'] ?? office['id'] ?? '').toString()),
                                );
                              }).toList(),
                              onChanged: _onOfficeChanged,
                              validator: (val) => _selectedRole == AppConstants.roleAdmin && val == null
                                  ? 'Please select office'
                                  : null,
                            ),
                          if (_selectedRole == AppConstants.roleAdmin && _selectedDepartmentId != null)
                            const SizedBox(height: 16),

                          if (_selectedRole == AppConstants.roleOfficer && _selectedDepartmentId != null)
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedDesignation,
                              decoration: const InputDecoration(labelText: 'Hierarchy (Designation)'),
                              items: _hierarchyList.map((hier) {
                                return DropdownMenuItem<String>(
                                  value: hier['role'],
                                  child: Text(hier['title'] ?? hier['role']),
                                );
                              }).toList(),
                              onChanged: _onDesignationChanged,
                              validator: (val) => val == null ? 'Please select hierarchy level' : null,
                            ),
                          if (_selectedRole == AppConstants.roleOfficer && _selectedDepartmentId != null)
                            const SizedBox(height: 16),
                          
                          if ((_selectedRole == AppConstants.roleOfficer && _selectedDesignation != null) ||
                              (_selectedRole == AppConstants.roleAdmin && _selectedOfficeId != null))
                            _isLoadingAccounts 
                              ? const CircularProgressIndicator() 
                              : DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedAccountId,
                                  decoration: InputDecoration(
                                    labelText: _selectedRole == AppConstants.roleAdmin
                                        ? 'Select Admin Account'
                                        : 'Select Officer Account',
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                  items: _accountsList.map((o) {
                                    return DropdownMenuItem<String>(
                                      value: o['id'],
                                      child: Text(
                                        '${o['name']} (${o['employeeId'] ?? o['id'] ?? 'HQ'})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onAccountChanged,
                                  validator: (val) {
                                    if (_selectedRole == AppConstants.roleOfficer && _selectedDesignation != null && val == null) {
                                      return 'Please select your identity';
                                    }
                                    if (_selectedRole == AppConstants.roleAdmin && _selectedOfficeId != null && val == null) {
                                      return 'Please select admin account';
                                    }
                                    return null;
                                  },
                                ),
                          if ((_selectedRole == AppConstants.roleOfficer && _selectedDesignation != null) ||
                              (_selectedRole == AppConstants.roleAdmin && _selectedOfficeId != null))
                            const SizedBox(height: 16),
                        ],
                      ),

                    // Credentials
                    if (_selectedRole == AppConstants.roleCitizen)
                      TextFormField(
                        controller: _identifierController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                        readOnly: false,
                      ),
                    if (_selectedRole == AppConstants.roleCitizen)
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
              if (kDebugMode)
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
