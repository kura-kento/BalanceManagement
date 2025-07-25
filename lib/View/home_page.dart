import 'dart:async';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/View/calendar/calendar_page.dart';
import 'package:balancemanagement_app/Common/PassLock/password_screen.dart';
import 'package:balancemanagement_app/Common/page_animation.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Common/Admob/admob_banner.dart';
import '../Common/app.dart';
import 'Setting/setting_page.dart';
import 'graph/graph_bar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  //以下BottomNavigationBar設定
  int _currentIndex = 0;
  final _pageWidgets = [
    const CalendarPage(),
    GraphBarPage(),
    SettingPage(),
  ];

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {});
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tracking();
  }

  Future<void> tracking() async {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // onResume処理
      if(SharedPrefs.getIsPassword() && SharedPrefs.getPassword() != '') {
        Navigator.push(
          context,
          SlidePageRoute(
            page: PassLock(),
            settings: RouteSettings(name: '',),
          ),
        );
      }
    }
  }

//メインのページ
  @override
  Widget build(BuildContext context) {
    return Container(
      color: App.bgColor,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: BannerBody(
                child: _pageWidgets.elementAt(_currentIndex)
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: const Icon(Icons.calendar_today), label: AppLocalizations.of(context).calendar),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.equalizer), label: AppLocalizations.of(context).graph),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.settings), label: AppLocalizations.of(context).setting),
              ],
              iconSize: 20.0,
              selectedFontSize: 10.0,
              unselectedFontSize: 8.0,
              elevation: 0,
              currentIndex: _currentIndex,
              fixedColor: Colors.blueAccent,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);
}
