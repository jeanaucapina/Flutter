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
- Marcadores y etiquetas responsivas para pantallas pequenas y grandes
- Etiquetas anti-solapamiento en zonas con muchas aulas (la seleccionada siempre visible)
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

## Editor visual de JSON (herramienta separada)

Se agrego una herramienta de desarrollo independiente para crear/editar aulas
con clic sobre el plano, sin integrarla al flujo principal de la app.

Archivo de entrada:
- `tool/floor_editor.dart`

Ejecutar en Windows:

```bash
flutter run -d windows -t tool/floor_editor.dart
```

Ejecutar en Web:

```bash
flutter run -d web-server -t tool/floor_editor.dart --web-port 8082
```

Uso rapido:
- Carga un JSON desde `assets/data/...`
- Elige modo (agregar aula, mover aula, entrada, inicio de ruta)
- Puedes arrastrar la entrada y el inicio de ruta directamente sobre el plano
- Haz clic sobre el plano para posicionar
- Guarda directo en archivo con `Guardar JSON en archivo` (Windows/macOS/Linux)
- En Web, usa `Copiar JSON generado` y pegalo en el archivo correspondiente

Notas importantes:
- El editor usa la proporcion real de la imagen para evitar desfases de posicion
- La app movil usa el mismo calculo de proporcion para mantener consistencia

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

## Icono de la aplicacion

Se configuro el icono de launcher para Android, iOS, Web, Windows y macOS
usando esta imagen:

- `assets/plans/ico.png`

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


