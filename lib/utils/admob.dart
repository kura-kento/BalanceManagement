import 'dart:io';

import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';
import 'package:intl/intl.dart';

class AdMob{
  static Widget banner(){

      return Container(
        width: 1000,
        color: Colors.grey[300],
        child: DFPBanner(
          isDevelop: true,
          testDevices: MyTestDevices(),
          adUnitId: Platform.isIOS ? 'ca-app-pub-7136658286637435/7202771519' :'ca-app-pub-7136658286637435/7436653342',
          adSize: DFPAdSize.BANNER,
          onAdLoaded: () {
            print('Banner onAdLoaded');
            print(SharedPrefs.getClickTime());
          },
          onAdFailedToLoad: (errorCode) {
            print('Banner onAdFailedToLoad: errorCode:$errorCode');
          },
          onAdOpened: () {
            print('Banner onAdOpened');
            SharedPrefs.setClickTime(DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()));
          },
          onAdClosed: () {
            print('Banner onAdClosed');
          },
          onAdLeftApplication: () {
            print('Banner onAdLeftApplication');
          },
        ),
      );
  }
}

class MyTestDevices extends TestDevices {
  static MyTestDevices _instance;

  factory MyTestDevices() {
    if (_instance == null) _instance = new MyTestDevices._internal();
    return _instance;
  }

  MyTestDevices._internal();

  @override
  List<String> get values => List()..add("75552646040bbf3d8fb887e5b108f30a")//iphoneSE2
                                   ..add("180c3203193a164f65d8315c594bc62c")//iphone6s+
                                   ..add("F6E54DB22F15DE9080D5A43D74CE5DA2");
}


