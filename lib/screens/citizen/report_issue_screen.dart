import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/complaint_type_model.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Complaint Data
  List<ComplaintTypeModel> _complaintTypes = [];
  ComplaintTypeModel? _selectedComplaintType;
  final TextEditingController _titleController = TextEditingController(); // For Autocomplete

  final TextEditingController _descriptionController = TextEditingController();
  
  Position? _currentPosition;
  bool _gettingLocation = false;
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComplaintTypes();
  }

  Future<void> _fetchComplaintTypes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('COMPLAINT_TYPES').get();
      final allTypes = snapshot.docs.map((d) => ComplaintTypeModel.fromMap(d.data())).toList();
      
      // Deduplicate by title
      final uniqueTypes = <String, ComplaintTypeModel>{};
      for (var type in allTypes) {
        uniqueTypes.putIfAbsent(type.title, () => type);
      }
      
      setState(() {
        _complaintTypes = uniqueTypes.values.toList();
      });
    } catch (e) {
      print("Error fetching complaint types: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() => _currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 images allowed')),
      );
      return;
    }
    
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fetch your location')),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final user = Provider.of<AuthService>(context, listen: false).currentUser;
        if (user == null) throw Exception('User not logged in');

        // Upload Images to Firebase Storage
        List<String> imageUrls = [];
        for (var i = 0; i < _selectedImages.length; i++) {
          try {
            String fileName = '${const Uuid().v4()}.jpg';
            Reference ref = FirebaseStorage.instance.ref().child('ticket_images').child(fileName);
            SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
            await ref.putFile(File(_selectedImages[i].path), metadata);
            String downloadUrl = await ref.getDownloadURL();
            imageUrls.add(downloadUrl);
          } catch (e) {
             print("Image upload failed: $e");
             throw Exception("Failed to upload image ${i + 1}. Check internet or storage permissions.");
          }
        }

        // Determine Priority from selected type or default
        String priority = 'Medium';
        String category = 'General';
        int? slaHours;
        int? slaMinutes;
        
        if (_selectedComplaintType != null && _selectedComplaintType!.title == _titleController.text) {
           priority = _selectedComplaintType!.priority;
           category = _selectedComplaintType!.category;
           
           // Simple SLA parsing
           if (_selectedComplaintType!.slaResolution.toLowerCase().contains('hour')) {
             slaHours = int.tryParse(_selectedComplaintType!.slaResolution.split(' ')[0]);
           } else if (_selectedComplaintType!.slaResolution.toLowerCase().contains('min')) {
             slaMinutes = int.tryParse(_selectedComplaintType!.slaResolution.split(' ')[0]);
           } else {
             slaHours = 24; 
           }
        } else {
          category = _titleController.text;
        }

        final ticket = TicketModel(
          ticketId: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          category: category,
          priority: priority,
          status: AppConstants.statusCreated,
          citizenId: user.userId,
          createdAt: DateTime.now(),
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          imageUrls: imageUrls,
          slaHours: slaHours,
          slaMinutes: slaMinutes,
        );

        await Provider.of<DatabaseService>(context, listen: false).createTicket(ticket);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report Submitted Successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission Failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Autocomplete for Title
              Autocomplete<ComplaintTypeModel>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<ComplaintTypeModel>.empty();
                  }
                  return _complaintTypes.where((ComplaintTypeModel option) {
                    return option.title.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (ComplaintTypeModel option) => option.title,
                onSelected: (ComplaintTypeModel selection) {
                  setState(() {
                    _selectedComplaintType = selection;
                    _titleController.text = selection.title;
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                   // Sync controllers if externally updated (e.g. by setstate reset)
                   if (textEditingController.text != _titleController.text && _titleController.text.isNotEmpty) {
                      // Only sync if main controller has value. 
                      // Warning: Mutual sync issues can happen.
                      // Ideally use the controller passed here.
                      // But we need to access text outside.
                   }
                   
                   return TextFormField(
                     controller: textEditingController,
                     focusNode: focusNode,
                     decoration: const InputDecoration(labelText: 'Issue Title (Auto-suggest)'),
                     validator: (val) {
                       if (val == null || val.isEmpty) return 'Required';
                       _titleController.text = val; // Ensure capture
                       return null;
                     },
                     onChanged: (val) {
                       _titleController.text = val;
                       if (_selectedComplaintType != null && val != _selectedComplaintType!.title) {
                         _selectedComplaintType = null;
                         setState(() {}); // refresh UI to hide priority box
                       }
                     },
                   );
                },
              ),
              const SizedBox(height: 16),
              
              // Hiding Priority and SLA from Citizen as requested
              // if (_selectedComplaintType != null)
              //    Padding(
              //      padding: const EdgeInsets.only(bottom: 16.0),
              //      child: Container(
              //        padding: const EdgeInsets.all(8),
              //        color: Colors.blue[50],
              //        child: Text("Priority: ${_selectedComplaintType!.priority} | Resolution SLA: ${_selectedComplaintType!.slaResolution}"),
              //      ),
              //    ),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Location
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Location'),
                subtitle: Text(_currentPosition != null 
                    ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Long: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                    : 'Location not fetched'),
                trailing: IconButton(
                  icon: _gettingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ),
              const Divider(),
              
              // Images
              const Text('Attach Images (Max 3)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  // Gallery option removed as per feedback to prevent fake complaints
                ],
              ),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


