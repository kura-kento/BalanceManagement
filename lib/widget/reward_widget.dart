import 'dart:io';

import 'package:balancemanagement_app/utils/app.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RewardWidget extends StatefulWidget {
  const RewardWidget({Key key}) : super(key: key);

  @override
  _RewardWidgetState createState() => _RewardWidgetState();
}

class _RewardWidgetState extends State<RewardWidget> {

  RewardedAd _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  @override
  void initState(){
    _createRewardedAd();
    super.initState();
  }

  static String getRewardedUnitId(){
    String BannerUnitId = "";
    if(Platform.isAndroid) {
      // Android のとき
      BannerUnitId = "ca-app-pub-7136658286637435/2517114489";

      // Android のとき test
      // BannerUnitId =  "ca-app-pub-3940256099942544/5224354917";
    } else if(Platform.isIOS) {
      // iOSのとき
      BannerUnitId = "ca-app-pub-7136658286637435/7074069496";
    }
    return BannerUnitId;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        // adUnitId: RewardedAd.testAdUnitId,
        adUnitId: getRewardedUnitId(),
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            // if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            //   _createRewardedAd();
            // }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('全画面広告を表示しています。'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad 全画面広告を閉じました');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd.setImmersiveMode(true);
    _rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
      //ここに報酬を書く
      DateTime charge_Time = DateTime.parse(SharedPrefs.getRewardTime());
      //分の差を出す。（マイナスなら現在時間からプラスする。）
      int diff_time = charge_Time.difference(DateTime.now()).inMinutes;

      DateTime addTime = (diff_time < 0
                                ?
                          DateTime.now()
                                :
                          charge_Time
                          ).add(Duration(hours: App.addHours));

      SharedPrefs.setRewardTime(addTime.toString());
      setState(() {});
    });
    _rewardedAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _rewardedAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime charge_time = DateTime.parse(SharedPrefs.getRewardTime());
    int diff_time = charge_time.difference(DateTime.now()).inHours;
    print('広告非表示期限：'+ SharedPrefs.getRewardTime());
    print(diff_time);

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          SfLinearGauge(
            interval: 40,
            maximum: 360,
            ranges: [
            ],
            markerPointers: [
              LinearShapePointer(
                value: diff_time * 1.0,
              ),
            ],
            barPointers: [
              LinearBarPointer(
                color:App.NoAdsButtonColor,
                value: diff_time * 1.0,
              )
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: App.NoAdsButtonColor, //ボタンの背景色
            ),
            onPressed: () {
              _showRewardedAd();
            },
            // battery_charge
            child: Container(
              width: 250,
              child: Center(
                child: Text(
                  "広告非表示期間を貯める(40h)",
                  textScaleFactor: 1.5,
                  style: TextStyle(fontSize: App.BTNfontsize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//sharedprefsに追加

