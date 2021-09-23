import 'package:flutter/material.dart';

class LogProvider extends ChangeNotifier {
  List<String> _lines = [];

  void addLine(String value) {
    if (_lines.length > 10) {
      _lines.clear();
    }
    _lines.add(value);
    notifyListeners();
  }

  List<String> getLines() {
    return _lines;
  }
}
