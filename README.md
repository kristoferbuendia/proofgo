# Verify IT — Dart Web

This folder contains the standalone Dart web edition of the Verify IT student clearance app. It does not modify or depend on the original HTML/Capacitor project.

## Features

- First-run student profile setup with optional profile photo
- Responsive dashboard and clearance checklist
- School event search, creation, deletion, and proof selection
- Attendance proof image preview and clearance completion
- Light, dark, and AMOLED display modes
- Browser-local persistence through `localStorage`

## Run during development

Install the Dart SDK, open this folder in a terminal, then run:

```powershell
dart pub get
dart run webdev serve
```

If `webdev` is not installed yet:

```powershell
dart pub global activate webdev
```

Open the address printed by `webdev` (normally `http://localhost:8080`).

## Create a production build

```powershell
New-Item -ItemType Directory -Force build\web
dart compile js -O4 web\main.dart -o build\web\main.dart.js
Copy-Item web\index.html,web\styles.css build\web
```

Serve the production build with the included Dart server:

```powershell
dart run tool\serve.dart
```

Then open `http://127.0.0.1:8080`. Do not open `index.html` directly from the filesystem, because browsers may block compiled JavaScript resources in `file://` mode.
