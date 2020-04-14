import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:id_me/models/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data extends ChangeNotifier {
  SharedPreferences p;
  String ownId;
  List<String> _bookIds = [];
  List<Profil> _book = [];
  List<Profil> get book => _book;
  List<Profil> _searchBook = [];
  List<Profil> get searchBook => _searchBook;
  Map<String, bool> displaySettings;
  Data() {
    _init();
  }
  void _init() async {
    p = await SharedPreferences.getInstance();
    this.ownId = p.getInt('OWN_ID').toString();
    print("ownID: $ownId");
    _bookIds = p.getStringList('book') ?? [];
    for (var i = 0; i < (_bookIds ?? List()).length; i++) {
      try {
        _book.add(Profil(false, id: _bookIds[i]).fromString(
            p.getString(_bookIds[i]),
            notify: false,
            returnProfile: true));
      } catch (e) {
        print(e);
      }
    }
    _searchBook.addAll(_book);
    _searchBook.sort((a, b) => a.name.compareTo(b.name));
  }

  void add(Profil profil) async {
    if (!_bookIds.contains(profil.id)) {
      _bookIds.add(profil.id);
      _book.add(profil);
      print('set new');
    } else {
      _book
          .singleWhere((element) => element.id == profil.id)
          .fromString(profil.getString());
      print('update');
    }
    _searchBook.clear();
    _searchBook.addAll(_book);
    _searchBook.sort((a, b) => a.name.compareTo(b.name));
    await _save();
    notifyListeners();
  }

  remove(Profil profil) {
    _bookIds.removeWhere((element) => element == profil.id);
    _book.removeWhere((element) => element == profil);
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await p.setStringList('book', _bookIds);
    for (var i = 0; i < _bookIds.length; i++) {
      try {
        await p.setString(
            _bookIds[i],
            _book
                .firstWhere((element) => element.id == _bookIds[i])
                .getString());
      } catch (e) {
        print(e);
      }
    }
  }

  void setOwn(Profil own) async {
    await p.setString('own', own.getString());
  }

  /// searches for contacts and resets searchList for input 'null'
  search(String input, {bool returnSearch = false}) {
    _searchBook.clear();
    _searchBook.addAll(_book);
    _searchBook.sort((a, b) => a.name.compareTo(b.name));
    if (input != null) {
      _searchBook.retainWhere((element) => element.name
        .toLowerCase()
        .contains(new RegExp(r'' + input.toLowerCase().trim() + '')));
    }
    if (returnSearch) {
      return searchBook;
    } else {
      notifyListeners();
    }
  }
}
