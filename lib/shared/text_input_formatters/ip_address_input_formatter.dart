import 'package:flutter/services.dart';

class IpAddressInputFormatter extends TextInputFormatter {
  String separator = '-';

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (newValue.text.length > oldValue.text.length) {
        String lastEnteredChar = newValue.text.substring(newValue.text.length - 1);
        var value = newValue.text;
        if (lastEnteredChar == separator) {
          if (RegExp(separator).allMatches(newValue.text).length > 3) {
            return oldValue;
          }
          if (newValue.text.length > 9) {
            return oldValue;
          }
          return TextEditingValue(
            text: '$value',
            selection: TextSelection.collapsed(
              offset: value.length,
            ),
          );
        }
        if (!_isNumeric(lastEnteredChar)) return oldValue;
        if (_isNumeric(newValue.text.split(separator).last) && newValue.text.split(separator).last.length == 3) {
          if (newValue.text.length < 16 && newValue.text.split(separator).last.length <= 3) {
            var s = '$separator';
            s = newValue.text.length == 15 ? '' : s;
            s = RegExp(separator).allMatches(newValue.text).length > 2 ? '' : s;
            value = '${newValue.text}$s';
          } else if (RegExp(separator).allMatches(newValue.text).length > 2) {
            return oldValue;
          } else {
            return oldValue;
          }
        } else if (newValue.text.length > 15) {
          return oldValue;
        } else if (RegExp(separator).allMatches(newValue.text).length == 3 &&
            newValue.text.split(separator).last.length > 3) {
          return oldValue;
        }
        return TextEditingValue(
          text: '$value',
          selection: TextSelection.collapsed(
            offset: value.length,
          ),
        );
      }
    }
    return newValue;
  }

  bool _isNumeric(String s) {
    if (s == null) return false;
    return double.tryParse(s) != null;
  }
}
