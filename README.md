# campus_map_app

Campus Map is a Flutter application designed to help students and visitors
navigate the university campus. The app loads floor plans for different
buildings, allows searching for classrooms, and shows the user's real-time
location on the map when accessed from a mobile browser or device.

## Features

- Interactive map with building markers and floor plans
- Classroom search with deep linking to floor views
- Geolocation tracking using the device's GPS (HTTPS is required on web)
- Route drawing from user location to selected classroom
- Offline JSON floor data stored in `assets`/`data` directories

## Project Structure

```
lib/
  main.dart             # entry point, map screen and location logic
  screens/
    floor_plan_screen.dart  # displays a selected floor plan with classrooms
  services/
    floor_loader.dart   # loads JSON floor data
    classroom_index_service.dart  # builds search index
  search/
    classroom_search.dart  # search delegate UI
  models/
    block.dart          # campus building definitions
    search_classroom.dart # search result model
  data/
    campus_data.dart    # hardcoded list of campus blocks

test/                   # widget tests
assets/                 # floor plans and JSON data files
pubspec.yaml            # dependencies and asset declarations
```

## Running

### Web

```bash
flutter config --enable-web
flutter run -d web-server --web-port 8081
# open http://localhost:8081/ or https://<published-url>/
```

> Note: Location permissions require HTTPS. Use GitHub Pages, Netlify, or
a local HTTPS server (mkcert/ngrok) when testing on an iPhone.

### Mobile

Connect a device and run:

```bash
flutter run
```

## Deployment

The app can be deployed as a static site using GitHub Pages. The `build/web`
folder contains the compiled output; pushing this to a `gh-pages` branch or
hosting via Netlify/Vercel works.

## License

MIT License (add your own if desired)

