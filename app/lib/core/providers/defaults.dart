import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'defaults.g.dart';

@Riverpod(keepAlive: true)
Color lightSeedColorFallback(Ref ref) => const Color(0xFF167C80);

@Riverpod(keepAlive: true)
Color darkSeedColorFallback(Ref ref) => const Color(0xFF167C80);

@Riverpod(keepAlive: true)
Uri docsUri(Ref ref) => Uri.parse('https://docs.weblibre.eu/');
