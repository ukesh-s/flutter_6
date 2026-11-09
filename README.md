# Experiment 6 — Student Records with SQLite

Standalone Flutter app demonstrating Create and Read operations for student records using SQLite. The app seeds two example students on first launch; subsequently added records are saved in the local database.

## Platforms

SQLite database operations are supported on Windows and Android. On web, this project uses an in-memory demonstration fallback because the `sqflite` plugin is not supported in browsers; web records do not persist.

## Run

From this folder:

```sh
flutter pub get
flutter run -d windows
# or: flutter run -d chrome (in-memory demo only)
```
