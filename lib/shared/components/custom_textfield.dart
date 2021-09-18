import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController nameControl;
  final String label;
  final void Function(bool hasFocus) onFocusChange;
  final void Function() onTap;
  final List<TextInputFormatter> inputFormatters;

  const CustomTextField({
    Key key,
    @required this.nameControl,
    @required this.label,
    this.onFocusChange,
    this.onTap,
    this.inputFormatters,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    if (widget.onFocusChange != null) {
      widget.onFocusChange(_focus.hasFocus);
    }
    //debugPrint("Focus: " + _focus.hasFocus.toString());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: widget.inputFormatters,
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap();
        }
      },
      focusNode: _focus,
      controller: widget.nameControl,
      autofocus: true,
      // cursorColor: Colors.blue[400],
      // textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        label: Text(widget.label),
        /*border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue[400],
          ),
        ),
        focusColor: Colors.blue[400],
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
          color: Colors.blue[400],
        )),*/
        //hintText: label,
      ),
    );
  }
}
