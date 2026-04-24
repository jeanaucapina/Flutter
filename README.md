# Campus Map App

Aplicacion Flutter para explorar un campus universitario con mapa interactivo,
busqueda de aulas, planos por planta, geolocalizacion y herramientas orientadas
tanto a estudiantes como a visitantes.

## Resumen
La aplicacion parte de una seleccion de perfil y luego muestra un mapa del
campus con acceso a bloques, aulas y rutas. Para estudiantes, ademas habilita
favoritos, horario y tareas. La informacion de planos y aulas se carga desde
archivos JSON incluidos en `assets/data/`.

## Funcionalidades
- Mapa interactivo del campus con bloques navegables.
- Seleccion de perfil al iniciar: estudiante o visitante.
- Persistencia local del perfil seleccionado.
- Busqueda de aulas con acceso directo al bloque y planta.
- Visualizacion de planos por planta.
- Geolocalizacion en tiempo real.
- Calculo de ruta con distancia y orientacion.
- Favoritos de aulas para perfil estudiante.
- Horario editable con seleccion guiada de bloque, planta y aula.
- Lista de tareas asociada al flujo academico.
- Tema claro y oscuro.
- Compatibilidad con web, Android, iOS, Windows, Linux y macOS.
## Stack tecnico

- Flutter
- Dart
- `flutter_map` para el mapa
- `latlong2` para calculos geograficos
- `geolocator` para ubicacion
- `provider` para estado simple
- `shared_preferences` para persistencia local
- `google_fonts` para tipografia
## Estructura del proyecto

```text
lib/
  main.dart
  data/
    campus_data.dart
  models/
    app_role.dart
    block.dart
    search_classroom.dart
  screens/
    block_detail_screen.dart
    floor_plan_screen.dart
    map_screen.dart
    role_selection_screen.dart
    schedule_screen.dart
    tasks_screen.dart
    widgets/
      map_screen_sections.dart
  search/
    classroom_search.dart
  services/
    classroom_index_service.dart
    favorites_service.dart
    floor_loader.dart
    route_handler.dart
    schedule_service.dart
    tasks_service.dart
    theme_provider.dart
  widgets/
    animated_routes.dart
    distance_info_widget.dart
    route_painter.dart

assets/
  data/
  plans/

tool/
  floor_editor.dart

test/
  main_test.dart
  route_handler_test.dart
  widget_test.dart

## Datos y assets

Los planos y metadatos de aulas se encuentran en:

- `assets/data/`
- `assets/plans/`

JSON incluidos actualmente:
- `assets/data/administrativo_planta1.json`
- `assets/data/administrativo_planta2.json`
- `assets/data/bloque_b_planta1.json`
- `assets/data/bloque_b_planta2.json`
- `assets/data/bloque_b_planta3.json`
- `assets/data/bloque_c_planta0.json`
- `assets/data/bloque_c_planta1.json`
- `assets/data/bloque_c_planta2.json`
- `assets/data/casona_balzay_planta1.json`

## Requisitos

- Flutter SDK compatible con `sdk: ^3.11.0`
- Dart incluido con Flutter
- Dispositivo, emulador o navegador compatible

Verifica tu entorno con:
```bash
flutter doctor
```

## Instalacion

```bash
flutter pub get
```

## Ejecucion

### App principal

En cualquier plataforma disponible:
```bash
flutter run
```

En web local:
```bash
flutter config --enable-web
flutter run -d web-server --web-port 8081
```

Luego abre `http://localhost:8081/`.

Nota sobre geolocalizacion en web:

- Normalmente requiere HTTPS.
- `localhost` suele estar permitido por los navegadores modernos.

### Plataformas especificas

Ejemplos:
```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

Puedes ver los dispositivos disponibles con:
```bash
flutter devices
```

## Herramienta auxiliar: editor visual de pisos

El proyecto incluye una herramienta separada para crear o ajustar aulas sobre
los planos y exportar el JSON correspondiente.

Archivo:

- `tool/floor_editor.dart`

Ejecutar en Windows:
```bash
flutter run -d windows -t tool/floor_editor.dart
```

Ejecutar en web:
```bash
flutter run -d web-server -t tool/floor_editor.dart --web-port 8082
```

Uso rapido:
- Cargar un JSON desde `assets/data/...`
- Agregar aulas
- Mover aulas existentes
- Definir entrada
- Definir inicio de ruta
- Guardar el archivo directamente en escritorio
- Copiar el JSON al portapapeles cuando se usa en web

Notas:
- En web no se guarda directamente en archivo.
- La herramienta usa posiciones normalizadas para mantener consistencia entre
  pantallas y plataformas.

## Calidad y pruebas

Analisis estatico:

```bash
flutter analyze
```

Pruebas:

```bash
flutter test
```

Cobertura actual:
- `test/main_test.dart`
- `test/route_handler_test.dart`
- `test/widget_test.dart`

## Build web

Para generar la version web:

```bash
flutter build web
```

Si el sitio se publica en GitHub Pages bajo el repositorio `Flutter`, usa:
```bash
flutter build web --base-href /Flutter/
```

URL publicada actualmente:
- `https://jeanaucapina.github.io/Flutter/`

## Icono de la aplicacion

El icono configurado para Android, iOS, web, Windows y macOS usa:

- `assets/plans/ico.png`

Configuracion en `pubspec.yaml` mediante `flutter_launcher_icons`.

## Dependencias principales

- `flutter_map`
- `latlong2`
- `geolocator`
- `provider`
- `google_fonts`
- `shared_preferences`

## Licencia

MIT


