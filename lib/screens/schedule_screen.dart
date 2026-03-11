import 'package:flutter/material.dart';
import 'dart:async';
import '../services/schedule_service.dart';
import 'tasks_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ScheduleItem> _items = [];
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
    final loaded = await ScheduleService.loadSchedule();
    if (!mounted) return;
    setState(() {
      _items = loaded;
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
      builder: (_) => _ScheduleEditorSheet(initialItem: item),
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

  const _ScheduleEditorSheet({this.initialItem});

  @override
  State<_ScheduleEditorSheet> createState() => _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends State<_ScheduleEditorSheet> {
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _classroomCtrl;
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _floorCtrl;

  late int _weekday;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _subjectCtrl = TextEditingController(text: item?.subject ?? '');
    _classroomCtrl = TextEditingController(text: item?.classroomName ?? '');
    _buildingCtrl = TextEditingController(text: item?.building ?? '');
    _floorCtrl = TextEditingController(text: item?.floor.toString() ?? '1');
    _weekday = item?.weekday ?? DateTime.monday;
    _time = item?.start ?? const TimeOfDay(hour: 8, minute: 0);
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _classroomCtrl.dispose();
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
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
    final classroom = _classroomCtrl.text.trim();
    final building = _buildingCtrl.text.trim();
    final floor = int.tryParse(_floorCtrl.text.trim());

    if (subject.isEmpty || classroom.isEmpty || building.isEmpty || floor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos correctamente.')),
      );
      return;
    }

    Navigator.of(context).pop(
      ScheduleItem(
        weekday: _weekday,
        start: _time,
        classroomName: classroom,
        building: building,
        floor: floor,
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
            TextField(
              controller: _classroomCtrl,
              decoration: const InputDecoration(labelText: 'Aula (ej: B101)'),
            ),
            TextField(
              controller: _buildingCtrl,
              decoration: const InputDecoration(labelText: 'Edificio (ej: Bloque B)'),
            ),
            TextField(
              controller: _floorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Planta'),
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
