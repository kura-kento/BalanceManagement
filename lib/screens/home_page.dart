import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/screens/calendar/calendar_page.dart';
import 'package:balancemanagement_app/screens/other/password_screen.dart';
import 'package:balancemanagement_app/screens/other/setting_page.dart';
import 'package:balancemanagement_app/utils/admob.dart';
import 'package:balancemanagement_app/utils/page_animation.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'graph/graph_bar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // BannerAd myBanner = AdMob.admobBanner();
  final BannerAd myBanner = AdMob.admobBanner();
  final BannerAd myBanner2 = AdMob.admobBanner2();
  //以下BottomNavigationBar設定
  int _currentIndex = 0;
  final _pageWidgets = [
    const CalendarPage(),
    // GraphBarPage(),
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
      if(SharedPrefs.getIsPassword()){
        Navigator.push(
          context,
          SlidePageRoute(
            page:PassLock(),
            settings: RouteSettings(name: '',),
          ),
        );

      }
    }
  }

  List<Widget> list() {
    return <Widget>[
      // AdMob.adContainer(myBanner),
      SharedPrefs.getAdPositionTop()
          ?
      AdMob.adContainer(myBanner)
          :
      AdMob.adContainer(myBanner2)
      ,
      Expanded(child: _pageWidgets.elementAt(_currentIndex)),
    ];
  }

//メインのページ
  @override
  Widget build(BuildContext context) {
    print('isNoAds:' + AdMob.isNoAds().toString());
    if(AdMob.isNoAds() == false){
      myBanner.load();
      myBanner2.load();
    }

    return Container(
      color: Colors.grey[300],
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            // children: list(),),
              children: SharedPrefs.getAdPositionTop()
                  ? list()
                  : list().reversed.toList()),
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
            elevation: 1.0,
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
