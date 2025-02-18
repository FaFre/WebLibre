import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_vec/sqlite3_vec.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Sqlite3Vec.ensureExtensionLoaded();

  final db = sqlite3.openInMemory();

  runApp(MyApp(db: db));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.db});

  final Database db;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.db.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final version =
        widget
            .db //
            .select('SELECT vec_version() as version;')
            .first['version'];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('sqlite-vec')),
        body: Center(child: Text('version: $version')),
      ),
    );
  }
}
