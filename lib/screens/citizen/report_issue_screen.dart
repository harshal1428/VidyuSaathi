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
import '../../services/clustering_service.dart';
import '../../services/nlp_classification_service.dart';
import '../../models/complaint_type_model.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Data
  List<ComplaintTypeModel> _allComplaintTypes = [];
  ComplaintTypeModel? _selectedSubtype;
  
  final TextEditingController _descriptionController = TextEditingController();
  
  Position? _currentPosition;
  bool _gettingLocation = false;
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoadingTypes = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComplaintData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaintData() async {
    setState(() => _isLoadingTypes = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('COMPLAINT_TYPES').get();
      final list = snapshot.docs.map((d) => ComplaintTypeModel.fromMap(d.data())).toList();
      
      if (mounted) {
        setState(() {
          _allComplaintTypes = list;
          _isLoadingTypes = false;
        });
      }
    } catch (e) {
      print("Error fetching complaint types: $e");
      if (mounted) setState(() => _isLoadingTypes = false);
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
      
      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error getting location: $e')),
         );
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 1 image allowed')));
      return;
    }
    
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);
      if (image != null) {
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || _selectedSubtype == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location is required')));
         return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload Images
      List<String> imageUrls = [];
      for (var img in _selectedImages) {
        String fileName = '${const Uuid().v4()}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('ticket_images').child(fileName);
        await ref.putFile(File(img.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      // Manually construct NlpResult from selection
      final nlpResult = NlpResult(
        departmentId: _selectedSubtype!.departmentId,
        category: _selectedSubtype!.category,
        subtype: _selectedSubtype!.subtype,
        priority: _selectedSubtype!.priority,
        title: _selectedSubtype!.subtype,
        slaHours: _selectedSubtype!.slaHours,
        confidence: 1.0,
        method: 'manual',
        isCriticalOverride: _selectedSubtype!.priority == 'Critical',
      );

      final ticket = TicketModel(
        ticketId: const Uuid().v4(),
        title: nlpResult.title,
        description: _descriptionController.text,
        category: nlpResult.category,
        priority: nlpResult.priority,
        status: AppConstants.statusCreated,
        citizenId: user.userId,
        createdAt: DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        imageUrls: imageUrls,
        slaHours: nlpResult.slaHours,
        generatedVia: 'Citizen App',
        departmentId: nlpResult.departmentId,
        rawInputText: _descriptionController.text,
        nlpClassification: nlpResult.toMap(),
      );

      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.createTicket(ticket, nlpResult);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket created successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: _isLoadingTypes 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick Issue Search (Autocomplete)
                  Autocomplete<ComplaintTypeModel>(
                    displayStringForOption: (ComplaintTypeModel option) => option.subtype,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<ComplaintTypeModel>.empty();
                      }
                      return _allComplaintTypes.where((ComplaintTypeModel option) {
                        return option.subtype.toLowerCase().contains(textEditingValue.text.toLowerCase()) || 
                               option.category.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (ComplaintTypeModel selection) {
                      setState(() {
                        _selectedSubtype = selection;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'What is the issue?',
                          hintText: 'Type to search (e.g. pothole, garbage...)',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => _selectedSubtype == null ? 'Please select a matching issue' : null,
                        onChanged: (val) {
                          if (_selectedSubtype != null && val != _selectedSubtype!.subtype) {
                             setState(() {
                               _selectedSubtype = null; 
                             });
                          }
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 250, maxWidth: MediaQuery.of(context).size.width - 32),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final ComplaintTypeModel option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option.subtype),
                                  subtitle: Text('Category: ${option.category}'),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),



                  // Location (Moved up as requested)
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: const Text('Incident Location'),
                      subtitle: Text(_currentPosition == null ? 'Fetching precise location...' : '${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}'),
                      trailing: _gettingLocation 
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : IconButton(icon: const Icon(Icons.refresh), onPressed: _getCurrentLocation),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Additional Details (Optional)',
                      hintText: 'Provide specific details, landmarks etc.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photos
                  const Text('Attach Photo (Max 1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ..._selectedImages.map((img) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(img.path), width: 80, height: 80, fit: BoxFit.cover)
                          ),
                          Positioned(right: -2, top: -2, child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.remove(img)),
                            child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                          )),
                        ],
                      )),
                      if (_selectedImages.isEmpty)
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Report', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

}
