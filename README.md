# Campus Map App

Aplicacion Flutter para navegar un campus universitario con mapa interactivo,
busqueda de aulas, geolocalizacion, rutas y herramientas para estudiantes
(horario, favoritos y tareas).

## Funcionalidades principales

- Mapa interactivo del campus con marcadores por bloque
- Seleccion de perfil al iniciar (estudiante o visitante)
- Persistencia del perfil en almacenamiento local
- Busqueda de aulas con acceso directo a bloque/planta
- Vista de planos por planta
- Geolocalizacion en tiempo real
- Calculo de ruta con distancia y orientacion
- Favoritos de aulas (solo perfil estudiante)
- Horario editable con seleccion guiada: bloque -> planta -> aula
- Lista de tareas asociada al flujo academico
- Tema claro/oscuro y opciones de accesibilidad
- Preparada para ejecutarse como PWA en web

## Estructura actual del proyecto

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

test/
  main_test.dart
  route_handler_test.dart
  widget_test.dart
```

## Requisitos

- Flutter SDK compatible con `sdk: ^3.11.0`
- Dart incluido con Flutter
- Navegador moderno para web (Chrome/Edge recomendado)

## Como ejecutar

### 1) Instalar dependencias

```bash
flutter pub get
```

### 2) Ejecutar en web (desarrollo local)

```bash
flutter config --enable-web
flutter run -d web-server --web-port 8081
```

Abrir en `http://localhost:8081/`.

Nota sobre ubicacion en web:
- Para geolocalizacion, normalmente se requiere HTTPS.
- `localhost` suele funcionar en navegadores modernos.

### 3) Ejecutar en dispositivo/emulador

```bash
flutter run
```

## Pruebas

```bash
flutter test
```

Cobertura base incluida:
- `test/route_handler_test.dart`
- `test/main_test.dart`
- `test/widget_test.dart`

## Despliegue web (GitHub Pages)

URL publicada:

`https://jeanaucapina.github.io/Flutter/`

Flujo manual de despliegue:

```bash
flutter build web
git checkout gh-pages
git --work-tree=build/web add --all
git --work-tree=build/web commit -m "Deploy updated build"
git push origin gh-pages
git checkout main
```

## Dependencias principales

- `flutter_map`
- `latlong2`
- `geolocator`
- `provider`
- `google_fonts`
- `shared_preferences`

## Licencia

MIT


