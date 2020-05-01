import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';

class AdMob{
  static Widget banner(){
    return   DFPBanner(
      isDevelop: false,
      testDevices: MyTestDevices(),
      adUnitId: 'ca-app-pub-3940256099942544/2934735716',
      adSize: DFPAdSize.BANNER,
      onAdLoaded: () {
        print('Banner onAdLoaded');
      },
      onAdFailedToLoad: (errorCode) {
        print('Banner onAdFailedToLoad: errorCode:$errorCode');
      },
      onAdOpened: () {
        print('Banner onAdOpened');
      },
      onAdClosed: () {
        print('Banner onAdClosed');
      },
      onAdLeftApplication: () {
        print('Banner onAdLeftApplication');
      },
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
                                   ..add("180c3203193a164f65d8315c594bc62c");//iphone6s+
  // Set here.
}