import 'package:flutter/material.dart';

extension RelativeSafeArea on MediaQueryData {
  double relativeSafeArea() {
    return 1.0 - (padding.top / size.height);
  }
}
