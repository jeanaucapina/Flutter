import 'package:flutter/material.dart';
import '../services/tasks_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<TaskItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await TasksService.loadTasks();
    if (!mounted) return;
    setState(() {
      _items = items;
      _sortItems();
      _loading = false;
    });
  }

  void _sortItems() {
    _items.sort((a, b) => a.dueAt.compareTo(b.dueAt));
  }

  Future<void> _persist() async {
    await TasksService.saveTasks(_items);
  }

  Future<void> _openEditor({TaskItem? initialItem, int? index}) async {
    final task = await showModalBottomSheet<TaskItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TaskEditorSheet(initialItem: initialItem),
    );

    if (task == null) return;

    setState(() {
      if (index != null) {
        _items[index] = task;
      } else {
        _items.add(task);
      }
      _sortItems();
    });

    await _persist();
  }

  Future<void> _toggleDone(int index, bool value) async {
    setState(() {
      _items[index] = _items[index].copyWith(done: value);
    });
    await _persist();
  }

  Future<void> _removeAt(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    await _persist();
  }

  String _dueLabel(DateTime dateTime) {
    final d = dateTime;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_task),
        label: const Text('Agregar tarea'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No hay tareas pendientes.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final task = _items[index];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done,
                          onChanged: (value) {
                            _toggleDone(index, value ?? false);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text('Para: ${_dueLabel(task.dueAt)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                              onPressed: () => _openEditor(initialItem: task, index: index),
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
    );
  }
}

class _TaskEditorSheet extends StatefulWidget {
  final TaskItem? initialItem;

  const _TaskEditorSheet({this.initialItem});

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  late final TextEditingController _titleCtrl;
  late DateTime _dueAt;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialItem?.title ?? '');
    _dueAt = widget.initialItem?.dueAt ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _dueAt.hour, minute: _dueAt.minute),
    );
    if (time == null) return;

    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una tarea.')),
      );
      return;
    }

    Navigator.of(context).pop(
      TaskItem(
        title: title,
        dueAt: _dueAt,
        done: widget.initialItem?.done ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dueText = '${_dueAt.day.toString().padLeft(2, '0')}/${_dueAt.month.toString().padLeft(2, '0')}/${_dueAt.year} ${_dueAt.hour.toString().padLeft(2, '0')}:${_dueAt.minute.toString().padLeft(2, '0')}';

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
              widget.initialItem == null ? 'Nueva tarea' : 'Editar tarea',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tarea'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha limite'),
              subtitle: Text(dueText),
              trailing: const Icon(Icons.event),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar tarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
