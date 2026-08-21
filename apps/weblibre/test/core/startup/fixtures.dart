import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Locates `packages/flutter_mozilla_components/test_fixtures/startup` by walking
/// up from the current directory, so the suite does not depend on how the runner
/// sets its working directory.
Directory startupFixturesDir() {
  var dir = Directory.current;

  while (true) {
    final candidate = Directory(
      p.join(
        dir.path,
        'packages',
        'flutter_mozilla_components',
        'test_fixtures',
        'startup',
      ),
    );
    if (candidate.existsSync()) return candidate;

    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not locate shared startup fixtures from ${Directory.current.path}');
    }
    dir = parent;
  }
}

Map<String, Object?> readFixture(String name) {
  final file = File(p.join(startupFixturesDir().path, name));
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}
