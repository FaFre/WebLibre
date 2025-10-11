import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rfp_target.g.dart';

@JsonSerializable()
class RFPTarget with FastEquatable {
  final String name;
  final int id;
  final String? description;
  final List<String> keywords;

  RFPTarget({
    required this.name,
    required this.id,
    this.description,
    required this.keywords,
  });

  factory RFPTarget.fromJson(Map<String, dynamic> json) =>
      _$RFPTargetFromJson(json);

  Map<String, dynamic> toJson() => _$RFPTargetToJson(this);

  @override
  List<Object?> get hashParameters => [name, id, description, keywords];
}
