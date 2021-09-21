// myMultiSelectionFormField.dart

import 'package:flutter/material.dart';

class MyMultiSelectionFormField<T> extends FormField<List<T>> {
  MyMultiSelectionFormField({
    Key key,
    @required List<T> initialValues, // List of initial selected options

    @required List<T> options, // List of available options

    @required Widget Function(T) titleBuilder, // Widget builder for an option in the dropdown menu

    @required Widget Function(T) chipLabelBuilder, // Widget builder for the selected options in the chipList Widget

    hint, // A placeholder widget that is displayed by the dropdown button
    this.decoration = const InputDecoration(),
    this.onChanged,
    FormFieldSetter<List> onSaved,
    FormFieldValidator<List> validator,
  })  : assert(options == null ||
            options.isEmpty ||
            initialValues == null ||
            initialValues.every((value) =>
                options.where((T option) {
                  return option == value;
                }).length ==
                1)),
        assert(decoration != null),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValues,
          validator: validator,
          builder: (FormFieldState<List> field) {
            final InputDecoration effectiveDecoration = decoration.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return InputDecorator(
              decoration: effectiveDecoration.copyWith(errorText: field.errorText),
              isEmpty: field.value.isEmpty,
              child: MyMultiSelectionField<T>(
                values: field.value,
                options: options,
                titleBuilder: titleBuilder,
                chipLabelBuilder: chipLabelBuilder,
                hint: field.value.isNotEmpty ? hint : null,
                onChanged: field.didChange,
              ),
            );
          },
        );
  final ValueChanged<List> onChanged;
  final InputDecoration decoration;
  @override
  _MyMultiSelectionFormFieldState<T> createState() => _MyMultiSelectionFormFieldState();
}

class _MyMultiSelectionFormFieldState<T> extends FormFieldState<List<T>> {
  @override
  MyMultiSelectionFormField<T> get widget => super.widget;
  @override
  void didChange(List values) {
    super.didChange(values);
    if (widget.onChanged != null) {
      widget.onChanged(values);
    }
  }
}

// fields/myMultiselectionField.dart ************************

class MyMultiSelectionField<T> extends StatelessWidget {
  MyMultiSelectionField({
    Key key,
    this.values,
    @required this.options,
    this.titleBuilder,
    @required this.chipLabelBuilder,
    this.hint,
    @required this.onChanged,
  })  : assert(options == null ||
            options.isEmpty ||
            values == null ||
            values.every((value) =>
                options.where((T option) {
                  return option == value;
                }).length ==
                1)),
        assert(chipLabelBuilder != null),
        assert(onChanged != null),
        super(key: key);
  final ValueChanged<List> onChanged;
  final List<T> values;
  final List<T> options;
  final Widget hint;
  final Widget Function(T) titleBuilder;
  final Widget Function(T) chipLabelBuilder;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: null,
            items: options
                .map<DropdownMenuItem>(
                  (T option) => DropdownMenuItem(
                    value: option,
                    child: MyCheckboxListTile(
                      selected: values.contains(option),
                      title: titleBuilder(option),
                      onChanged: (_) {
                        if (!values.contains(option)) {
                          values.add(option);
                        } else {
                          values.remove(option);
                        }
                        onChanged(values);
                      },
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (context) {
              return options.map<Widget>((T option) {
                return Text('');
              }).toList();
            }, // Selected items won't be displayed here as they are already displayed in the chip list
            hint: hint, onChanged: onChanged == null ? null : (T value) {},
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: MyChipList(
                values: values,
                chipBuilder: (T value) {
                  return Chip(
                    label: chipLabelBuilder(value),
                    onDeleted: () {
                      values.remove(value);
                      onChanged(values);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MyCheckboxListTile extends StatefulWidget {
  MyCheckboxListTile({
    Key key,
    @required this.title,
    @required this.onChanged,
    @required this.selected,
  })  : assert(title != null),
        assert(onChanged != null),
        assert(selected != null),
        super(key: key);
  final Widget title;
  final dynamic onChanged;
  final bool selected;
  @override
  _MyCheckboxListTileState createState() => _MyCheckboxListTileState();
}

class _MyCheckboxListTileState extends State<MyCheckboxListTile> {
  _MyCheckboxListTileState();
  bool _checked;
  @override
  void initState() {
    _checked = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _checked,
      selected: _checked,
      title: widget.title,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        widget.onChanged(checked);
        setState(() {
          _checked = checked;
        });
      },
    );
  }
}

class MyChipList<T> extends StatelessWidget {
  const MyChipList({
    @required this.values,
    @required this.chipBuilder,
  });
  final List<T> values;
  final Chip Function(T) chipBuilder;
  List _buildChipList() {
    final List items = [];
    for (T value in values) {
      items.add(chipBuilder(value));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChipList(),
    );
  }
}
