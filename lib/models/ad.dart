import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class BannerFallback extends StatelessWidget {
  final BuildContext context;
  final Ad _ad;
  final bool content;
  BannerFallback(this.context, this._ad, {this.content = true});

  @override
  Widget build(BuildContext context) {
    print(_ad._banner);
    return Container(
        height: _ad.bannerHeight,
        // child: (content)
        //     ? Consumer(builder: (context, pref, _) {
        //         return Card(
          child: Card(
                    elevation: 0,
                    color: Colors.blue[200],
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Wrap(
                        spacing: MediaQuery.of(context).size.width*0.1,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                      Icon(MaterialCommunityIcons.google_adwords,
                          color: Colors.white,
                          size: 20),
                      Icon(MaterialCommunityIcons.google_adwords,
                          color: Colors.white),
                      Icon(MaterialCommunityIcons.google_adwords,
                          color: Colors.white,
                          size: 20),
                        ],
                      ),
                    )));
              // })
            // : Container());
  }
}

class Ad {
  BuildContext context;
  Ad(this.context);
  BannerAd _banner;
  bool get hasBanner => (_banner != null);
  double get bannerHeight => (hasBanner) ? _getBannerHeight() : 0;
  InterstitialAd _interstitial;

  double _getBannerHeight() {
    double screen = MediaQuery.of(context).size.height;
    if (screen <= 400) {
      return 32;
    } else if (screen <= 720) {
      return 50;
    } else {
      return 90;
    }
  }

  BannerAd _createBanner() {
    return BannerAd(
      adUnitId: "ca-app-pub-4885568839996243/2048915124",
      // adUnitId: BannerAd.testAdUnitId,
      size: AdSize.smartBanner,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  InterstitialAd _createInterstitial() {
    return InterstitialAd(
      adUnitId: "ca-app-pub-4885568839996243/4483506774",
      // adUnitId: InterstitialAd.testAdUnitId,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  void banner({bool realBottom = false, bool top = false}) {
    assert(!realBottom || !top);
    double aOf;
    // if (Provider.of(context).showAds) {
        _banner ??= _createBanner();
      if (top) {
        aOf = MediaQuery.of(context).padding.top;
      } else if (!realBottom) {
        aOf = (MediaQuery.of(context).size.height * 0.06) +
            kBottomNavigationBarHeight;
      } else {
        aOf = 0;
      }
      _banner
        ..load().catchError((e) => print("bannerError: $e"))
        ..show(
            anchorType: (top) ? AnchorType.top : AnchorType.bottom,
            anchorOffset: aOf);
            // .then((value) => Provider.of(context).bannerState(value));
    // }
  }

  interstitial() {
      _interstitial ??= _createInterstitial();
    _interstitial
      ..load().catchError((e) => print("interstitialError: $e"))
      ..show();
  }

  dispose({bool banner = true, bool interstitial = true}) async {
    print(_banner.isLoaded());
    _banner?.dispose().catchError((e) => print("disposing banner error: $e"))
    ..then((value) {
      print("disposing banner");
      // Provider.of(context).bannerState(!value);
      print("banner disposed: $value");
    });
    _interstitial?.dispose();
  }
}
