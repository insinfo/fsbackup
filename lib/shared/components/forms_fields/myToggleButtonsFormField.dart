// myToggleButtonsFormField.dart

import 'package:flutter/material.dart';
import 'package:fsbackup/shared/components/forms_fields/myToggleButtons.dart';

class MyToggleButtonsFormField<T> extends FormField<T> {
  MyToggleButtonsFormField({
    Key key,
    this.initialValue, // Initial selected option

    @required this.items, // Available options

    @required this.itemBuilder, // Widget builder for an option

    @required this.selectedItemBuilder, // Widget builder for the selected option
    this.decoration = const InputDecoration(),
    this.onChanged,
    FormFieldSetter onSaved,
    FormFieldValidator validator,
  })  : assert(decoration != null),
        assert(items != null),
        assert(itemBuilder != null),
        assert(selectedItemBuilder != null),
        assert(initialValue == null || items.contains(initialValue)),
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
              child: MyToggleButtons<T>(
                items: items,
                value: field.value,
                itemBuilder: itemBuilder,
                selectedItemBuilder: selectedItemBuilder,
                onPressed: field.didChange,
              ),
            );
          },
        );
  final List<T> items;
  final ValueChanged<T> onChanged;
  final T initialValue;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget Function(BuildContext, T) selectedItemBuilder;
  final InputDecoration decoration;
  @override
  _MyToggleButtonsFormFieldState<T> createState() => _MyToggleButtonsFormFieldState<T>();
}

class _MyToggleButtonsFormFieldState<T> extends FormFieldState<T> {
  @override
  MyToggleButtonsFormField<T> get widget => super.widget;
  @override
  void didChange(T value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}
