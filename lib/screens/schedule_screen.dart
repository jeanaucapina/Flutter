import 'package:flutter/material.dart';
import 'dart:async';
import '../models/search_classroom.dart';
import '../services/classroom_index_service.dart';
import '../services/schedule_service.dart';
import 'tasks_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ScheduleItem> _items = [];
  List<SearchClassroom> _classroomOptions = [];
  bool _loading = true;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _todayLabel(DateTime now) {
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final weekday = ScheduleService.weekdayLabel(now.weekday);
    return '$weekday, $day/$month/${now.year} - $hour:$minute';
  }

  Future<void> _openTasksScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TasksScreen(),
      ),
    );
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ScheduleService.loadSchedule(),
      ClassroomIndexService.loadIndex(),
    ]);

    final loaded = results[0] as List<ScheduleItem>;
    final loadedClassrooms = results[1] as List<SearchClassroom>;
    loadedClassrooms.sort((a, b) {
      final byBuilding = a.building.compareTo(b.building);
      if (byBuilding != 0) return byBuilding;
      final byFloor = a.floor.compareTo(b.floor);
      if (byFloor != 0) return byFloor;
      return a.name.compareTo(b.name);
    });

    if (!mounted) return;
    setState(() {
      _items = loaded;
      _classroomOptions = loadedClassrooms;
      _sortItems();
      _loading = false;
    });
  }

  void _sortItems() {
    _items.sort((a, b) {
      final byDay = a.weekday.compareTo(b.weekday);
      if (byDay != 0) return byDay;
      return (a.start.hour * 60 + a.start.minute)
          .compareTo(b.start.hour * 60 + b.start.minute);
    });
  }

  Future<void> _persist() async {
    await ScheduleService.saveSchedule(_items);
  }

  Future<void> _openEditor({ScheduleItem? item, int? index}) async {
    final result = await showModalBottomSheet<ScheduleItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ScheduleEditorSheet(
        initialItem: item,
        classroomOptions: _classroomOptions,
      ),
    );

    if (result == null) return;

    setState(() {
      if (index != null) {
        _items[index] = result;
      } else {
        _items.add(result);
      }
      _sortItems();
    });

    await _persist();
  }

  Future<void> _removeAt(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horario'),
        actions: [
          IconButton(
            onPressed: _openTasksScreen,
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Ver tareas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar clase'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.today_outlined),
                      title: const Text('Fecha y hora actual'),
                      subtitle: Text(_todayLabel(_now)),
                    ),
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(
                          child: Text('No hay clases en tu horario. Agrega una clase.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final timeText = '${item.start.hour.toString().padLeft(2, '0')}:${item.start.minute.toString().padLeft(2, '0')}';
                            return Card(
                              child: ListTile(
                                title: Text('${item.subject} - ${item.classroomName}'),
                                subtitle: Text(
                                  '${ScheduleService.weekdayLabel(item.weekday)} $timeText | ${item.building} | Planta ${item.floor}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Editar',
                                      onPressed: () => _openEditor(item: item, index: index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Eliminar',
                                      onPressed: () => _removeAt(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ScheduleEditorSheet extends StatefulWidget {
  final ScheduleItem? initialItem;
  final List<SearchClassroom> classroomOptions;

  const _ScheduleEditorSheet({
    this.initialItem,
    required this.classroomOptions,
  });

  @override
  State<_ScheduleEditorSheet> createState() => _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends State<_ScheduleEditorSheet> {
  late final TextEditingController _subjectCtrl;

  late int _weekday;
  late TimeOfDay _time;
  String? _selectedBuilding;
  int? _selectedFloor;
  String? _selectedClassroomId;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _subjectCtrl = TextEditingController(text: item?.subject ?? '');
    _weekday = item?.weekday ?? DateTime.monday;
    _time = item?.start ?? const TimeOfDay(hour: 8, minute: 0);

    if (item != null) {
      final initial = widget.classroomOptions.where((c) {
        return c.name == item.classroomName &&
            c.building == item.building &&
            c.floor == item.floor;
      });
      _selectedClassroomId = initial.isEmpty ? null : initial.first.id;
      _selectedBuilding = item.building;
      _selectedFloor = item.floor;
    }

    _selectedBuilding ??= _availableBuildings.isNotEmpty ? _availableBuildings.first : null;
    _selectedFloor ??= _availableFloorsFor(_selectedBuilding).isNotEmpty
        ? _availableFloorsFor(_selectedBuilding).first
        : null;
  }

  List<String> get _availableBuildings {
    final set = widget.classroomOptions.map((c) => c.building).toSet().toList();
    set.sort();
    return set;
  }

  List<int> _availableFloorsFor(String? building) {
    if (building == null) return <int>[];
    final floors = widget.classroomOptions
        .where((c) => c.building == building)
        .map((c) => c.floor)
        .toSet()
        .toList();
    floors.sort();
    return floors;
  }

  List<SearchClassroom> _availableClassroomsFor(String? building, int? floor) {
    if (building == null || floor == null) return <SearchClassroom>[];
    final classrooms = widget.classroomOptions
        .where((c) => c.building == building && c.floor == floor)
        .toList();
    classrooms.sort((a, b) => a.name.compareTo(b.name));
    return classrooms;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (selected == null) return;
    setState(() {
      _time = selected;
    });
  }

  void _save() {
    final subject = _subjectCtrl.text.trim();
    if (_selectedClassroomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona bloque, planta y aula.')),
      );
      return;
    }

    final selected = widget.classroomOptions.where((c) => c.id == _selectedClassroomId).first;

    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos correctamente.')),
      );
      return;
    }

    Navigator.of(context).pop(
      ScheduleItem(
        weekday: _weekday,
        start: _time,
        classroomName: selected.name,
        building: selected.building,
        floor: selected.floor,
        subject: subject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialItem == null ? 'Nueva clase' : 'Editar clase',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _weekday,
              items: const [
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
                DateTime.saturday,
                DateTime.sunday,
              ].map((day) {
                return DropdownMenuItem<int>(
                  value: day,
                  child: Text(ScheduleService.weekdayLabel(day)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _weekday = value);
              },
              decoration: const InputDecoration(labelText: 'Dia'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hora'),
              subtitle: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.schedule),
              onTap: _pickTime,
            ),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Materia'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedBuilding,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Bloque',
              ),
              items: _availableBuildings.map((building) {
                return DropdownMenuItem<String>(
                  value: building,
                  child: Text(
                    building,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBuilding = value;
                  final floors = _availableFloorsFor(_selectedBuilding);
                  _selectedFloor = floors.isNotEmpty ? floors.first : null;
                  _selectedClassroomId = null;
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedFloor,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Planta',
              ),
              items: _availableFloorsFor(_selectedBuilding).map((floor) {
                return DropdownMenuItem<int>(
                  value: floor,
                  child: Text('Planta $floor'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFloor = value;
                  _selectedClassroomId = null;
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedClassroomId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Aula',
              ),
              items: _availableClassroomsFor(_selectedBuilding, _selectedFloor).map((option) {
                return DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(option.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassroomId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
