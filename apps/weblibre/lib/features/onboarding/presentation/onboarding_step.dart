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

/// The steps of the onboarding, each one page. The page list is built from
/// them, keyed by step, so a step that appears or goes (Privacy & security
/// follows the Advanced privacy switch) moves the other pages rather than
/// rebuilding them.
enum OnboardingStep {
  welcome,
  preset,
  search,
  layout,
  privacySecurity,
  yourSetup,
  permissions,

  /// A review after an update: uBlock Origin on its own.
  uBlock,

  /// The revision-1 review: on-device AI alone.
  aiConfiguration;

  /// The key of this step's page in the onboarding's page list.
  ValueKey<OnboardingStep> get pageKey => ValueKey(this);
}

/// Opens [step] in the onboarding, for a row that leads back to a step.
typedef OpenOnboardingStep = void Function(OnboardingStep step);
