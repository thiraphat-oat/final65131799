import 'package:flutter/material.dart';
import 'package:final65131799/database/database_helper.dart';
import 'package:final65131799/database/model.dart';

class LandUseScreen extends StatefulWidget {
  final int plantId;

  const LandUseScreen({super.key, required this.plantId});

  @override
  _LandUseScreenState createState() => _LandUseScreenState();
}

class _LandUseScreenState extends State<LandUseScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<LandUse> _landUses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLandUses();
  }

  Future<void> _loadLandUses() async {
    try {
      final landUses = await _databaseHelper.getLandUsesForPlant(widget.plantId);
      setState(() {
        _landUses = landUses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading land uses: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Uses'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _landUses.isEmpty
              ? const Center(child: Text('No land uses found for this plant.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _landUses.length,
                  itemBuilder: (context, index) {
                    final landUse = _landUses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type: ${landUse.landUseTypeName}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Component: ${landUse.componentName}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              landUse.landUseDescription,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}