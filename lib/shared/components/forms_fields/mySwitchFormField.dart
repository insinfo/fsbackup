// mySwitchFormField.dart

import 'package:flutter/material.dart';

class MySwitchFormField extends FormField<bool> {
  MySwitchFormField({
    Key key,
    bool initialValue, // Initial field value
    this.decoration = const InputDecoration(), // A BoxDecoration to style the field FormFieldSetter

    onSaved, // Method called when when the form is saved FormFieldValidator

    validator, // Method called for validation

    this.onChanged, // Method called whenever the value changes

    this.constraints = const BoxConstraints(), // A BoxConstraints to set the switch size
  })  : assert(decoration != null),
        assert(initialValue != null),
        assert(constraints != null),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState field) {
            final InputDecoration effectiveDecoration = decoration.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return InputDecorator(
              decoration: effectiveDecoration.copyWith(errorText: field.errorText),
              isEmpty: field.value == null,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: constraints,
                    child: Switch(
                      value: field.value,
                      onChanged: field.didChange,
                    ),
                  ),
                ],
              ),
            );
          },
        );
  final ValueChanged onChanged;
  final InputDecoration decoration;
  final BoxConstraints constraints;
  @override
  FormFieldState<bool> createState() => _MySwitchFormFieldState();
}

class _MySwitchFormFieldState extends FormFieldState<bool> {
  @override
  MySwitchFormField get widget => super.widget;
  @override
  void didChange(bool value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}
