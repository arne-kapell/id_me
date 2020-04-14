import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable_card/expandable_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:id_me/code_display.dart';
import 'package:id_me/contacts_display.dart';
import 'package:id_me/models/data.dart';
import 'package:id_me/models/functions.dart';
import 'package:id_me/models/profil.dart';
import 'package:id_me/profile_display.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String own_id;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences p = await SharedPreferences.getInstance();
  if (p.getInt('OWN_ID') == null) {
    int own = DateTime.now()
        .add(Duration(seconds: Random.secure().nextInt(999)))
        .hashCode;
    p.setInt('OWN_ID', own);
    own_id = own.toString();
  } else {
    own_id = p.getInt('OWN_ID').toString();
  }
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'idME',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Baloo',
          brightness: Brightness.dark,
          primarySwatch: Colors.blueGrey,
          primaryColor: hexColor("#485265"), // Independence - darkblueish
          accentColor: hexColor("#cdcdcd"), // Pastel Gray
          backgroundColor: hexColor("#ebebeb"), // Isabelline
          snackBarTheme: SnackBarThemeData(
            backgroundColor: hexColor("#ebebeb"), // Isabelline
            elevation: 5
          ),
          // scaffoldBackgroundColor: hexColor("#485265"),
          textTheme: TextTheme(
              // primaryColor: Hexcolor("#485265"), // Independence - darkblueish
              // textStyle: TextStyle(
              //   color: Hexcolor("#ebebeb"), // Isabelline
              )),
      routes: {
        '/': (context) => HomeScreen(),
      },
      initialRoute: '/',
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _controller;
  int _page;
  bool _scan;

  @override
  void initState() {
    _controller = PageController(initialPage: 1, keepPage: false);
    _scan = false;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _swipe(int newPage) {
    _controller.animateToPage(newPage,
        duration: Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  void _processQr(String code, BuildContext context) {
    if (code.startsWith('idme://')) {
      Profil profil = Profil(false);
      profil.fromString(code.substring(7), notify: false);
      Provider.of<Data>(context, listen: false).add(profil);
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(profil.name)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Profil(true, id: own_id)),
        ChangeNotifierProvider(create: (_) => Data())
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: ExpandableCardPage(
          page: PageView(
            // physics: NeverScrollableScrollPhysics(),
            controller: _controller,
            children: <Widget>[
              SafeArea(top: true, child: ContactsDisplay()),
              SafeArea(top: true, child: CodeDisplay()),
              SafeArea(top: true, child: ProfileDisplay()),
            ],
            onPageChanged: (i) => setState(() => _page = i),
          ),
          expandableCard: ExpandableCard(
            hasRoundedCorners: true,
            hasHandle: false,
            minHeight: kBottomNavigationBarHeight * 2,
            maxHeight: MediaQuery.of(context).size.width +
                (kBottomNavigationBarHeight * 2),
            padding: EdgeInsets.zero,
            children: <Widget>[
              Icon((true) ? Ionicons.ios_arrow_up : Ionicons.ios_arrow_down,
                  size: 50),
              Center(
                  child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  splashColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (!_scan) {
                      Timer(Duration(seconds: 20),
                          () => setState(() => _scan = false));
                    }
                    setState(() => _scan = !_scan);
                  },
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.8,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: (_scan)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Builder(builder: (context) {
                                return QRBarScannerCamera(
                                  onError: (context, error) => Center(
                                    child: AutoSizeText(
                                      error.toString(),
                                      style: TextStyle(color: Colors.red),
                                      minFontSize: 20,
                                    ),
                                  ),
                                  qrCodeCallback: (code) {
                                    setState(() => _scan = false);
                                    _processQr(code, context);
                                  },
                                  notStartedBuilder: (context) => Center(
                                      child: CircularProgressIndicator()),
                                );
                              }),
                            )
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(MaterialCommunityIcons.qrcode_scan),
                              ))),
                ),
              )),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          // type: BottomNavigationBarType.shifting,
          currentIndex: _page ?? 1,
          items: [
            BottomNavigationBarItem(
                title: Container(),
                icon: Icon(MaterialCommunityIcons.contacts),
                activeIcon: Icon(MaterialCommunityIcons.contacts,
                    size: 40, color: Theme.of(context).backgroundColor)),
            BottomNavigationBarItem(
                title: Container(),
                icon: Icon(AntDesign.qrcode),
                activeIcon: Icon(AntDesign.qrcode,
                    size: 40, color: Theme.of(context).backgroundColor)),
            BottomNavigationBarItem(
                title: Container(),
                icon: Icon(FontAwesome.user_o),
                activeIcon: Icon(FontAwesome.user_o,
                    size: 40, color: Theme.of(context).backgroundColor)),
          ],
          onTap: (i) => _swipe(i),
        ),
      ),
    );
  }
}
