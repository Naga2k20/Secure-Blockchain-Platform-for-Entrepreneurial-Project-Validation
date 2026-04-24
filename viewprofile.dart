import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadDocumentsPage extends StatefulWidget {
  final String? name;
  final String? email;
  final String? mobile;
  final String? district;
  final String? ukey;

  const UploadDocumentsPage({
    Key? key,
    required this.name,
    required this.email,
    required this.mobile,
    required this.district,
    required this.ukey,
  }) : super(key: key);

  @override
  _UploadDocumentsPageState createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  final TextEditingController _docNameController = TextEditingController();
  final TextEditingController _docIdController = TextEditingController();
  final TextEditingController _docTypeController = TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _proofDescriptionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  File? _selectedFile;
  bool isLoading = false;
  List<String> selectedDepartments = [];
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  void _addDepartment() {
    if (_departmentController.text.isNotEmpty) {
      setState(() {
        selectedDepartments.add(_departmentController.text);
        _departmentController.clear();
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      String? userId = user?.uid;
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String dataKey = _database.child('Documents').push().key ?? '';

      Map<String, dynamic> documentData = {
        'docname': _docNameController.text,
        'docid': _docIdController.text,
        'doctype': _docTypeController.text,
        'proof': _proofDescriptionController.text,
        'docno': _docNumberController.text,
        'timestamp': timestamp,
        'status': 'pending',
        'date': formattedDate,
        'uid': userId,
      };

      if (_selectedFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('documents/$dataKey');
        await storageRef.putFile(_selectedFile!);
        documentData['fileUrl'] = await storageRef.getDownloadURL();
      }

      await _database.child('Documents').child(dataKey).set(documentData);

      setState(() {
        isLoading = false;
        _docNameController.clear();
        _docIdController.clear();
        _docTypeController.clear();
        _docNumberController.clear();
        _proofDescriptionController.clear();
        _departmentController.clear();
        selectedDepartments.clear();
        _selectedFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document uploaded successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Documents"),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[700]!, Colors.teal[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildSectionHeader("Document Details"),
              const SizedBox(height: 15),

              // Name
              _buildInputField(_docIdController, "Name", Icons.person_outline),

              // Description
              _buildInputField(_docNameController, "Description", Icons.description_outlined),

              // Location
              _buildInputField(_docNumberController, "Location", Icons.location_on_outlined),

              // Document Type
              _buildInputField(_docTypeController, "Document Type", Icons.assignment_outlined),

              // Proof Description
              _buildInputField(_proofDescriptionController, "Proof Description", Icons.note_add_outlined),




              // Selected Departments
              if (selectedDepartments.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Selected Departments:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedDepartments.map((dept) => Chip(
                      label: Text(dept),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          selectedDepartments.remove(dept);
                        });
                      },
                      backgroundColor: Colors.teal[50],
                      labelStyle: TextStyle(
                        color: Colors.teal[800],
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.teal[100]!),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 20),
              _buildSectionHeader("Document Attachment"),
              const SizedBox(height: 15),

              // Image Upload
              _buildImagePicker(),

              const SizedBox(height: 30),

              // Upload Button
              isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
                ),
              )
                  : ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.teal.withOpacity(0.3),
                ),
                child: const Text(
                  "UPLOAD DOCUMENT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.teal[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal[600]),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal[400]!, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: TextStyle(color: Colors.grey[800], fontSize: 15),
      ),
    );
  }

  Widget _buildDepartmentField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _departmentController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.assignment_ind_outlined, color: Colors.teal[600]),
                labelText: "Department Signature",
                labelStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal[400]!, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                hintText: "Enter department name",
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _departmentController.text.isNotEmpty ? Colors.teal[600] : Colors.grey[400],
              shape: BoxShape.circle,
              boxShadow: [
                if (_departmentController.text.isNotEmpty)
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _departmentController.text.isNotEmpty ? _addDepartment : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_selectedFile != null)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(_selectedFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFile = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text("Take Photo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.teal[400]!),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text("Choose from Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  shadowColor: Colors.teal.withOpacity(0.3),
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }
}