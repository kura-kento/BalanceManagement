import 'dart:async';

import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/screens/calendar_page.dart';
import 'package:balancemanagement_app/screens/setting_page.dart';
import 'package:balancemanagement_app/utils/admob.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'graph_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //以下BottomNavigationBar設定
  int _currentIndex = 0;
  final _pageWidgets = [
    CalendarPage(),
    GraphPage(),
    SettingPage(),
  ];

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {});
    });
    super.initState();
  }

  List<Widget> list() {
    return <Widget>[
      AdMob.banner(),
      Expanded(child: _pageWidgets.elementAt(_currentIndex)),
    ];
  }

//メインのページ
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
              children: SharedPrefs.getAdPositionTop()
                  ? list()
                  : list().reversed.toList()),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), title: Text(AppLocalizations.of(context).calendar)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.equalizer), title: Text(AppLocalizations.of(context).graph)),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), title: Text(AppLocalizations.of(context).setting)),
            ],
            iconSize: 20.0,
            selectedFontSize: 10.0,
            unselectedFontSize: 8.0,
            currentIndex: _currentIndex,
            fixedColor: Colors.blueAccent,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);
}
