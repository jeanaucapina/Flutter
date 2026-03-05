import 'package:flutter/material.dart';
import '../models/search_classroom.dart';

class ClassroomSearch extends SearchDelegate {

  final List<SearchClassroom> classrooms;

  ClassroomSearch(this.classrooms);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {

    final results = classrooms
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map((c) {
        return ListTile(
          title: Text(c.name),
          subtitle: Text("${c.building} - Planta ${c.floor}"),
          onTap: () {
            close(context, c);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}