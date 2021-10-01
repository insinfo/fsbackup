import 'package:flutter/material.dart';

class LogProvider extends ChangeNotifier {
  List<String> _lines = [];

  void addLine(String value) {
    if (_lines.length > 100) {
      _lines.clear();
    }
    _lines.add(value);
    notifyListeners();
  }

  List<String> getLines() {
    return _lines;
  }

  String get getAllText => _lines.join('\r\n');

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
