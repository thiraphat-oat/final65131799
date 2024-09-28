import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:final65131799/database/database_helper.dart';
import 'package:final65131799/database/model.dart';

class EditPlantScreen extends StatefulWidget {
  final Plant plant;

  const EditPlantScreen({Key? key, required this.plant}) : super(key: key);

  @override
  _EditPlantScreenState createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _scientificNameController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.plantName);
    _scientificNameController = TextEditingController(text: widget.plant.plantScientific);
    if (widget.plant.plantImage.isNotEmpty) {
      _image = File(widget.plant.plantImage);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    super.dispose();
  }

  Future<void> _getImage(bool isCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _deletePlant() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deletePlant(widget.plant.plantID);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plant deleted successfully')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Edit Plant Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                      label: const Text('Camera', style: TextStyle(color: Colors.white)), // ตัวอักษรสีขาว
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
                      label: const Text('Gallery', style: TextStyle(color: Colors.white)), // ตัวอักษรสีขาว
                      onPressed: () => _getImage(false),
                    ),
                  ],
                ),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.teal.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white), // เพิ่มไอคอนบันทึก
                  label: const Text(
                    'Update Plant',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: _submitForm,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white), // ไอคอนถังขยะ
                  label: const Text(
                    'Delete Plant',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: _deletePlant,
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
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String imagePath = widget.plant.plantImage;
      if (_image != null && _image!.path != widget.plant.plantImage) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(_image!.path);
        final String newPath = path.join(directory.path, fileName);
        await _image!.copy(newPath);
        imagePath = newPath;
      }

      final updatedPlant = Plant(
        plantID: widget.plant.plantID,
        plantName: _nameController.text,
        plantScientific: _scientificNameController.text,
        plantImage: imagePath,
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.updatePlant(updatedPlant);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant updated successfully')),
      );

      Navigator.pop(context, true);
    }
  }
}
