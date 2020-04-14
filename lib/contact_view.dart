import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:id_me/models/data.dart';
import 'package:id_me/models/functions.dart';
import 'package:id_me/models/profil.dart';

class ContactView extends StatelessWidget {
  final Profil profil;
  final Data data;
  const ContactView({Key key, this.profil, this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(profil.name,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 25)),
        actions: <Widget>[
          IconButton(
              icon: Icon(AntDesign.delete),
              onPressed: () async {
                var dialog = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: AutoSizeText("'${profil.name}' löschen?"),
                          actions: <Widget>[
                            FlatButton(
                                child: Text('Ja'),
                                color: Colors.red[800],
                                onPressed: () =>
                                    Navigator.of(context).pop(true)),
                            FlatButton(
                                child: Text('Nein'),
                                color: Colors.green[600],
                                onPressed: () =>
                                    Navigator.of(context).pop(false))
                          ],
                        ));
                if (dialog) {
                  data.remove(profil);
                  Navigator.of(context).pop();
                }
              })
        ],
      ),
      body: ListView(
        children: <Widget>[
          Builder(
            builder: (context) {
              List<Widget> items = [];
              for (var i = 0; i < profil.asMap.length; i++) {
                items.add(Padding(
                  padding: const EdgeInsets.all(5),
                  child: Material(
                    elevation: 2,
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => launchURL(context, profil.linkMap.values.elementAt(i)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                                getPlatformIcon(profil.asMap.keys.elementAt(i)),
                                size: MediaQuery.of(context).size.width * 0.35),
                          ),
                        ),
                      )),
                ));
              }
              items.add(AutoSizeText('ID: ' + profil.id, style: TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic, color: Colors.white60)));
              return Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: items,
              );
            },
          ),
        ],
      ),
    );
  }
}
