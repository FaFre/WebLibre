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

class KagiCategoryDefinition {
  final String slug;
  final String label;
  final String description;
  final String emoji;

  const KagiCategoryDefinition({
    required this.slug,
    required this.label,
    required this.description,
    required this.emoji,
  });
}

class KagiCategories {
  final Map<String, KagiCategoryDefinition> categories;
  final Map<String, List<String>> groups;
  final Map<String, String> remap;

  const KagiCategories({
    required this.categories,
    required this.groups,
    required this.remap,
  });

  factory KagiCategories.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as Map<String, dynamic>;
    final categories = rawCategories.map(
      (slug, data) => MapEntry(
        slug,
        KagiCategoryDefinition(
          slug: slug,
          label: (data as Map<String, dynamic>)['label'] as String,
          description: data['description'] as String,
          emoji: data['emoji'] as String,
        ),
      ),
    );

    final rawGroups = json['groups'] as Map<String, dynamic>;
    final groups = rawGroups.map(
      (name, slugs) => MapEntry(name, (slugs as List<dynamic>).cast<String>()),
    );

    final rawRemap = json['remap'] as Map<String, dynamic>;
    final remap = rawRemap.cast<String, String>();

    return KagiCategories(categories: categories, groups: groups, remap: remap);
  }
}
