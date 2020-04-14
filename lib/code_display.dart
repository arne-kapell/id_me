import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:id_me/models/data.dart';
import 'package:id_me/models/functions.dart';
import 'package:id_me/models/profil.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CodeDisplay extends StatefulWidget {
  @override
  _CodeDisplayState createState() => _CodeDisplayState();
}

class _CodeDisplayState extends State<CodeDisplay> {
  bool _hideCode = false;
  Profil profil;
  Map<String, bool> settings;

  @override
  void initState() {
    // settings = <String, bool>{};
    super.initState();
  }

  _refreshCode() {
    setState(() => this._hideCode = true);
    Timer(Duration(milliseconds: 100), () => setState(() => this._hideCode = false));
  }

  // _showNameDialog(BuildContext context) async {
  //   TextEditingController _name = TextEditingController();
  //   var dialog = showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: AutoSizeText('Hi',
  //               minFontSize: 25, style: TextStyle(fontWeight: FontWeight.bold)),
  //           content: Container(
  //             height: MediaQuery.of(context).size.height * 0.5,
  //             child: ListView(
  //               children: <Widget>[
  //                 AutoSizeText('Bitte gib deinen Namen (oder Spitznamen) ein:',
  //                     textAlign: TextAlign.justify),
  //                 TextField(
  //                   textAlign: TextAlign.center,
  //                   controller: _name,
  //                 ),
  //                 IconButton(
  //                     icon: Icon(Feather.check_circle),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     })
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //   dialog.whenComplete(() {
  //     if (_name.text.trim() != '') {
  //       Provider.of<Profil>(context).name = _name.text.trim();
  //       setState(() {});
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    profil = Provider.of<Profil>(context);
    settings = Provider.of<Data>(context).displaySettings ?? <String, bool>{};
    for (var item in profil.listAll) {
      settings.putIfAbsent(item, () => true);
    }
    print('settings: ' + settings['snapchat'].toString());
    Provider.of<Data>(context, listen: false).displaySettings = settings;
    String _currentLink = Provider.of<Profil>(context, listen: true).getString(
        ifacebook: settings['facebook'],
        iinstagram: settings['instagram'],
        ireddit: settings['reddit'],
        isnapchat: settings['snapchat'],
        isoundcloud: settings['soundcloud'],
        ispotify: settings['spotify'],
        itwitch: settings['twitch'],
        itwitter: settings['twitter'],
        iwattpad: settings['wattpad'],
        iwhatsapp: settings['whatsapp'],
        iyoutube: settings['youtube']);
    return Card(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          child: Material(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(5),
              child: InkWell(
                  splashColor: Theme.of(context).primaryColor,
                  onLongPress: () => setState(() => _hideCode = !_hideCode),
                  borderRadius: BorderRadius.circular(5),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: AnimatedCrossFade(
                      crossFadeState: (_hideCode)
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                      firstCurve: Curves.ease,
                      secondCurve: Curves.ease,
                      firstChild: SizedBox.fromSize(
                          child: Icon(
                            Icons.visibility_off,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          size: Size.square(200)),
                      secondChild: (_currentLink != null)
                          ? Padding(
                              padding: const EdgeInsets.all(5),
                              child: PrettyQr(
                                  size: MediaQuery.of(context).size.width * 0.7,
                                  // image: (profil.image != null)
                                  //     ? profil.image.image
                                  //     : Image.asset('img/user_blank.png').image,
                                  typeNumber: 10,
                                  roundEdges: true,
                                  data: "idme://" + _currentLink), // --> deeplink
                            )
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox.fromSize(
                                  child: Icon(
                                    AntDesign.questioncircleo,
                                    size: 90,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  size: Size.square(200))),
                    ),
                  ))),
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
              Builder(
                builder: (context) {
                  List<Widget> children = [];
                  for (var i = 0; i < profil.asMap.length; i++) {
                    String name = profil.asMap.keys.elementAt(i);
                    children.add(PlatformCard(
                        name,
                        settings[name],
                        (bool n) {
                          this.setState(() => settings.update(name, (value) => n));
                          this._refreshCode();
                        }));
                  }
                  if (children.length == 0) {
                    children.add(Icon(Entypo.dots_three_horizontal,
                        size: MediaQuery.of(context).size.width * 0.3));
                  }
                  return Wrap(
                    children: children,
                    alignment: WrapAlignment.spaceEvenly,
                  );
                },
              ),
            ],
          ),
        ),
        Container(height: kBottomNavigationBarHeight*0.8)
      ],
    ));
  }
}

class PlatformCard extends StatelessWidget {
  final String name;
  final bool value;
  final Function(bool n) onChanged;
  PlatformCard(this.name, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    IconData icon = getPlatformIcon(name);
    return Card(
        color: Theme.of(context).primaryColor,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              Icon(icon, size: 60),
              Switch.adaptive(value: value, onChanged: onChanged)
            ],
          ),
        ));
  }
}
