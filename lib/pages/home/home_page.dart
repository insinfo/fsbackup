import 'package:flutter/material.dart';
import 'package:fsbackup/blocs/server_bloc.dart';
import 'package:fsbackup/models/server.dart';
import 'package:fsbackup/pages/help/help_page.dart';
import 'package:fsbackup/pages/server/server_page.dart';
import 'package:fsbackup/pages/process/process_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    serverBloc.updateServers();
  }

  @override
  void dispose() {
    serverBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('FSBackup'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ajuda',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Server>>(
        stream: serverBloc.getServers,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return Center(
              child: Text(
                'Carregando',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[200] : Colors.grey[700]),
                textScaleFactor: 1.5,
              ),
            );
          else if (snapshot.data.length == 0)
            return Center(
              child: Text(
                'Sem Servidores',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
                textScaleFactor: 1.5,
              ),
            );
          else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_left,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[200] : Colors.grey[700],
                      ),
                      Text(
                        'Deslize', // Swipe
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark ? Colors.grey[200] : Colors.grey[700]),
                      ),
                      Icon(
                        Icons.arrow_right,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[200] : Colors.grey[700],
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 0,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: new Key(UniqueKey().toString()),
                        confirmDismiss: (DismissDirection dir) async {
                          if (dir == DismissDirection.startToEnd) {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServerPage(existingServer: snapshot.data[index]),
                                ));
                            serverBloc.updateServers();
                          } else {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ProcessPage(server: snapshot.data[index], scaffoldKey: _scaffoldKey);
                            }));
                          }
                          return false;
                        },
                        child: ListTile(title: Text('${snapshot.data[index].name}')),
                        background: Container(
                          // ignore: deprecated_member_use
                          color: Theme.of(context).accentColor,
                          padding: EdgeInsets.fromLTRB(20, 0, 00, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Editar',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.fromLTRB(00, 0, 20, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Upload',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServerPage(existingServer: null),
              ));
          serverBloc.updateServers();
        },
        tooltip: 'Add Server',
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
