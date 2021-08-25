import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key key,
    @required this.nameControl,
    @required this.label,
  }) : super(key: key);

  final TextEditingController nameControl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: nameControl,
      autofocus: true,
      // cursorColor: Colors.blue[400],
      // textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        label: Text(label),
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
