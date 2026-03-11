class SearchClassroom {
  final String name;
  final String building;
  final int floor;
  final List<String> aliases;

  SearchClassroom({
    required this.name,
    required this.building,
    required this.floor,
    this.aliases = const [],
  });

  String get id => '${building.toLowerCase()}|$floor|${name.toLowerCase()}';
}