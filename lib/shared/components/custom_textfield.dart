import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController nameControl;
  final String label;
  final void Function(bool hasFocus) onFocusChange;
  final void Function() onTap;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;

  final String Function(String) validator;

  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final String initialValue;
  final String hintText;
  //custom
  final bool isPassword;

  CustomTextField({
    Key key,
    this.nameControl,
    this.label = '',
    this.onFocusChange,
    this.onTap,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.isPassword = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.initialValue,
    this.hintText,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode _focus = FocusNode();
  bool _isObscure = true;
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
    return TextFormField(
      obscureText: widget.isPassword == false ? widget.obscureText : _isObscure,
      enableSuggestions: widget.enableSuggestions,
      autocorrect: widget.autocorrect,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      initialValue: widget.initialValue,

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
          hintText: widget.hintText,
          label: Text(widget.label),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  })
              : null
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
