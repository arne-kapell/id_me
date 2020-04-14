import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:id_me/contact_view.dart';
import 'package:id_me/models/data.dart';
import 'package:id_me/models/functions.dart';
import 'package:id_me/models/profil.dart';
import 'package:provider/provider.dart';

class ContactsDisplay extends StatefulWidget {
  @override
  _ContactsDisplayState createState() => _ContactsDisplayState();
}

class _ContactsDisplayState extends State<ContactsDisplay> {
  Data data;
  List<Profil> _contacts;
  TextEditingController _searchBox;
  FocusNode _searchFocus;
  bool _search = false;

  @override
  void initState() {
    _searchBox = TextEditingController();
    _searchFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (_searchFocus.hasFocus) {
      _searchFocus.unfocus();
    }
    _searchBox.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      data = Provider.of<Data>(context);
    }
    _contacts = data.searchBook;
    return Stack(
      children: <Widget>[
        Card(
            child: (data.book.length > 0)
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AnimatedCrossFade(
                        crossFadeState: (_search)
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 800),
                        firstChild: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(AntDesign.close),
                                  iconSize: 30,
                                  onPressed: () {
                                    if (_searchFocus.hasFocus) {
                                      _searchFocus.unfocus();
                                    }
                                    _searchBox.text = '';
                                    setState(() => _search = false);
                                  }),
                              Expanded(
                                child: TextField(
                                  controller: _searchBox,
                                  focusNode: _searchFocus,
                                  onChanged: (v) {
                                    if (v.trim() == '') {
                                      data.search(null);
                                    } else {
                                      data.search(v);
                                    }
                                  },
                                  onEditingComplete: () {
                                    _searchFocus.unfocus();
                                  },
                                  decoration: InputDecoration(
                                      hintText: 'Kontakte durchsuchen...',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      isDense: true,
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Material(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            elevation: 2,
                                            color:
                                                Theme.of(context).primaryColor,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Container(
                                                  child: Icon(Icons.search,
                                                      color: Colors.white),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15),
                                              onTap: () => (_searchFocus
                                                      .hasFocus)
                                                  ? _searchFocus.unfocus()
                                                  : _searchFocus.requestFocus(),
                                            )),
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                        secondChild: Container(),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, int i) {
                            return ContactItem(_contacts[i], data);
                          },
                        ),
                      ),
                      Container(height: kBottomNavigationBarHeight * 0.8)
                    ],
                  )
                : Opacity(
                    opacity: 0.8,
                    child: Wrap(
                      direction: Axis.vertical,
                      runAlignment: WrapAlignment.center,
                      alignment: WrapAlignment.spaceEvenly,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: <Widget>[
                        Icon(FontAwesome5Solid.ghost,
                            size: MediaQuery.of(context).size.width * 0.4,
                            color: Theme.of(context).backgroundColor),
                        AutoSizeText('... ziemlich leer hier ...',
                            minFontSize:
                                (MediaQuery.of(context).size.width * 0.08)
                                    .roundToDouble(),
                            style: TextStyle(
                                color: Theme.of(context).backgroundColor)),
                        Icon(Feather.chevrons_up)
                      ],
                    ),
                  )),
        Positioned(
            bottom: 10 + kBottomNavigationBarHeight,
            left: 10,
            child: AnimatedCrossFade(
              crossFadeState: (!_search) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 500),
              firstChild: Material(
                    borderRadius: BorderRadius.circular(50),
                    elevation: 2,
                    color: Theme.of(context).primaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                          child: Icon(Icons.search, color: Colors.white),
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.width * 0.15),
                      onTap: () {
                        setState(() => _search = true);
                        Timer(Duration(milliseconds: 500),
                            () => _searchFocus.requestFocus());
                      },
                    )),
                    secondChild: Container(width: 0, height: 0),
            ))
      ],
    );
  }
}

class ContactItem extends StatelessWidget {
  final Profil profil;
  final Data data;
  ContactItem(this.profil, this.data);

  @override
  Widget build(BuildContext context) {
    print(profil);
    return Dismissible(
      key: ValueKey(profil.id),
      onDismissed: (direction) => data.remove(profil),
      confirmDismiss: (direction) => showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: AutoSizeText("'${profil.name}' löschen?"),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ja'),
                      color: Colors.red[800],
                      onPressed: () => Navigator.of(context).pop(true)),
                  FlatButton(
                      child: Text('Nein'),
                      color: Colors.green[600],
                      onPressed: () => Navigator.of(context).pop(false))
                ],
              )),
      background: Opacity(
          opacity: 0.7,
          child: Card(
              color: Colors.red[800],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: <Widget>[
                      Icon(AntDesign.delete),
                      Icon(AntDesign.delete)
                    ]),
              ))),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ContactView(profil: profil, data: data))),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: AutoSizeText(profil.name, style: Theme.of(context).textTheme.headline5, maxLines: 1),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Builder(
                    builder: (context) {
                      List<Widget> icons = [];
                      for (var i = 0; i < profil.asMap.length; i++) {
                        icons.add(Icon(
                          getPlatformIcon(profil.asMap.keys.elementAt(i)),
                          size: MediaQuery.of(context).size.width * 0.07,
                        ));
                      }
                      return Wrap(
                          children: icons,
                          spacing: 5,
                          runSpacing: 5,
                          alignment: WrapAlignment.spaceEvenly);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
