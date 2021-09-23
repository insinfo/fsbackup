import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';
import 'package:fsbackup/constants.dart';
import 'package:fsbackup/providers/log_provider.dart';
import 'package:provider/provider.dart';

class LogViewWidget extends StatefulWidget {
  final ScrollController scrollController;

  const LogViewWidget({Key key, this.scrollController}) : super(key: key);
  @override
  _LogViewWidgetState createState() => _LogViewWidgetState();
}

class _LogViewWidgetState extends State<LogViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: ChangeNotifierProvider.value(
        value: locator<LogProvider>(),
        builder: (context, w) => Consumer<LogProvider>(builder: (ctx, data, child) {
          var list = data.getLines();
          return ListView.builder(
              controller: widget.scrollController,
              itemCount: list.length,
              itemBuilder: (ctx, idx) {
                return Text(list[idx]);
              });
        }),
      ),
    );
  }
}
