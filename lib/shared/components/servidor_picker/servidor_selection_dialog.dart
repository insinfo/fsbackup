import 'package:flutter/material.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/models/servidor.dart';

/// selection dialog used for selection of the item
class SelectionDialog extends StatefulWidget {
  final List<Servidor> elements;

  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final TextStyle textStyle;
  final BoxDecoration boxDecoration;
  final WidgetBuilder emptySearchBuilder;

  final Size size;
  final bool hideSearch;
  final Icon closeIcon;

  /// Background color of SelectionDialog
  final Color backgroundColor;

  /// Boxshaow color of SelectionDialog that matches CountryCodePicker barrier color
  final Color barrierColor;

  SelectionDialog(
    this.elements, {
    Key key,
    this.emptySearchBuilder,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.textStyle,
    this.boxDecoration,
    this.size,
    this.backgroundColor,
    this.barrierColor,
    this.hideSearch = false,
    this.closeIcon,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  List<Servidor> filteredElements;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          //clipBehavior: Clip.hardEdge,
          width: widget.size?.width ?? MediaQuery.of(context).size.width,
          height: widget.size?.height ?? MediaQuery.of(context).size.height * 0.85,
          decoration: widget.boxDecoration ??
              BoxDecoration(
                color: widget.backgroundColor ?? secondaryColor,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: const EdgeInsets.all(0),
                iconSize: 20,
                icon: widget.closeIcon,
                onPressed: () => Navigator.pop(context),
              ),
              if (!widget.hideSearch)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    style: widget.searchStyle,
                    decoration: widget.searchDecoration,
                    onChanged: _filterElements,
                  ),
                ),
              Expanded(
                child: ListView(
                  children: [
                    if (filteredElements.isEmpty)
                      _buildEmptySearchWidget(context)
                    else
                      ...filteredElements.map(
                        (e) => SimpleDialogOption(
                          child: _buildOption(e),
                          onPressed: () {
                            _selectItem(e);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildOption(Servidor e) {
    return Container(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              e.nome,
              overflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder(context);
    }

    return Center(
      child: Text('Não encontrado'),
    );
  }

  @override
  void initState() {
    filteredElements = [...widget.elements];
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toLowerCase();
    setState(() {
      filteredElements =
          widget.elements.where((e) => e.nome.toLowerCase().contains(s) || e.host.toLowerCase().contains(s)).toList();
    });
  }

  void _selectItem(Servidor e) {
    Navigator.pop(context, e);
  }
}
