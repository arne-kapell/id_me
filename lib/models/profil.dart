import 'dart:io';

import 'package:flutter/material.dart';
import 'package:id_me/models/data.dart';
import 'package:provider/provider.dart';
import 'package:save_image_to_prefs/utility/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profil extends ChangeNotifier {
  String id;
  bool isOwn;
  Profil(this.isOwn,
      {this.id,
      this.name,
      this.image,
      this.facebook,
      this.instagram,
      this.reddit,
      this.snapchat,
      this.soundcloud,
      this.spotify,
      this.twitch,
      this.twitter,
      this.wattpad,
      this.whatsapp,
      this.youtube}) {
    _initOwn();
  }
  void _initOwn() async {
    if (this.isOwn) {
      SharedPreferences p = await SharedPreferences.getInstance();
      this.fromString(p.getString('own') ?? '');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String imageKeyValue = prefs.getString(IMAGE_KEY);
      if (imageKeyValue != null) {
        final imageString = await ImageSharedPrefs.loadImageFromPrefs();
        image = ImageSharedPrefs.imageFrom64BaseString(imageString);
      }
      notifyListeners();
    }
  }

  String name;
  Image image;

  Future<void> setImage(File file) async {
    this.image = Image.file(file);
    if (file != null) {
      await ImageSharedPrefs.saveImageToPrefs(
        ImageSharedPrefs.base64String(file.readAsBytesSync()));
    }
    notifyListeners();
  }

  /// {username} https://www.facebook.com/{username}
  String facebook;
  String get facebookLink => "https://www.facebook.com/$facebook";

  /// @{username} https://www.instagram.com/{username}/
  String instagram;
  String get instagramLink => "https://www.instagram.com/$instagram/";

  /// u/{username} https://www.reddit.com/user/{username}
  String reddit;
  String get redditLink => "https://www.reddit.com/user/$reddit";

  /// {username} https://www.snapchat.com/add/{username}/
  String snapchat;
  String get snapchatLink => "https://www.snapchat.com/add/$snapchat/";

  /// {username} https://soundcloud.com/{username}
  String soundcloud;
  String get soundcloudLink => "https://soundcloud.com/$soundcloud";

  /// {username} https://open.spotify.com/user/{username}
  String spotify;
  String get spotifyLink => "https://open.spotify.com/user/$spotify";

  /// {username} https://www.twitch.tv/{username}
  String twitch;
  String get twitchLink => "https://www.twitch.tv/$twitch";

  /// @{username} https://twitter.com/{username}
  String twitter;
  String get twitterLink => "https://twitter.com/$twitter";

  /// @{username} https://www.wattpad.com/user/{username}
  String wattpad;
  String get wattpadLink => "https://www.wattpad.com/user/$wattpad";

  /// phone number in international format: 0049 160 ...
  String whatsapp;
  String get whatsappLink => "https://wa.me/$whatsapp";

  /// {channel-id} https://www.youtube.com/channel/{channel-id}
  String youtube;
  String get youtubeLink => "https://www.youtube.com/channel/$youtube";

  /// all possible items as list
  List<String> get listAll => [
        'facebook',
        'instagram',
        'reddit',
        'snapchat',
        'soundcloud',
        'spotify',
        'twitch',
        'twitter',
        'wattpad',
        'whatsapp',
        'youtube'
      ];
  Map<String, String> get listUnset => _getMap(false);

  /// items as map (only the used ones)
  Map<String, String> get asMap => _getMap(true);

  _getMap(bool isSet) {
    Map<String, String> tmp = {
      'facebook': facebook,
      'instagram': instagram,
      'reddit': reddit,
      'snapchat': snapchat,
      'soundcloud': soundcloud,
      'spotify': spotify,
      'twitch': twitch,
      'twitter': twitter,
      'wattpad': wattpad,
      'whatsapp': whatsapp,
      'youtube': youtube,
    };
    tmp.removeWhere((key, value) => (isSet) ? value == null : value != null);
    return tmp;
  }

  Map<String, String> get linkMap => _getLinkMap();

  _getLinkMap() {
    Map<String, String> tmp = {
      'facebook': facebookLink,
      'instagram': instagramLink,
      'reddit': redditLink,
      'snapchat': snapchatLink,
      'soundcloud': soundcloudLink,
      'spotify': spotifyLink,
      'twitch': twitchLink,
      'twitter': twitterLink,
      'wattpad': wattpadLink,
      'whatsapp': whatsappLink,
      'youtube': youtubeLink,
    };
    Map<String, String> unset = _getMap(false);
    for (var i = 0; i < unset.length; i++) {
      tmp.removeWhere((key, value) => key == unset.keys.elementAt(i));
    }
    return tmp;
  }

  /// returns String for code generation
  String getString(
      {bool iinstagram = true,
      bool itwitter = true,
      bool isnapchat = true,
      bool ifacebook = true,
      bool iwhatsapp = true,
      bool ireddit = true,
      bool itwitch = true,
      bool iwattpad = true,
      bool isoundcloud = true,
      bool ispotify = true,
      bool iyoutube = true}) {
    if (name == null &&
        instagram == null &&
        twitter == null &&
        snapchat == null &&
        facebook == null &&
        whatsapp == null &&
        reddit == null &&
        twitch == null &&
        wattpad == null &&
        soundcloud == null &&
        spotify == null &&
        youtube == null) {
      return null;
    }
    print("getString");
    print(isnapchat);
    String data = this.id;
    if (name != null) {
      data = data + '?' + name.replaceAll(' ', '_');
    }
    if (instagram != null && iinstagram) {
      data = data + '?instagram=' + this.instagram;
    }
    if (twitter != null && itwitter) {
      data = data + '?twitter=' + this.twitter;
    }
    if (snapchat != null && isnapchat) {
      data = data + '?snapchat=' + this.snapchat;
    }
    if (facebook != null && ifacebook) {
      data = data + '?facebook=' + this.facebook;
    }
    if (whatsapp != null && iwhatsapp) {
      data = data + '?whatsapp=' + this.whatsapp;
    }
    if (reddit != null && ireddit) {
      data = data + '?reddit=' + this.reddit;
    }
    if (twitch != null && itwitch) {
      data = data + '?twitch=' + this.twitch;
    }
    if (wattpad != null && iwattpad) {
      data = data + '?wattpad=' + this.wattpad;
    }
    if (soundcloud != null && isoundcloud) {
      data = data + '?soundcloud=' + this.soundcloud;
    }
    if (spotify != null && ispotify) {
      data = data + '?spotify=' + this.spotify;
    }
    if (youtube != null && iyoutube) {
      data = data + '?youtube=' + this.youtube;
    }
    if (data.isNotEmpty) {
      print(data);
      return data;
    } else {
      return null;
    }
  }

  /// clear item
  clear(String item) {
    switch (item) {
      case 'instagram':
        this.instagram = null;
        break;
      case 'twitter':
        this.twitter = null;
        break;
      case 'snapchat':
        this.snapchat = null;
        break;
      case 'facebook':
        this.facebook = null;
        break;
      case 'whatsapp':
        this.whatsapp = null;
        break;
      case 'reddit':
        this.reddit = null;
        break;
      case 'twitch':
        this.twitch = null;
        break;
      case 'wattpad':
        this.wattpad = null;
        break;
      case 'soundcloud':
        this.soundcloud = null;
        break;
      case 'spotify':
        this.spotify = null;
        break;
      case 'youtube':
        this.youtube = null;
        break;
    }
    notifyListeners();
  }

  /// add item
  add(String item, String value, BuildContext context) {
    switch (item) {
      case 'instagram':
        this.instagram = value;
        break;
      case 'twitter':
        this.twitter = value;
        break;
      case 'snapchat':
        this.snapchat = value;
        break;
      case 'facebook':
        this.facebook = value;
        break;
      case 'whatsapp':
        this.whatsapp = value;
        break;
      case 'reddit':
        this.reddit = value;
        break;
      case 'twitch':
        this.twitch = value;
        break;
      case 'wattpad':
        this.wattpad = value;
        break;
      case 'soundcloud':
        this.soundcloud = value;
        break;
      case 'spotify':
        this.spotify = value;
        break;
      case 'youtube':
        this.youtube = value;
        break;
    }
    Provider.of<Data>(context).setOwn(this);
    notifyListeners();
  }

  updateName(String name, BuildContext context) {
    this.name = name;
    Provider.of<Data>(context, listen: false).setOwn(this);
    notifyListeners();
  }

  /// returns Profil or null if data is empty String or has no id
  fromString(String data, {bool notify = true, bool returnProfile = false}) {
    List<String> splitted = data.split('?');
    if (data.isEmpty) {
      return null;
    }
    if (int.tryParse(splitted[0]) != null) {
      this.id = splitted[0];
    } else {
      return null;
    }
    if (splitted[1].isNotEmpty) {
      this.name = splitted[1].replaceAll('_', ' ');
    }
    for (int i = 2; i < (splitted.length); i++) {
      String current = splitted[i];
      if (current.contains('=')) {
        String type = current.split('=')[0];
        String value = current.split('=')[1];
        switch (type) {
          case 'instagram':
            this.instagram = value;
            break;
          case 'twitter':
            this.twitter = value;
            break;
          case 'snapchat':
            this.snapchat = value;
            break;
          case 'facebook':
            this.facebook = value;
            break;
          case 'whatsapp':
            this.whatsapp = value;
            break;
          case 'reddit':
            this.reddit = value;
            break;
          case 'twitch':
            this.twitch = value;
            break;
          case 'wattpad':
            this.wattpad = value;
            break;
          case 'soundcloud':
            this.soundcloud = value;
            break;
          case 'spotify':
            this.spotify = value;
            break;
          case 'youtube':
            this.youtube = value;
            break;
        }
      }
    }
    if (returnProfile) {
      return this;
    }
    if (notify) {
      notifyListeners();
    }
  }
}
