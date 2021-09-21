// formFields/myDateFormField.dart ********************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyDateFormField extends FormField<DateTime> {
  MyDateFormField({
    Key key,
    DateTime initialValue,
    this.dayFocusNode,
    double dayWidth = 40,
    this.monthFocusNode,
    double monthWidth = 40,
    this.yearFocusNode,
    double yearWidth = 60,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    InputDecoration decoration = const InputDecoration(),
    InputDecoration inputDecoration =
        const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(0)),
    Widget separator = const Text('/'),
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    TextAlign textAlign = TextAlign.center,
    TextAlignVertical textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    bool enableSuggestions = true,
    bool autovalidate = false,
    bool maxLengthEnforced = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    this.onChanged,
    GestureTapCallback dayOnTap,
    GestureTapCallback monthOnTap,
    GestureTapCallback yearOnTap,
    VoidCallback onEditingComplete,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    bool enabled = true,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder buildCounter,
  })  : assert(initialValue == null),
        assert(textAlign != null),
        assert(separator != null),
        assert(autofocus != null),
        assert(readOnly != null),
        assert(obscureText != null),
        assert(autocorrect != null),
        assert(enableSuggestions != null),
        assert(autovalidate != null),
        assert(maxLengthEnforced != null),
        assert(scrollPadding != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          'minLines can\'t be greater than maxLines',
        ),
        assert(expands != null),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1, 'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength > 0),
        assert(enableInteractiveSelection != null),
        super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          //autovalidate: autovalidate,
          enabled: enabled,
          builder: (FormFieldState<DateTime> field) {
            final _MyDateFormFieldState state = field;
            final InputDecoration effectiveDecoration =
                (decoration ?? const InputDecoration()).applyDefaults(Theme.of(field.context).inputDecorationTheme);

            String toOriginalFormatString(DateTime dateTime) {
              final y = dateTime.year.toString().padLeft(4, '0');
              final m = dateTime.month.toString().padLeft(2, '0');
              final d = dateTime.day.toString().padLeft(2, '0');
              return "$y$m$d";
            }

            bool isValidDate(String input) {
              try {
                final date = DateTime.parse(input);
                final originalFormatString = toOriginalFormatString(date);
                return input == originalFormatString;
              } catch (e) {
                return false;
              }
            }

            return InputDecorator(
                decoration: effectiveDecoration.copyWith(errorText: field.errorText),
                isEmpty: false,
                isFocused: state._effectiveYearFocusNode.hasFocus ||
                    state._effectiveMonthFocusNode.hasFocus ||
                    state._effectiveDayFocusNode.hasFocus,
                child: Row(mainAxisAlignment: mainAxisAlignment, children: [
                  SizedBox(
                    width: dayWidth,
                    child: TextField(
                      controller: state._effectiveDayController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: inputDecoration,
                      focusNode: state._effectiveDayFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: textInputAction,
                      style: style,
                      strutStyle: strutStyle,
                      textAlign: textAlign,
                      textAlignVertical: textAlignVertical,
                      textDirection: textDirection,
                      textCapitalization: textCapitalization,
                      autofocus: autofocus,
                      toolbarOptions: toolbarOptions,
                      readOnly: readOnly,
                      showCursor: showCursor,
                      obscureText: obscureText,
                      autocorrect: autocorrect,
                      enableSuggestions: enableSuggestions,
                      // maxLengthEnforced: maxLengthEnforced,
                      maxLines: maxLines,
                      minLines: minLines,
                      expands: expands,
                      maxLength: maxLength,
                      onChanged: (value) {
                        if (value.length == 2 && int.parse(value) > 0 && int.parse(value) <= 31) {
                          state._effectiveMonthFocusNode.requestFocus();
                        }
                        if (value != '' &&
                            state._effectiveMonthController.text != '' &&
                            state._effectiveYearController.text != '') {
                          final date =
                              '${state._effectiveYearController.text}${state._effectiveMonthController.text}$value';
                          if (isValidDate(date)) {
                            field.didChange(DateTime.utc(
                              int.parse(state._effectiveYearController.text),
                              int.parse(state._effectiveMonthController.text),
                              int.parse(value),
                            ));
                          } else {
                            field.didChange(null);
                          }
                        }
                      },
                      onTap: dayOnTap,
                      onEditingComplete: () {
                        state._effectiveMonthFocusNode.requestFocus();
                      },
                      enabled: enabled,
                      cursorWidth: cursorWidth,
                      cursorRadius: cursorRadius,
                      cursorColor: cursorColor,
                      scrollPadding: scrollPadding,
                      keyboardAppearance: keyboardAppearance,
                      enableInteractiveSelection: enableInteractiveSelection,
                      buildCounter: buildCounter,
                    ),
                  ),
                  separator,
                  SizedBox(
                    width: monthWidth,
                    child: TextField(
                      controller: state._effectiveMonthController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: inputDecoration,
                      focusNode: state._effectiveMonthFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: textInputAction,
                      style: style,
                      strutStyle: strutStyle,
                      textAlign: textAlign,
                      textAlignVertical: textAlignVertical,
                      textDirection: textDirection,
                      textCapitalization: textCapitalization,
                      autofocus: autofocus,
                      toolbarOptions: toolbarOptions,
                      readOnly: readOnly,
                      showCursor: showCursor,
                      obscureText: obscureText,
                      autocorrect: autocorrect,
                      enableSuggestions: enableSuggestions,
                      //  maxLengthEnforced: maxLengthEnforced,
                      maxLines: maxLines,
                      minLines: minLines,
                      expands: expands,
                      maxLength: maxLength,
                      onChanged: (value) {
                        if (value.length == 2 && int.parse(value) > 0 && int.parse(value) <= 12) {
                          state._effectiveYearFocusNode.requestFocus();
                        }
                        if (value != '' &&
                            state._effectiveDayController.text != '' &&
                            state._effectiveYearController.text != '') {
                          final date =
                              '${state._effectiveYearController.text}$value${state._effectiveDayController.text}';
                          if (isValidDate(date)) {
                            field.didChange(DateTime.utc(
                              int.parse(state._effectiveYearController.text),
                              int.parse(value),
                              int.parse(state._effectiveDayController.text),
                            ));
                          } else {
                            field.didChange(null);
                          }
                        }
                      },
                      onTap: monthOnTap,
                      onEditingComplete: () {
                        state._effectiveYearFocusNode.requestFocus();
                      },
                      enabled: enabled,
                      cursorWidth: cursorWidth,
                      cursorRadius: cursorRadius,
                      cursorColor: cursorColor,
                      scrollPadding: scrollPadding,
                      keyboardAppearance: keyboardAppearance,
                      enableInteractiveSelection: enableInteractiveSelection,
                      buildCounter: buildCounter,
                    ),
                  ),
                  separator,
                  SizedBox(
                    width: yearWidth,
                    child: TextField(
                      controller: state._effectiveYearController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: inputDecoration,
                      focusNode: state._effectiveYearFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: textInputAction,
                      style: style,
                      strutStyle: strutStyle,
                      textAlign: textAlign,
                      textAlignVertical: textAlignVertical,
                      textDirection: textDirection,
                      textCapitalization: textCapitalization,
                      autofocus: autofocus,
                      toolbarOptions: toolbarOptions,
                      readOnly: readOnly,
                      showCursor: showCursor,
                      obscureText: obscureText,
                      autocorrect: autocorrect,
                      enableSuggestions: enableSuggestions,
                      // maxLengthEnforced: maxLengthEnforced,
                      maxLines: maxLines,
                      minLines: minLines,
                      expands: expands,
                      maxLength: maxLength,
                      onChanged: (value) {
                        if (value != '' &&
                            state._effectiveDayController.text != '' &&
                            state._effectiveMonthController.text != '') {
                          final date =
                              '$value${state._effectiveMonthController.text}${state._effectiveDayController.text}';
                          if (isValidDate(date)) {
                            field.didChange(DateTime.utc(
                              int.parse(value),
                              int.parse(state._effectiveMonthController.text),
                              int.parse(state._effectiveDayController.text),
                            ));
                          } else {
                            field.didChange(null);
                          }
                        }
                      },
                      onTap: yearOnTap,
                      onEditingComplete: onEditingComplete,
                      enabled: enabled,
                      cursorWidth: cursorWidth,
                      cursorRadius: cursorRadius,
                      cursorColor: cursorColor,
                      scrollPadding: scrollPadding,
                      keyboardAppearance: keyboardAppearance,
                      enableInteractiveSelection: enableInteractiveSelection,
                      buildCounter: buildCounter,
                    ),
                  ),
                ]));
          },
        );

  final ValueChanged<DateTime> onChanged;
  final FocusNode dayFocusNode;
  final FocusNode monthFocusNode;
  final FocusNode yearFocusNode;

  @override
  _MyDateFormFieldState createState() => _MyDateFormFieldState();
}

class _MyDateFormFieldState extends FormFieldState<DateTime> {
  @override
  MyDateFormField get widget => super.widget;

  TextEditingController _dayController;
  TextEditingController get _effectiveDayController => _dayController;
  TextEditingController _monthController;
  TextEditingController get _effectiveMonthController => _monthController;
  TextEditingController _yearController;
  TextEditingController get _effectiveYearController => _yearController;

  FocusNode _dayFocusNode;
  FocusNode get _effectiveDayFocusNode => widget.dayFocusNode ?? _dayFocusNode;
  FocusNode _monthFocusNode;
  FocusNode get _effectiveMonthFocusNode => widget.monthFocusNode ?? _monthFocusNode;
  FocusNode _yearFocusNode;
  FocusNode get _effectiveYearFocusNode => widget.yearFocusNode ?? _yearFocusNode;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(text: widget.initialValue != null ? widget.initialValue.day.toString() : '');
    _monthController =
        TextEditingController(text: widget.initialValue != null ? widget.initialValue.month.toString() : '');
    _yearController =
        TextEditingController(text: widget.initialValue != null ? widget.initialValue.year.toString() : '');

    if (widget.dayFocusNode == null) {
      _dayFocusNode = FocusNode();
    }
    if (widget.monthFocusNode == null) {
      _monthFocusNode = FocusNode();
    }
    if (widget.yearFocusNode == null) {
      _yearFocusNode = FocusNode();
    }
  }

  @override
  void didChange(DateTime value) {
    super.didChange(value);
    if (this.hasError) {
      this.validate();
    }
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveDayController.text = widget.initialValue != null ? widget.initialValue.day.toString() : null;
      _effectiveMonthController.text = widget.initialValue != null ? widget.initialValue.month.toString() : null;
      _effectiveYearController.text = widget.initialValue != null ? widget.initialValue.year.toString() : null;
    });
  }
}
