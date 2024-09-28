import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final65131799/database/database_helper.dart';
import 'package:final65131799/database/model.dart';
import 'package:final65131799/screens/plant_detail_screen.dart';
import 'package:final65131799/screens/add_plant_screen.dart';
import 'package:final65131799/screens/edit_plant_screen.dart';
import 'package:final65131799/screens/search_land_use_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Plant> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final plants = await _databaseHelper.getPlants();
    setState(() {
      _plants = plants;
    });
  }

  bool _isAssetImage(String path) {
    return path.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Information', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white), // ไอคอนค้นหา
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchLandUseScreen(), // ไปยังหน้าค้นหาที่สร้างขึ้น
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPlantScreen(), // ไปยังหน้าจอเพิ่มพืช
                ),
              ).then((_) => _loadPlants()); // โหลดพืชใหม่หลังเพิ่มเสร็จ
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          final plant = _plants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailScreen(plant: plant),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ตรวจสอบว่าเป็น Asset หรือ File Path และใช้วิธีแสดงภาพที่เหมาะสม
                    _isAssetImage(plant.plantImage)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              plant.plantImage,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(plant.plantImage),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plant.plantName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPlantScreen(plant: plant),
                              ),
                            ).then((_) => _loadPlants()); // โหลดพืชใหม่หลังแก้ไขเสร็จ
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plant.plantScientific,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<LandUse>>(
                      future: _databaseHelper.getLandUsesForPlant(plant.plantID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No Land Use Types available');
                        } else {
                          // แสดงข้อมูลการใช้ที่ดิน
                          final landUses = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: landUses.map((landUse) {
                              return Text(
                                'Land Use: ${landUse.landUseTypeName} - ${landUse.landUseDescription}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.grey.shade100, // พื้นหลังสีอ่อนสำหรับหน้าจอทั้งหมด
    );
  }
}
