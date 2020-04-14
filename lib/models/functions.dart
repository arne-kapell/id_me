import 'package:flutter/material.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexColor(String rgb) {
  return new Color(int.parse(rgb.substring(1, 7), radix: 16) + 0xFF000000);
}

launchURL(BuildContext context, String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Fehler beim Öffnen von $url", style: TextStyle(color: Colors.red))));
  }
}

getPlatformIcon(String platform) {
  switch (platform) {
      case 'facebook':
        // return Entypo.facebook;
        return BrandIcons.facebook;
        break;
      case 'instagram':
        // return Feather.instagram;
        return BrandIcons.instagram;
        break;
      case 'reddit':
        // return FontAwesome.reddit_square;
        return BrandIcons.reddit;
        break;
      case 'snapchat':
        // return FontAwesome.snapchat_square;
        return BrandIcons.snapchat;
        break;
      case 'soundcloud':
        // return MaterialCommunityIcons.soundcloud;
        return BrandIcons.soundcloud;
        break;
      case 'spotify':
        // return Fontisto.spotify;
        return BrandIcons.spotify;
        break;
      case 'twitch':
        // return Fontisto.twitch;
        return BrandIcons.twitch;
        break;
      case 'twitter':
        // return FontAwesome.twitter_square;
        return BrandIcons.twitter;
        break;
      case 'wattpad':
        return BrandIcons.wattpad;
        break;
      case 'whatsapp':
        // return FontAwesome5Brands.whatsapp_square;
        return BrandIcons.whatsapp;
        break;
      case 'youtube':
        // return FontAwesome.youtube_play;
        return BrandIcons.youtube;
        break;
      default:
      return AntDesign.questioncircleo;
    }
}

getUsernameString(String username, String platform) {
  String pre = '';
  String post = '';
  switch (platform) {
      case 'instagram':
        pre = '@';
        break;
      case 'reddit':
        pre = 'u/';
        break;
      case 'twitter':
        pre = '@';
        break;
      case 'wattpad':
        pre = '@';
        break;
      default:
    }
  return pre+username+post;
}