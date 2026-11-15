/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';

/// How a component differs between installed and offered build (4.3).
/// Nothing in this layer says "security".
enum ComponentChangeKind { unchanged, upgraded, downgraded, changed, unknown }

class ComponentChange with FastEquatable {
  ComponentChange({
    required this.id,
    required this.installed,
    required this.target,
    required this.kind,
  });

  final ComponentId id;
  final ComponentIdentity installed;
  final ComponentIdentity target;
  final ComponentChangeKind kind;

  @override
  List<Object?> get hashParameters => [id, installed, target, kind];
}

/// How advisories relate to the offered update (5.2).
class AdvisorySummary with FastEquatable {
  AdvisorySummary({required this.resolved, required this.unresolved});

  static final none = AdvisorySummary(resolved: [], unresolved: []);

  /// Affect the installation and are fixed by the target.
  final List<Advisory> resolved;

  /// Affect the installation; only a later version fixes them.
  final List<Advisory> unresolved;

  @override
  List<Object?> get hashParameters => [resolved, unresolved];
}

class ReleaseNotesBlock with FastEquatable {
  ReleaseNotesBlock({required this.appVersion, required this.notes});

  final String appVersion;
  final ReleaseNotes notes;

  @override
  List<Object?> get hashParameters => [appVersion, notes];
}

/// Everything the UI and a later security notice need about one offered
/// update.
class UpdateAssessment with FastEquatable {
  UpdateAssessment({
    required this.targetId,
    required this.versionCode,
    required this.logicalReleaseSequence,
    required this.appVersion,
    required this.target,
    required this.componentChanges,
    required this.securityClassification,
    required this.advisories,
    required this.releaseNotes,
    required this.releaseNotesUrl,
  });

  final String targetId;
  final int versionCode;
  final int? logicalReleaseSequence;

  /// Null when no verified description exists (Play without catalogue).
  final String? appVersion;

  /// Null when the accepted catalogue doesn't describe the offered version
  /// (or none could be read); Play's update is still offered (8.1).
  final UpdateTarget? target;

  /// Null when details aren't available.
  final List<ComponentChange>? componentChanges;
  final SecurityClassification securityClassification;
  final AdvisorySummary advisories;

  /// One block per release in (installed, target] that has a summary,
  /// newest first.
  final List<ReleaseNotesBlock> releaseNotes;
  final Uri? releaseNotesUrl;

  ArtifactRef? get artifact => target?.artifact;

  /// What announcements compare: the logical release sequence, or the
  /// version code where the catalogue gives none.
  int get releaseSequence => logicalReleaseSequence ?? versionCode;

  bool get includesSecurityFixes =>
      securityClassification == SecurityClassification.fixesIncluded ||
      securityClassification == SecurityClassification.critical;

  @override
  List<Object?> get hashParameters => [
    targetId,
    versionCode,
    logicalReleaseSequence,
    appVersion,
    target,
    componentChanges,
    securityClassification,
    advisories,
    releaseNotes,
    releaseNotesUrl,
  ];
}
