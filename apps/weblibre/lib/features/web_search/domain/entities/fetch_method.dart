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
import 'package:flutter/material.dart';

/// Capture pipeline selector. Each choice maps to a (method, variant) pair
/// understood by the search backend's capture clients.
enum FetchMethodChoice {
  /// Trafilatura — extracted reader-mode text + metadata. Not a "capture"
  /// per se; goes through the `fetchPage` command.
  trafilatura(method: null, variant: null),

  /// SingleFile — self-contained HTML archive.
  singlefileHtml(method: 'singlefile', variant: 'balanced'),

  /// shot-scraper — PDF rendering.
  shotScraperPdf(method: 'shot-scraper', variant: 'pdf'),

  /// shot-scraper — PNG screenshot.
  shotScraperPng(method: 'shot-scraper', variant: 'png');

  const FetchMethodChoice({required this.method, required this.variant});

  final String? method;
  final String? variant;

  static FetchMethodChoice? forCapture({
    required String method,
    required String variant,
  }) {
    for (final choice in FetchMethodChoice.values) {
      if (choice.method == method && choice.variant == variant) {
        return choice;
      }
    }
    return null;
  }

  IconData get icon => switch (this) {
    FetchMethodChoice.trafilatura => Icons.description_outlined,
    FetchMethodChoice.singlefileHtml => Icons.archive_outlined,
    FetchMethodChoice.shotScraperPdf => Icons.picture_as_pdf_outlined,
    FetchMethodChoice.shotScraperPng => Icons.image_outlined,
  };
}
