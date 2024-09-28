import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:final65131799/database/database_helper.dart';
import 'package:final65131799/database/model.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({Key? key}) : super(key: key);

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  File? _image;
  List<int> _selectedLandUses = [];

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    super.dispose();
  }

  Future<void> _getImage(bool isCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // พื้นหลังสีอ่อน
      appBar: AppBar(
        title: const Text(
          'Add New Plant',
          style: TextStyle(
            color: Colors.white, // เปลี่ยนสีข้อความเป็นสีขาว
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white, // เปลี่ยนสี foreground เป็นสีขาว
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // ปรับ padding ให้เหมือนกับ EditPlantScreen
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Plant Name'),
                const SizedBox(height: 20),
                _buildTextField(_scientificNameController, 'Scientific Name'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.white), // ไอคอนสีขาว
                      label: const Text(
                        'Camera',
                        style: TextStyle(color: Colors.white), // ตัวอักษรสีขาว
                      ),
                      onPressed: () => _getImage(true),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.image, color: Colors.white), // ไอคอนสีขาว
                      label: const Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white), // ตัวอักษรสีขาว
                      ),
                      onPressed: () => _getImage(false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_image != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // ขอบโค้งมนสำหรับภาพ
                      child: Image.file(
                        _image!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Select Land Uses:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildLandUseCheckboxes(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // ปุ่มโค้งมน
                      ),
                    ),
                    child: const Text(
                      'Add Plant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ตัวอักษรสีขาว
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $label';
        }
        return null;
      },
    );
  }

  Widget _buildLandUseCheckboxes() {
    return FutureBuilder<List<LandUseType>>(
      future: DatabaseHelper().getLandUseTypes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No land use types available');
        } else {
          return Column(
            children: snapshot.data!.map((landUseType) {
              return CheckboxListTile(
                title: Text(landUseType.landUseTypeName),
                value: _selectedLandUses.contains(landUseType.landUseTypeID),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedLandUses.add(landUseType.landUseTypeID);
                    } else {
                      _selectedLandUses.remove(landUseType.landUseTypeID);
                    }
                  });
                },
              );
            }).toList(),
          );
        }
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String imagePath = '';
        if (_image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final String fileName = path.basename(_image!.path);
          final String newPath = path.join(directory.path, fileName);
          await _image!.copy(newPath);
          imagePath = newPath;
        }

        final newPlant = Plant(
          plantID: 0, // Set to 0 to let SQLite auto-increment
          plantName: _nameController.text,
          plantScientific: _scientificNameController.text,
          plantImage: imagePath,
        );

        final dbHelper = DatabaseHelper();
        final plantId = await dbHelper.insertPlant(newPlant);

        if (plantId > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plant added successfully')),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to insert plant');
        }
      } catch (e) {
        print('Error adding plant: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding plant: $e')),
        );
      }
    }
  }
}
