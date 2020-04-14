import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:id_me/models/functions.dart';
import 'package:id_me/models/profil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class ProfileDisplay extends StatefulWidget {
  @override
  _ProfileDisplayState createState() => _ProfileDisplayState();
}

class _ProfileDisplayState extends State<ProfileDisplay> {
  bool _processing = false;
  bool _selectSource = false;
  Timer _timer;
  bool _editName;
  TextEditingController _nameController = TextEditingController();
  FocusNode _nameFocus = FocusNode();

  _pickImage(ImageSource source) async {
    setState(() => _processing = true);
    final _image = await ImagePicker.pickImage(source: source);
    if (_image != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: _image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Zuschneiden',
              toolbarColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1,
              rectWidth: 1,
              rectHeight: 1,
              showCancelConfirmationDialog: true,
              resetAspectRatioEnabled: false,
              aspectRatioLockEnabled: true,
              doneButtonTitle: 'Fertig',
              cancelButtonTitle: 'Abbrechen'));
      if (croppedFile != null) {
        await Provider.of<Profil>(context, listen: false).setImage(croppedFile);
      }
    }
    setState(() => _processing = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Profil profil = Provider.of<Profil>(context);
    Image image = (profil.image != null)
        ? profil.image
        : Image.asset('img/user_blank.png');
    if (_editName == null) {
      _editName = (profil.name == null);
      if (_editName) {
        Timer(Duration(milliseconds: 500), () => _nameFocus.requestFocus());
      }
    }
    return Card(
      child: Column(
        children: <Widget>[
          Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Material(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).backgroundColor,
                  elevation: 5,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      if (!_selectSource) {
                        _timer = Timer(Duration(seconds: 5),
                            () => setState(() => _selectSource = false));
                      } else {
                        _timer.cancel();
                      }
                      setState(() => _selectSource = !_selectSource);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: CircleAvatar(
                          backgroundImage: image.image,
                          minRadius: MediaQuery.of(context).size.width * 0.2,
                          child: (_processing)
                              ? Center(child: CircularProgressIndicator())
                              : AnimatedCrossFade(
                                  crossFadeState: (_selectSource)
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: Duration(milliseconds: 500),
                                  firstChild: Center(
                                      child: Material(
                                          color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Row(
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(Feather.image),
                                                onPressed: () => _pickImage(
                                                    ImageSource.gallery),
                                              ),
                                              Container(
                                                  width: 2,
                                                  height: 40,
                                                  color: Theme.of(context)
                                                      .backgroundColor),
                                              IconButton(
                                                icon: Icon(Feather.camera),
                                                onPressed: () => _pickImage(
                                                    ImageSource.camera),
                                              )
                                            ],
                                          ))),
                                  firstCurve: Curves.easeIn,
                                  secondChild: Container(),
                                )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: AnimatedCrossFade(
                  crossFadeState: (_editName)
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 500),
                  firstChild: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      maxLength: 20,
                      decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: profil.name,
                          labelStyle: TextStyle(fontSize: 20),
                          counterStyle:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: MediaQuery.of(context).size.width * 0.08),
                      onChanged: (text) {
                        if (text.trim() != '') {
                          profil.updateName(text.trim(), context);
                        } else {
                          // profil.name = null;
                        }
                      },
                      onEditingComplete: () {
                        _nameFocus.unfocus();
                        setState(() => _editName = false);
                      },
                    ),
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GestureDetector(
                        onTap: () {
                          setState(() => _editName = true);
                          _nameFocus.requestFocus();
                        },
                        child: AutoSizeText(profil.name ?? '**********',
                            maxLines: 1,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.09))),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                List<Widget> children = [];
                // children.add(Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   child: Divider(color: Colors.white),
                // ));
                for (var i = 0; i < profil.asMap.length; i++) {
                  String name = profil.asMap.keys.elementAt(i);
                  String username = profil.asMap.values.elementAt(i);
                  children.add(Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: 5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onLongPress: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Icon(getPlatformIcon(name), size: MediaQuery.of(context).size.width*0.2),
                                content: Center(
                                  heightFactor: 1,
                                    child: RaisedButton(
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Icon(MaterialCommunityIcons.test_tube, size: 28),
                                            ),
                                            AutoSizeText('Weiterleitung testen', style: Theme.of(context).textTheme.bodyText2, minFontSize: 18),
                                          ],
                                        ),
                                        color: Theme.of(context).primaryColor,
                                        padding: EdgeInsets.all(10),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          launchURL(context, profil.linkMap[name]);
                                        }),
                                  )
                              )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(getPlatformIcon(name), size: 35),
                          ),
                          Expanded(
                              child: AutoSizeText(
                                  getUsernameString(username, name))),
                          IconButton(
                            icon: Icon(MaterialIcons.delete),
                            onPressed: () => profil.clear(name),
                          )
                        ],
                      ),
                    ),
                  ));
                }
                children.add(Center(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, 5, 0, 20),
                  child: CupertinoButton.filled(
                    child: Icon(MaterialIcons.add),
                    onPressed: () {
                      var bottomSheet = Scaffold.of(context).showBottomSheet(
                          (context) => BottomSheetAdd(profil: profil),
                          elevation: 5);
                      bottomSheet.closed.whenComplete(() => setState(() {}));
                    },
                  ),
                )));
                return ListView(children: children);
              },
            ),
          ),
          Container(height: kBottomNavigationBarHeight*0.8)
        ],
      ),
    );
  }
}

class BottomSheetAdd extends StatefulWidget {
  const BottomSheetAdd({
    Key key,
    @required this.profil,
  }) : super(key: key);

  final Profil profil;

  @override
  _BottomSheetAddState createState() => _BottomSheetAddState();
}

class _BottomSheetAddState extends State<BottomSheetAdd> {
  String _value;
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> values = Provider.of<Profil>(context).listUnset.keys.toList();
    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.2,
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            Material(
              color: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Builder(builder: (context) {
                    List<DropdownMenuItem> items = [];
                    for (var i = 0; i < values.length; i++) {
                      items.add(DropdownMenuItem(
                          value: values[i],
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(values[i].substring(0, 1).toUpperCase() +
                                  values[i].substring(1)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(getPlatformIcon(values[i])),
                              )
                            ],
                          )));
                    }
                    return SearchableDropdown.single(
                      items: items,
                      value: _value,
                      hint: "Auswählen...",
                      searchHint: null,
                      icon: Icon(Feather.chevron_down),
                      displayClearIcon: false,
                      onChanged: (value) {
                        setState(() {
                          _value = value;
                        });
                      },
                      dialogBox: false,
                      isExpanded: true,
                      menuConstraints:
                          BoxConstraints.tight(Size.fromHeight(350)),
                    );
                  }),
                  (_value != null)
                      ? Center(
                          child: Icon(getPlatformIcon(_value),
                              size: MediaQuery.of(context).size.width * 0.4))
                      : Container(),
                  (_value != null)
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                AutoSizeText(getUsernameString('', _value),
                                    minFontSize: 30),
                                Expanded(
                                    child: TextField(
                                        controller: _controller,
                                        decoration: InputDecoration(),
                                        style: TextStyle(fontSize: 30),
                                        textAlign: TextAlign.center)),
                                IconButton(
                                    icon: Icon(AntDesign.checkcircleo),
                                    iconSize: 30,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Provider.of<Profil>(context,
                                              listen: false)
                                          .add(_value, _controller.text.trim(),
                                              context);
                                    })
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ));
  }
}
