import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

MenuController useMenuController() {
  return useMemoized(() => MenuController());
}
