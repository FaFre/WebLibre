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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

class TranslationState with FastEquatable {
  final bool isTranslated;
  final bool isTranslateProcessing;
  final bool isOfferTranslate;
  final bool isExpectedTranslate;
  final String? detectedLanguageCode;
  final String? userPreferredLanguageCode;
  final String? requestedFromLanguage;
  final String? requestedToLanguage;
  final String? translationErrorName;
  final bool? displayError;

  TranslationState({
    required this.isTranslated,
    required this.isTranslateProcessing,
    required this.isOfferTranslate,
    required this.isExpectedTranslate,
    this.detectedLanguageCode,
    this.userPreferredLanguageCode,
    this.requestedFromLanguage,
    this.requestedToLanguage,
    this.translationErrorName,
    this.displayError,
  });

  factory TranslationState.$default() => TranslationState(
    isTranslated: false,
    isTranslateProcessing: false,
    isOfferTranslate: false,
    isExpectedTranslate: false,
  );

  factory TranslationState.fromData(TabTranslationStateData data) =>
      TranslationState(
        isTranslated: data.isTranslated,
        isTranslateProcessing: data.isTranslateProcessing,
        isOfferTranslate: data.isOfferTranslate,
        isExpectedTranslate: data.isExpectedTranslate,
        detectedLanguageCode: data.detectedLanguageCode,
        userPreferredLanguageCode: data.userPreferredLanguageCode,
        requestedFromLanguage: data.requestedFromLanguage,
        requestedToLanguage: data.requestedToLanguage,
        translationErrorName: data.translationErrorName,
        displayError: data.displayError,
      );

  bool get hasError =>
      translationErrorName != null && (displayError ?? true);

  @override
  List<Object?> get hashParameters => [
    isTranslated,
    isTranslateProcessing,
    isOfferTranslate,
    isExpectedTranslate,
    detectedLanguageCode,
    userPreferredLanguageCode,
    requestedFromLanguage,
    requestedToLanguage,
    translationErrorName,
    displayError,
  ];
}
