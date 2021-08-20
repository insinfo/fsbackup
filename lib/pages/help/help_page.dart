import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tuma  |  Help'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema de backup de servidores Linux Debian',
                  textScaleFactor: 2,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Teste pagina de ajuda',
                )
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(
                onTap: () {
                  launch('https://jubarte.riodasostras.rj.gov.br/');
                },
                child: Text(
                  'jubarte',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
