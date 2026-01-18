import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTitle;
  final TextEditingController _descriptionController = TextEditingController();
  
  Position? _currentPosition;
  bool _gettingLocation = false;
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  bool _isSubmitting = false;

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
            // Ensure the Reference is valid.
            Reference ref = FirebaseStorage.instance.ref().child('ticket_images').child(fileName);
            
            // Set metadata to ensure the server treats it as an image
            SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

            await ref.putFile(File(_selectedImages[i].path), metadata);
            String downloadUrl = await ref.getDownloadURL();
            imageUrls.add(downloadUrl);
          } catch (e) {
             print("Image upload failed: $e");
             // Decide whether to fail the whole ticket or just skip the image.
             // For strict correctness, we fail explaining why.
             throw Exception("Failed to upload image ${i + 1}. Check internet or storage permissions.");
          }
        }

        final ticket = TicketModel(
          ticketId: const Uuid().v4(),
          title: _selectedTitle!,
          description: _descriptionController.text,
          category: _selectedTitle!, // Using title as category for now
          priority: 'Medium',
          status: AppConstants.statusCreated,
          citizenId: user.userId,
          createdAt: DateTime.now(),
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          imageUrls: imageUrls,
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
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                decoration: const InputDecoration(labelText: 'Issue Title'),
                items: AppConstants.ticketCategories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTitle = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
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
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
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
