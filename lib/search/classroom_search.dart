import 'package:flutter/material.dart';
import '../models/search_classroom.dart';

class ClassroomSearch extends SearchDelegate {

  final List<SearchClassroom> classrooms;
  final Set<String> favoriteIds;
  final ValueChanged<SearchClassroom> onToggleFavorite;

  ClassroomSearch(
    this.classrooms, {
    required this.favoriteIds,
    required this.onToggleFavorite,
  });

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
    final results = _search(query);

    if (results.isEmpty) {
      return const Center(
        child: Text('Sin resultados. Prueba con aula, bloque o materia.'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final c = results[index];
        final isFavorite = favoriteIds.contains(c.id);
        return ListTile(
          title: Text(c.name),
          subtitle: Text('${c.building} - Planta ${c.floor}'),
          trailing: IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: () {
              onToggleFavorite(c);
              showSuggestions(context);
            },
          ),
          onTap: () {
            close(context, c);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  List<SearchClassroom> _search(String rawQuery) {
    final normalizedQuery = _normalize(rawQuery);

    final scored = classrooms.map((c) {
      final score = _scoreClassroom(c, normalizedQuery);
      return _ScoredClassroom(classroom: c, score: score);
    }).where((item) => item.score > 0).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return scored.map((e) => e.classroom).toList();
  }

  int _scoreClassroom(SearchClassroom classroom, String queryText) {
    if (queryText.isEmpty) {
      return favoriteIds.contains(classroom.id) ? 80 : 40;
    }

    final searchable = <String>[
      classroom.name,
      classroom.building,
      'planta ${classroom.floor}',
      ...classroom.aliases,
    ].map(_normalize).toList();

    int score = 0;

    for (final value in searchable) {
      if (value == queryText) {
        score = score < 200 ? 200 : score;
      } else if (value.startsWith(queryText)) {
        score = score < 160 ? 160 : score;
      } else if (value.contains(queryText)) {
        score = score < 120 ? 120 : score;
      } else {
        final distance = _levenshtein(value, queryText);
        if (distance <= 2 && queryText.length >= 3) {
          score = score < 90 ? 90 : score;
        }
      }
    }

    if (favoriteIds.contains(classroom.id)) {
      score += 10;
    }

    return score;
  }

  String _normalize(String input) {
    final lower = input.toLowerCase().trim();
    const accentMap = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ñ': 'n',
    };

    final normalizedChars = lower.split('').map((ch) => accentMap[ch] ?? ch).join();
    return normalizedChars.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final costs = List<int>.generate(b.length + 1, (i) => i);
    for (int i = 1; i <= a.length; i++) {
      int prev = i - 1;
      costs[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final temp = costs[j];
        final insert = costs[j] + 1;
        final delete = costs[j - 1] + 1;
        final replace = prev + (a[i - 1] == b[j - 1] ? 0 : 1);
        costs[j] = [insert, delete, replace].reduce((x, y) => x < y ? x : y);
        prev = temp;
      }
    }
    return costs[b.length];
  }
}

class _ScoredClassroom {
  final SearchClassroom classroom;
  final int score;

  _ScoredClassroom({required this.classroom, required this.score});
}