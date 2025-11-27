import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/uuid.dart';

part 'profile.g.dart';

@JsonSerializable()
@CopyWith()
class Profile with FastEquatable {
  @CopyWithField(immutable: true)
  final String id;
  final String name;

  late final uuidValue = UuidValue.fromString(id);

  Profile({required this.id, required this.name});

  factory Profile.create({required String name}) {
    return Profile(id: uuid.v7(), name: name);
  }

  @override
  List<Object?> get hashParameters => [id, name];

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
