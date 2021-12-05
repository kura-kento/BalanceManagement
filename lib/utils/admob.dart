import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'shared_prefs.dart';

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

  static BannerAd admobBanner2() {
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
    DateTime charge_Time = DateTime.parse(SharedPrefs.getRewardTime());
    //分の差を出す。（マイナスなら現在時間からプラスする。）
    int diff_time = charge_Time.difference(DateTime.now()).inMinutes;

    if(isNoAds()) return Container();
    AdWidget adWidget = AdWidget(ad: myBanner);
    return Container(
      alignment: Alignment.center,
      child: adWidget,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
    );
  }

  //広告非表示がチャージを行っていたらtrueを返す。
  static bool isNoAds(){
    DateTime charge_Time = DateTime.parse(SharedPrefs.getRewardTime());
    //分の差を出す。（マイナスなら現在時間からプラスする。）
    int diff_time = charge_Time.difference(DateTime.now()).inMinutes;
    return diff_time > 0;
  }
}