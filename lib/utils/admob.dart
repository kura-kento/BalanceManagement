import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMob{
  static String getBannerAdUnitId() {
    // iOSとAndroidで広告ユニットIDを分岐させる
    if (Platform.isAndroid) {
      // Androidの広告ユニットID
      return 'ca-app-pub-7136658286637435/7436653342';
    } else if (Platform.isIOS) {
      // iOSの広告ユニットID
      return 'ca-app-pub-7136658286637435/7202771519';
    }
    return null;
  }

  static BannerAd admobBanner() {
    // return Container();
    return BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        // 広告が正常にロードされたときに呼ばれます。
        onAdLoaded: (Ad ad) => print('バナー広告がロードされました。'),
        // 広告のロードが失敗した際に呼ばれます。
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('バナー広告のロードに失敗しました。: $error');
        },
        // 広告が開かれたときに呼ばれます。
        onAdOpened: (Ad ad) => print('バナー広告が開かれました。'),
        // 広告が閉じられたときに呼ばれます。
        onAdClosed: (Ad ad) => print('バナー広告が閉じられました。'),
        // ユーザーがアプリを閉じるときに呼ばれます。
        onAdWillDismissScreen: (Ad ad) => print('ユーザーがアプリを離れました。'),
      ),
    );
  }

  static Widget adContainer(myBanner){
    final AdWidget adWidget = AdWidget(ad: myBanner);
    return Container(
      alignment: Alignment.center,
      child: adWidget,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
    );
  }
}