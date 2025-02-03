import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';

class ContainerMetadataConverter
    implements TypeConverter<ContainerMetadata, String> {
  const ContainerMetadataConverter();

  @override
  ContainerMetadata fromSql(String fromDb) {
    final json = jsonDecode(fromDb) as Map<String, dynamic>;
    return ContainerMetadata.fromJson(json);
  }

  @override
  String toSql(ContainerMetadata value) {
    return jsonEncode(value.toJson());
  }
}
