import 'package:flutter/material.dart';
import 'package:fsbackup/models/servidor.dart';
import 'package:fsbackup/shared/components/servidor_selection_dialog.dart';

class ServidorPicker extends StatefulWidget {
  final ValueChanged<Servidor> onChanged;
  final ValueChanged<Servidor> onInit;
  final String initialSelection;

  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;

  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final TextStyle dialogTextStyle;
  final WidgetBuilder emptySearchBuilder;
  final Function(Servidor) builder;
  final bool enabled;
  final TextOverflow textOverflow;
  final Icon closeIcon;

  /// Barrier color of ModalBottomSheet
  final Color barrierColor;

  /// Background color of ModalBottomSheet
  final Color backgroundColor;

  /// BoxDecoration for dialog
  final BoxDecoration boxDecoration;

  /// the size of the selection dialog
  final Size dialogSize;

  /// Background color of selection dialog
  final Color dialogBackgroundColor;

  /// used to customize the country list
  final List<String> countryFilter;

  /// aligns the flag and the Text left
  ///
  /// additionally this option also fills the available space of the widget.
  /// this is especially useful in combination with [showOnlyCountryWhenClosed],
  /// because longer country names are displayed in one line
  final bool alignLeft;

  /// Use this property to change the order of the options
  final Comparator<Servidor> comparator;

  /// Set to true if you want to hide the search part
  final bool hideSearch;

  /// Set to true if you want to show drop down button
  final bool showDropDownButton;

  /// [BoxDecoration] for the flag image
  final Decoration flagDecoration;

  /// An  argument for injecting a list of items
  final List<Servidor> items;

  ServidorPicker({
    this.onChanged,
    this.onInit,
    this.initialSelection,
    this.textStyle,
    this.padding = const EdgeInsets.all(8.0),
    this.searchDecoration = const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Busca'),
    this.searchStyle,
    this.dialogTextStyle,
    this.emptySearchBuilder,
    this.alignLeft = false,
    this.flagDecoration,
    this.builder,
    this.enabled = true,
    this.textOverflow = TextOverflow.ellipsis,
    this.barrierColor,
    this.backgroundColor,
    this.boxDecoration,
    this.comparator,
    this.countryFilter,
    this.hideSearch = false,
    this.showDropDownButton = true,
    this.dialogSize,
    this.dialogBackgroundColor,
    this.closeIcon = const Icon(Icons.close),
    @required this.items,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var elements = [...items];
    if (comparator != null) {
      elements.sort(comparator);
    }

    if (countryFilter != null && countryFilter.isNotEmpty) {
      final uppercaseCustomList = countryFilter.map((c) => c.toUpperCase()).toList();
      elements =
          elements.where((c) => uppercaseCustomList.contains(c.nome) || uppercaseCustomList.contains(c.host)).toList();
    }

    return _ServidorPickerState(elements);
  }
}

class _ServidorPickerState extends State<ServidorPicker> {
  Servidor selectedItem;
  List<Servidor> elements = [];

  _ServidorPickerState(this.elements);

  @override
  Widget build(BuildContext context) {
    Widget _widget;
    if (widget.builder != null)
      _widget = InkWell(
        onTap: showPickerDialog,
        child: widget.builder(selectedItem),
      );
    else {
      _widget = TextButton(
        onPressed: widget.enabled ? showPickerDialog : null,
        child: Padding(
          padding: widget.padding,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
                child: Text(
                  selectedItem.nome,
                  style: widget.textStyle ?? Theme.of(context).textTheme.button,
                  overflow: widget.textOverflow,
                ),
              ),
              if (widget.showDropDownButton)
                Flexible(
                  flex: widget.alignLeft ? 0 : 1,
                  fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
                  child: Padding(
                      padding: widget.alignLeft
                          ? const EdgeInsets.only(right: 16.0, left: 8.0)
                          : const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                        size: 32.0,
                      )),
                ),
            ],
          ),
        ),
      );
    }
    return _widget;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(ServidorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements.firstWhere(
            (e) =>
                (e.nome.toUpperCase() == widget.initialSelection.toUpperCase()) || (e.host == widget.initialSelection),
            orElse: () => elements[0]);
      } else {
        selectedItem = elements[0];
      }
      _onInit(selectedItem);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
          (e) => (e.nome.toUpperCase() == widget.initialSelection.toUpperCase()) || (e.host == widget.initialSelection),
          orElse: () => elements[0]);
    } else {
      selectedItem = elements[0];
    }
  }

  void showPickerDialog() {
    showDialog(
      barrierColor: widget.barrierColor ?? Colors.grey.withOpacity(0.5),
      // backgroundColor: widget.backgroundColor ?? Colors.transparent,
      context: context,
      builder: (context) => Center(
        child: Container(
          constraints: BoxConstraints(maxHeight: 500, maxWidth: 400),
          child: Dialog(
            child: SelectionDialog(
              elements,
              emptySearchBuilder: widget.emptySearchBuilder,
              searchDecoration: widget.searchDecoration,
              searchStyle: widget.searchStyle,
              textStyle: widget.dialogTextStyle,
              boxDecoration: widget.boxDecoration,
              size: widget.dialogSize,
              backgroundColor: widget.dialogBackgroundColor,
              barrierColor: widget.barrierColor,
              hideSearch: widget.hideSearch,
              closeIcon: widget.closeIcon,
            ),
          ),
        ),
      ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });

        _publishSelection(e);
      }
    });
  }

  void _publishSelection(Servidor e) {
    if (widget.onChanged != null) {
      widget.onChanged(e);
    }
  }

  void _onInit(Servidor e) {
    if (widget.onInit != null) {
      widget.onInit(e);
    }
  }
}
