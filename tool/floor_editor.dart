import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FloorEditorApp());
}

class FloorEditorApp extends StatelessWidget {
  const FloorEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Floor JSON Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const FloorEditorScreen(),
    );
  }
}

enum EditMode {
  addClassroom,
  moveSelectedClassroom,
  setEntrance,
  setRouteStart,
}

class EditableClassroom {
  EditableClassroom({
    required this.name,
    required this.x,
    required this.y,
    required this.directions,
  });

  String name;
  double x;
  double y;
  String directions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'x': _round3(x),
      'y': _round3(y),
      'directions': directions,
    };
  }
}

class EditableFloorData {
  EditableFloorData({
    required this.building,
    required this.floor,
    required this.image,
    required this.entrance,
    required this.routeStart,
    required this.classrooms,
  });

  String building;
  int floor;
  String image;
  Offset entrance;
  Offset routeStart;
  List<EditableClassroom> classrooms;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'building': building,
      'floor': floor,
      'image': image,
      'entrance': <String, dynamic>{
        'x': _round3(entrance.dx),
        'y': _round3(entrance.dy),
      },
      'route_start': <String, dynamic>{
        'x': _round3(routeStart.dx),
        'y': _round3(routeStart.dy),
      },
      'classrooms': classrooms.map((c) => c.toJson()).toList(),
    };
  }

  static EditableFloorData fromJson(Map<String, dynamic> json) {
    final entranceJson = json['entrance'] as Map<String, dynamic>;
    final routeJson = (json['route_start'] as Map<String, dynamic>?) ?? entranceJson;
    final classroomsJson = (json['classrooms'] as List<dynamic>?) ?? <dynamic>[];

    return EditableFloorData(
      building: (json['building'] ?? '').toString(),
      floor: (json['floor'] as num?)?.toInt() ?? 1,
      image: (json['image'] ?? '').toString(),
      entrance: Offset(
        (entranceJson['x'] as num).toDouble(),
        (entranceJson['y'] as num).toDouble(),
      ),
      routeStart: Offset(
        (routeJson['x'] as num).toDouble(),
        (routeJson['y'] as num).toDouble(),
      ),
      classrooms: classroomsJson
          .map(
            (item) => EditableClassroom(
              name: (item['name'] ?? '').toString(),
              x: (item['x'] as num).toDouble(),
              y: (item['y'] as num).toDouble(),
              directions: (item['directions'] ?? '').toString(),
            ),
          )
          .toList(),
    );
  }
}

class FloorEditorScreen extends StatefulWidget {
  const FloorEditorScreen({super.key});

  @override
  State<FloorEditorScreen> createState() => _FloorEditorScreenState();
}

class _FloorEditorScreenState extends State<FloorEditorScreen> {
  static const List<String> _presetJsonPaths = <String>[
    'assets/data/administrativo_planta1.json',
    'assets/data/administrativo_planta2.json',
    'assets/data/bloque_b_planta1.json',
    'assets/data/bloque_b_planta2.json',
    'assets/data/bloque_b_planta3.json',
    'assets/data/bloque_c_planta0.json',
    'assets/data/bloque_c_planta1.json',
    'assets/data/bloque_c_planta2.json',
    'assets/data/casona_balzay_planta1.json',
  ];

  final TextEditingController _pathCtrl = TextEditingController(
    text: _presetJsonPaths.first,
  );
  String _loadedAssetPath = _presetJsonPaths.first;

  late EditableFloorData _data;
  bool _loading = false;
  EditMode _mode = EditMode.addClassroom;
  int? _selectedClassroomIndex;

  @override
  void initState() {
    super.initState();
    _data = EditableFloorData(
      building: 'Bloque X',
      floor: 1,
      image: 'assets/plans/bloque_b_planta1.png',
      entrance: const Offset(0.9, 0.5),
      routeStart: const Offset(0.9, 0.5),
      classrooms: <EditableClassroom>[],
    );
    _loadFromAssetPath(_pathCtrl.text);
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFromAssetPath(String path) async {
    setState(() {
      _loading = true;
    });

    try {
      final raw = await rootBundle.loadString(path);
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = EditableFloorData.fromJson(parsed);
      if (!mounted) return;

      setState(() {
        _data = loaded;
        _loadedAssetPath = path;
        _selectedClassroomIndex = null;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar JSON: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _exportJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_data.toJson());
  }

  Future<void> _copyJson() async {
    await Clipboard.setData(ClipboardData(text: _exportJson()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copiado al portapapeles.')),
    );
  }

  Future<void> _saveJsonToFile() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Guardar en archivo no esta disponible en Web. Usa Windows para guardar directo.',
          ),
        ),
      );
      return;
    }

    final targetPath = _pathCtrl.text.trim().isNotEmpty
        ? _pathCtrl.text.trim()
        : _loadedAssetPath;

    try {
      final file = File(targetPath);
      final exists = await file.exists();
      if (!exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No existe el archivo: $targetPath')),
        );
        return;
      }

      await file.writeAsString('${_exportJson()}\n');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guardado en $targetPath')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $error')),
      );
    }
  }

  void _onCanvasTap(Offset normalizedPosition) {
    final x = normalizedPosition.dx;
    final y = normalizedPosition.dy;

    switch (_mode) {
      case EditMode.setEntrance:
        setState(() {
          _data.entrance = Offset(x, y);
        });
        break;
      case EditMode.setRouteStart:
        setState(() {
          _data.routeStart = Offset(x, y);
        });
        break;
      case EditMode.moveSelectedClassroom:
        if (_selectedClassroomIndex == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecciona un aula primero.')),
          );
          return;
        }
        setState(() {
          final selected = _data.classrooms[_selectedClassroomIndex!];
          selected.x = x;
          selected.y = y;
        });
        break;
      case EditMode.addClassroom:
        _openNewClassroomDialog(x: x, y: y);
        break;
    }
  }

  Future<void> _openNewClassroomDialog({required double x, required double y}) async {
    final nameCtrl = TextEditingController();
    final directionsCtrl = TextEditingController();
    final created = await showDialog<EditableClassroom>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva aula'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: directionsCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Indicaciones'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.of(context).pop(
                  EditableClassroom(
                    name: name,
                    x: x,
                    y: y,
                    directions: directionsCtrl.text.trim(),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    nameCtrl.dispose();
    directionsCtrl.dispose();

    if (created == null) return;
    setState(() {
      _data.classrooms.add(created);
      _selectedClassroomIndex = _data.classrooms.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floor JSON Editor'),
        actions: [
          IconButton(
            tooltip: 'Guardar archivo',
            onPressed: _saveJsonToFile,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: 'Copiar JSON',
            onPressed: _copyJson,
            icon: const Icon(Icons.copy_all_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _presetJsonPaths.contains(_pathCtrl.text)
                              ? _pathCtrl.text
                              : null,
                          hint: const Text('Selecciona un JSON de ejemplo'),
                          items: _presetJsonPaths
                              .map(
                                (path) => DropdownMenuItem<String>(
                                  value: path,
                                  child: Text(
                                    path,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          selectedItemBuilder: (context) => _presetJsonPaths
                              .map(
                                (path) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    path,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            _pathCtrl.text = value;
                            _loadFromAssetPath(value);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 360,
                        child: TextField(
                          controller: _pathCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ruta JSON (asset)',
                            hintText: 'assets/data/bloque_x_planta1.json',
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _loadFromAssetPath(_pathCtrl.text.trim()),
                        icon: const Icon(Icons.file_open_outlined),
                        label: const Text('Cargar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: _MapCanvas(
                            imagePath: _data.image,
                            classrooms: _data.classrooms,
                            selectedClassroomIndex: _selectedClassroomIndex,
                            entrance: _data.entrance,
                            routeStart: _data.routeStart,
                            onEntranceDragged: (value) {
                              setState(() {
                                _data.entrance = value;
                              });
                            },
                            onRouteStartDragged: (value) {
                              setState(() {
                                _data.routeStart = value;
                              });
                            },
                            onTap: _onCanvasTap,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 420,
                        child: _RightPanel(
                          data: _data,
                          mode: _mode,
                          selectedClassroomIndex: _selectedClassroomIndex,
                          onModeChanged: (mode) {
                            setState(() {
                              _mode = mode;
                            });
                          },
                          onBuildingChanged: (value) {
                            setState(() {
                              _data.building = value;
                            });
                          },
                          onFloorChanged: (value) {
                            setState(() {
                              _data.floor = value;
                            });
                          },
                          onImageChanged: (value) {
                            setState(() {
                              _data.image = value;
                            });
                          },
                          onSelectClassroom: (index) {
                            setState(() {
                              _selectedClassroomIndex = index;
                            });
                          },
                          onUpdateClassroom: (index, classroom) {
                            setState(() {
                              _data.classrooms[index] = classroom;
                            });
                          },
                          onDeleteClassroom: (index) {
                            setState(() {
                              _data.classrooms.removeAt(index);
                              if (_selectedClassroomIndex == index) {
                                _selectedClassroomIndex = null;
                              } else if (_selectedClassroomIndex != null &&
                                  _selectedClassroomIndex! > index) {
                                _selectedClassroomIndex = _selectedClassroomIndex! - 1;
                              }
                            });
                          },
                          onSaveJson: _saveJsonToFile,
                          onCopyJson: _copyJson,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _MapCanvas extends StatefulWidget {
  const _MapCanvas({
    required this.imagePath,
    required this.classrooms,
    required this.selectedClassroomIndex,
    required this.entrance,
    required this.routeStart,
    required this.onEntranceDragged,
    required this.onRouteStartDragged,
    required this.onTap,
  });

  final String imagePath;
  final List<EditableClassroom> classrooms;
  final int? selectedClassroomIndex;
  final Offset entrance;
  final Offset routeStart;
  final ValueChanged<Offset> onEntranceDragged;
  final ValueChanged<Offset> onRouteStartDragged;
  final ValueChanged<Offset> onTap;

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  double _imageAspectRatio = 2.5;

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatio(widget.imagePath);
  }

  @override
  void didUpdateWidget(covariant _MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImageAspectRatio(widget.imagePath);
    }
  }

  Future<void> _loadImageAspectRatio(String path) async {
    try {
      final bytes = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final ratio = image.height == 0 ? 2.5 : image.width / image.height;
      if (!mounted) return;
      setState(() {
        _imageAspectRatio = ratio;
      });
    } catch (_) {
      // Keep previous ratio if asset decoding fails.
    }
  }

  Rect _imageRect(BoxConstraints constraints) {
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    double displayedWidth;
    double displayedHeight;

    if (containerWidth / containerHeight > _imageAspectRatio) {
      displayedHeight = containerHeight;
      displayedWidth = displayedHeight * _imageAspectRatio;
    } else {
      displayedWidth = containerWidth;
      displayedHeight = displayedWidth / _imageAspectRatio;
    }

    final offsetX = (containerWidth - displayedWidth) / 2;
    final offsetY = (containerHeight - displayedHeight) / 2;
    return Rect.fromLTWH(offsetX, offsetY, displayedWidth, displayedHeight);
  }

  Offset _normalizedFromLocal(Offset localPosition, Rect imageRect) {
    final x = ((localPosition.dx - imageRect.left) / imageRect.width).clamp(0.0, 1.0);
    final y = ((localPosition.dy - imageRect.top) / imageRect.height).clamp(0.0, 1.0);
    return Offset(x, y);
  }

  Offset _localFromNormalized(Offset normalized, Rect imageRect) {
    return Offset(
      imageRect.left + normalized.dx * imageRect.width,
      imageRect.top + normalized.dy * imageRect.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageRect = _imageRect(constraints);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (!imageRect.contains(details.localPosition)) {
                return;
              }
              widget.onTap(_normalizedFromLocal(details.localPosition, imageRect));
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: imageRect.left,
                  top: imageRect.top,
                  width: imageRect.width,
                  height: imageRect.height,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('No se pudo cargar la imagen del plano.'),
                      );
                    },
                  ),
                ),
                ...widget.classrooms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final classroom = entry.value;
                  final markerPos = _localFromNormalized(
                    Offset(classroom.x, classroom.y),
                    imageRect,
                  );
                  return Positioned(
                    left: markerPos.dx - 8,
                    top: markerPos.dy - 8,
                    child: _MarkerDot(
                      color: index == widget.selectedClassroomIndex
                          ? Colors.amber
                          : Colors.red,
                      tooltip: classroom.name,
                    ),
                  );
                }),
                Builder(
                  builder: (context) {
                    final markerPos = _localFromNormalized(widget.entrance, imageRect);
                    return Positioned(
                      left: markerPos.dx - 8,
                      top: markerPos.dy - 8,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          final current = _localFromNormalized(widget.entrance, imageRect);
                          final nextLocal = current + details.delta;
                          widget.onEntranceDragged(
                            _normalizedFromLocal(nextLocal, imageRect),
                          );
                        },
                        child: const _MarkerDot(
                          color: Colors.green,
                          tooltip: 'Entrada (arrastra para mover)',
                        ),
                      ),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    final markerPos = _localFromNormalized(widget.routeStart, imageRect);
                    return Positioned(
                      left: markerPos.dx - 8,
                      top: markerPos.dy - 8,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          final current = _localFromNormalized(widget.routeStart, imageRect);
                          final nextLocal = current + details.delta;
                          widget.onRouteStartDragged(
                            _normalizedFromLocal(nextLocal, imageRect),
                          );
                        },
                        child: const _MarkerDot(
                          color: Colors.blue,
                          tooltip: 'Inicio ruta (arrastra para mover)',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarkerDot extends StatelessWidget {
  const _MarkerDot({required this.color, required this.tooltip});

  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.data,
    required this.mode,
    required this.selectedClassroomIndex,
    required this.onModeChanged,
    required this.onBuildingChanged,
    required this.onFloorChanged,
    required this.onImageChanged,
    required this.onSelectClassroom,
    required this.onUpdateClassroom,
    required this.onDeleteClassroom,
    required this.onSaveJson,
    required this.onCopyJson,
  });

  final EditableFloorData data;
  final EditMode mode;
  final int? selectedClassroomIndex;

  final ValueChanged<EditMode> onModeChanged;
  final ValueChanged<String> onBuildingChanged;
  final ValueChanged<int> onFloorChanged;
  final ValueChanged<String> onImageChanged;
  final ValueChanged<int> onSelectClassroom;
  final void Function(int index, EditableClassroom classroom) onUpdateClassroom;
  final ValueChanged<int> onDeleteClassroom;
  final VoidCallback onSaveJson;
  final VoidCallback onCopyJson;

  @override
  Widget build(BuildContext context) {
    final floorCtrl = TextEditingController(text: data.floor.toString());

    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos generales', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: data.building),
              decoration: const InputDecoration(labelText: 'Building'),
              onChanged: onBuildingChanged,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: floorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Floor'),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) onFloorChanged(parsed);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: data.image),
              decoration: const InputDecoration(labelText: 'Image asset path'),
              onChanged: onImageChanged,
            ),
            const SizedBox(height: 12),
            Text('Modo de edicion', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('Agregar aula'),
                  selected: mode == EditMode.addClassroom,
                  onSelected: (_) => onModeChanged(EditMode.addClassroom),
                ),
                ChoiceChip(
                  label: const Text('Mover aula'),
                  selected: mode == EditMode.moveSelectedClassroom,
                  onSelected: (_) => onModeChanged(EditMode.moveSelectedClassroom),
                ),
                ChoiceChip(
                  label: const Text('Entrada'),
                  selected: mode == EditMode.setEntrance,
                  onSelected: (_) => onModeChanged(EditMode.setEntrance),
                ),
                ChoiceChip(
                  label: const Text('Inicio ruta'),
                  selected: mode == EditMode.setRouteStart,
                  onSelected: (_) => onModeChanged(EditMode.setRouteStart),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona un modo y haz clic sobre el plano.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: data.classrooms.length,
                itemBuilder: (context, index) {
                  final classroom = data.classrooms[index];
                  final selected = selectedClassroomIndex == index;

                  return Card(
                    color: selected
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null,
                    child: ListTile(
                      onTap: () => onSelectClassroom(index),
                      title: Text(classroom.name),
                      subtitle: Text(
                        'x=${_round3(classroom.x)} y=${_round3(classroom.y)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () async {
                              final updated = await _showEditClassroomDialog(
                                context,
                                classroom,
                              );
                              if (updated == null) return;
                              onUpdateClassroom(index, updated);
                            },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            onPressed: () => onDeleteClassroom(index),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSaveJson,
                icon: const Icon(Icons.save),
                label: const Text('Guardar JSON en archivo'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCopyJson,
                icon: const Icon(Icons.copy),
                label: const Text('Copiar JSON generado'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<EditableClassroom?> _showEditClassroomDialog(
    BuildContext context,
    EditableClassroom classroom,
  ) async {
    final nameCtrl = TextEditingController(text: classroom.name);
    final directionsCtrl = TextEditingController(text: classroom.directions);

    final result = await showDialog<EditableClassroom>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar aula'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: directionsCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Indicaciones'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.of(context).pop(
                  EditableClassroom(
                    name: name,
                    x: classroom.x,
                    y: classroom.y,
                    directions: directionsCtrl.text.trim(),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    nameCtrl.dispose();
    directionsCtrl.dispose();
    return result;
  }
}

double _round3(double value) => (value * 1000).roundToDouble() / 1000;