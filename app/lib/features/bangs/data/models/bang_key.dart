import 'package:json_annotation/json_annotation.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

class BangKey {
  final String trigger;
  final BangGroup group;

  const BangKey({required this.group, required this.trigger});

  @override
  String toString() {
    return '${group.name}::$trigger';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangKey &&
          runtimeType == other.runtimeType &&
          trigger == other.trigger &&
          group == other.group;

  @override
  int get hashCode => Object.hash(trigger, group);

  static BangKey? tryFromString(String key) {
    try {
      final [group, trigger] = key.split('::');
      return BangKey(
        group: BangGroup.values.firstWhere((g) => g.name == group),
        trigger: trigger,
      );
    } catch (_) {
      return null;
    }
  }
}

class BangKeyConverter implements JsonConverter<BangKey?, String?> {
  const BangKeyConverter();

  @override
  BangKey? fromJson(String? json) {
    return json.mapNotNull((json) => BangKey.tryFromString(json));
  }

  @override
  String? toJson(BangKey? object) {
    return object?.toString();
  }
}
