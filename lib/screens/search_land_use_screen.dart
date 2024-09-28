import 'package:flutter/material.dart';
import 'package:final65131799/database/database_helper.dart';
import 'package:final65131799/database/model.dart';

class SearchLandUseScreen extends StatefulWidget {
  const SearchLandUseScreen({Key? key}) : super(key: key);

  @override
  _SearchLandUseScreenState createState() => _SearchLandUseScreenState();
}

class _SearchLandUseScreenState extends State<SearchLandUseScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // รายการข้อมูลทั้งหมด
  List<LandUseType> _landUseTypes = [];
  List<Plant> _plants = [];
  List<PlantComponent> _plantComponents = [];

  String _searchQuery = '';
  bool _isLoading = true; // เพิ่มตัวแปรสถานะการโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final landUses = await _databaseHelper.getLandUseTypes();
      final plants = await _databaseHelper.getPlants();
      final plantComponents = await _databaseHelper.getPlantComponents();

      setState(() {
        _landUseTypes = landUses;
        _plants = plants;
        _plantComponents = plantComponents;
        _isLoading = false; // การโหลดข้อมูลเสร็จสิ้น
      });

      // เพิ่มการตรวจสอบข้อมูลที่ถูกดึงมา
      print('LandUseTypes: $_landUseTypes');
      print('Plants: $_plants');
      print('PlantComponents: $_plantComponents');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ฟังก์ชันสำหรับกรองข้อมูลตามคำค้นหา
    List<LandUseType> filteredLandUseTypes = _landUseTypes.where((landUse) {
      return landUse.landUseTypeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             landUse.landUseTypeDescription.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    List<Plant> filteredPlants = _plants.where((plant) {
      return plant.plantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             plant.plantScientific.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    List<PlantComponent> filteredPlantComponents = _plantComponents.where((component) {
      return component.componentName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Land Use', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator()) // แสดงตัวโหลด
            : Column(
                children: [
                  // ช่องค้นหา
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // แสดงผลลัพธ์การค้นหา
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // แสดงผลลัพธ์จาก LandUseType
                          if (filteredLandUseTypes.isNotEmpty) ...[
                            const Text('Land Use Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredLandUseTypes.length,
                              itemBuilder: (context, index) {
                                final landUseType = filteredLandUseTypes[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(landUseType.landUseTypeName),
                                    subtitle: Text(landUseType.landUseTypeDescription),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          // แสดงผลลัพธ์จาก Plant
                          if (filteredPlants.isNotEmpty) ...[
                            const Text('Plants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredPlants.length,
                              itemBuilder: (context, index) {
                                final plant = filteredPlants[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Image.asset(
                                      plant.plantImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                    title: Text(plant.plantName),
                                    subtitle: Text(plant.plantScientific),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          // แสดงผลลัพธ์จาก PlantComponent
                          if (filteredPlantComponents.isNotEmpty) ...[
                            const Text('Plant Components', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredPlantComponents.length,
                              itemBuilder: (context, index) {
                                final component = filteredPlantComponents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Image.asset(
                                      component.componentIcon,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                    title: Text(component.componentName),
                                  ),
                                );
                              },
                            ),
                          ],
                          // หากไม่มีผลลัพธ์ใดเลย
                          if (filteredLandUseTypes.isEmpty && filteredPlants.isEmpty && filteredPlantComponents.isEmpty && _searchQuery.isNotEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('No results found.', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      backgroundColor: Colors.grey.shade100, // พื้นหลังสีอ่อนสำหรับหน้าจอทั้งหมด
    );
  }
}
