import 'package:fast_equatable/fast_equatable.dart';

class SiteAssignment with FastEquatable {
  final String id;
  final String? contextualIdentity;
  final Uri assignedSite;

  SiteAssignment({
    required this.id,
    required this.contextualIdentity,
    //Drift type casting issue should be non null
    required String? assignedSite,
  }) : assignedSite = Uri.parse(assignedSite!);

  @override
  List<Object?> get hashParameters => [id, contextualIdentity, assignedSite];
}
