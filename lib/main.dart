import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, title: 'Student Records', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff16836b)), useMaterial3: true), home: const StudentPage());
}

class StudentPage extends StatefulWidget { const StudentPage({super.key}); @override State<StudentPage> createState() => _StudentPageState(); }
class _StudentPageState extends State<StudentPage> {
  Database? _db;
  List<Map<String, Object?>> _students = [];
  final List<Map<String, Object?>> _webStudents = [];
  int _nextWebId = 1;
  static const demoStudents = [{'name': 'Avery Chen', 'course': 'Computer Science'}, {'name': 'Noah Kim', 'course': 'Information Technology'}];
  final _name = TextEditingController(), _course = TextEditingController();
  String? _error;
  Future<void> _load() async { if (kIsWeb) { if (_webStudents.isEmpty) _webStudents.addAll(demoStudents.map((s) => <String, Object?>{'id': _nextWebId++, ...s})); if (mounted) setState(() => _students = List.of(_webStudents)); return; } try { final db = await _database(); final rows = await db.query('students', orderBy: 'id DESC'); if (rows.isEmpty) { for (final student in demoStudents) { await db.insert('students', student); } } final loaded = rows.isEmpty ? await db.query('students', orderBy: 'id DESC') : rows; if (mounted) setState(() { _db = db; _students = loaded; }); } catch (e) { if (mounted) setState(() => _error = 'Could not open the local SQLite database: $e'); } }
  Future<Database> _database() async => _db ??= await openDatabase('student_records.db', version: 1, onCreate: (db, version) => db.execute('CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, course TEXT NOT NULL)'));
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _name.dispose(); _course.dispose(); _db?.close(); super.dispose(); }
  Future<void> _add() async { final name = _name.text.trim(), course = _course.text.trim(); if (name.isEmpty || course.isEmpty) { setState(() => _error = 'Enter both a student name and course.'); return; } if (kIsWeb) { setState(() { _webStudents.insert(0, {'id': _nextWebId++, 'name': name, 'course': course}); _students = List.of(_webStudents); _name.clear(); _course.clear(); _error = null; }); return; } try { final db = await _database(); await db.insert('students', {'name': name, 'course': course}); _name.clear(); _course.clear(); setState(() => _error = null); await _load(); } catch (e) { setState(() => _error = 'Could not save the student: $e'); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Student Records')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: ListView(padding: const EdgeInsets.all(20), children: [const Card(child: ListTile(leading: Icon(Icons.storage), title: Text(kIsWeb ? 'Temporary in-memory demo' : 'Local SQLite database'), subtitle: Text(kIsWeb ? 'Records reset when the browser is refreshed.' : 'Student records are saved in a local SQLite database.'))), const SizedBox(height: 12), TextField(controller: _name, decoration: const InputDecoration(labelText: 'Student name', border: OutlineInputBorder())), const SizedBox(height: 10), TextField(controller: _course, decoration: const InputDecoration(labelText: 'Course / class', border: OutlineInputBorder())), const SizedBox(height: 10), FilledButton.icon(onPressed: _add, icon: const Icon(Icons.person_add), label: const Text('Add student')), if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))), const SizedBox(height: 18), Text('Saved students (${_students.length})', style: Theme.of(context).textTheme.titleLarge), if (_students.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No records yet. Add a student to get started.')), ..._students.map((s) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.school)), title: Text(s['name'] as String), subtitle: Text(s['course'] as String))))]))));
}
