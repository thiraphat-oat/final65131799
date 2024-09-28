import 'package:flutter/material.dart';
import 'package:final65131799/database/model.dart';
import 'package:final65131799/screens/land_use_screen.dart';
import 'package:final65131799/screens/edit_plant_screen.dart'; // นำเข้าไฟล์แก้ไขพืช

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.plantName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlantScreen(plant: plant), // ไปยังหน้าจอแก้ไขพืช
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(plant.plantName),
              background: Image.asset(
                plant.plantImage, // ตรวจสอบว่าใช้ชื่อแปรที่ถูกต้อง
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scientific Name:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.plantScientific,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LandUseScreen(plantId: plant.plantID),
                        ),
                      );
                    },
                    child: const Text('View Land Uses'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
