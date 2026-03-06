# campus_map_app

Campus Map is a Flutter application designed to help students and visitors
navigate the university campus. The app loads floor plans for different
buildings, allows searching for classrooms, and shows the user's real-time
location on the map when accessed from a mobile browser or device.

## Features

- 🗺️ Interactive map with building markers and floor plans
- 🔍 Classroom search with deep linking to floor views
- 📍 Geolocation tracking using the device's GPS (HTTPS required on web)
- 🧭 Status indicator for location permissions & GPS state, positioned above the follow-location button
- 🛣️ Route calculation with distance and bearing display
- 🌙 Dark mode toggle for comfortable viewing in any lighting
- ♿ Accessibility features (adjustable text size: 80%, 100%, 120%)
- 📱 Progressive Web App (PWA) ready - installable on home screen
- 🎨 Smooth page transitions and animations
- 📊 Route instructions with cardinal directions and distance

## Project Structure

```
lib/
  main.dart                           # entry point, map screen and location logic
  screens/
    floor_plan_screen.dart           # displays a selected floor plan with classrooms
  services/
    floor_loader.dart                # loads JSON floor data
    classroom_index_service.dart     # builds search index
    theme_provider.dart              # manages dark/light theme and text scaling
    route_handler.dart               # calculates routes and directions
  search/
    classroom_search.dart            # search delegate UI
  models/
    block.dart                       # campus building definitions
    search_classroom.dart            # search result model
  data/
    campus_data.dart                 # hardcoded list of campus blocks
  widgets/
    animated_routes.dart             # custom page transition animations
    distance_info_widget.dart        # displays route info card

test/                                # unit tests and widget tests
assets/                              # floor plans and JSON data files
pubspec.yaml                         # dependencies and asset declarations
```

## Running

### Web (Local Development)

```bash
flutter config --enable-web
flutter run -d web-server --web-port 8081
# open http://localhost:8081/ or https://<published-url>/
```

> Note: Location permissions require HTTPS. For local testing with location:
> - Use Chrome/Edge (they allow HTTP geolocation on localhost)
> - Or use a local HTTPS server with mkcert or ngrok
> - Or deploy to GitHub Pages for public HTTPS access

### Mobile

Connect a device and run:

```bash
flutter run
```

## Deployment

The app is deployed as a static site using GitHub Pages. The `build/web`
folder contains the compiled output; it's automatically published to:

```
https://jeanaucapina.github.io/Flutter/
```

### Deploying Changes

1. Build the web version:
   ```bash
   flutter build web
   ```

2. Deploy to GitHub Pages:
   ```bash
   git checkout gh-pages
   git --work-tree=build/web add --all
   git --work-tree=build/web commit -m "Deploy updated build"
   git push origin gh-pages
   git checkout main
   ```

## Testing

Run unit tests:

```bash
flutter test
```

### Test Coverage

- `test/route_handler_test.dart` - Tests for route calculation and distance formatting
- `test/main_test.dart` - Widget tests for theme toggle and UI elements

## Technologies & Dependencies

- **Flutter** - UI framework
- **flutter_map** - Interactive map widget
- **geolocator** - GPS location services
- **provider** - State management
- **google_fonts** - Typography
- **latlong2** - Geographic coordinates

## Accessibility

- 🌙 **Dark Mode** - Toggle dark/light theme via AppBar button
- 🔤 **Text Scaling** - 3 presets (80%, 100%, 120%) in Accessibility menu
- 🎯 **Tooltip Hints** - All buttons have descriptive tooltips

## Architecture Notes

The app uses the Provider pattern for state management (theme), clean service-based
architecture for location and routing logic, and custom page transitions for smooth UX.
Floor data is loaded asynchronously from JSON files in assets.

## License

MIT License


