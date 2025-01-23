class VectorDatabaseMigrator {
  final int dimensions;

  String get vectorTableDefinition => '''
CREATE VIRTUAL TABLE document_vec using vec0(
  id TEXT PRIMARY KEY,
  main_document_id TEXT,
  context_id TEXT PARTITION KEY,
  embedding float[$dimensions],
  content_hash TEXT
);
''';

  VectorDatabaseMigrator({required this.dimensions});
}
