import 'package:flutter/material.dart';

import '../models/block.dart';
import 'floor_plan_screen.dart';

class BlockDetailScreen extends StatelessWidget {
  final Block block;

  const BlockDetailScreen({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(block.name)),
      body: ListView.builder(
        itemCount: block.floors.length,
        itemBuilder: (context, index) {
          final floor = block.floors[index];
          return ListTile(
            title: Text('Planta ${floor.number}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FloorPlanScreen(
                    jsonPath: 'assets/data/${block.code}_planta${floor.number}.json',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
