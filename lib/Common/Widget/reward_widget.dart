import 'dart:io';

import 'package:balancemanagement_app/Common/app.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../main.dart';

class RewardWidget extends StatefulWidget {
  const RewardWidget({Key? key}) : super(key: key);

  @override
  _RewardWidgetState createState() => _RewardWidgetState();
}

class _RewardWidgetState extends State<RewardWidget> {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3; //再度繰り返す回数

  @override
  void initState() {
    _createRewardedAd();
    super.initState();
  }

  static String getRewardedUnitId(){
    String BannerUnitId = "";
    if(Platform.isAndroid) {
      // Android のとき
      BannerUnitId = 'ca-app-pub-7136658286637435/2517114489';
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
        adUnitId: getRewardedUnitId(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            setState(() { }); //ボタンが活性
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('全画面広告を表示しています。'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad 全画面広告を閉じました');
        ad.dispose();
        RestartWidget.restartApp(context);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd?.setImmersiveMode(true);
    _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
      //ここに報酬を書く
      DateTime chargeTime = DateTime.parse(SharedPrefs.getRewardTime());
      //分の差を出す。（マイナスなら現在時間からプラスする。）
      int diffTime = chargeTime.difference(DateTime.now()).inMinutes;

      DateTime addTime = (diffTime < 0
          ?
      DateTime.now()
          :
      chargeTime
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
    DateTime chargeTime = DateTime.parse(SharedPrefs.getRewardTime());
    int diffTime = chargeTime.difference(DateTime.now()).inHours;
    // print('広告非表示期限：'+ SharedPrefs.getRewardTime());
    // print(diffTime);

    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SfLinearGauge(
            interval: 40,
            maximum: 360,
            ranges: const [],
            markerPointers: [
              LinearShapePointer(
                value: diffTime * 1.0,
              ),
            ],
            barPointers: [
              LinearBarPointer(
                color: App.NoAdsButtonColor,
                value: diffTime * 1.0,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                ),
                backgroundColor: App.NoAdsButtonColor, //ボタンの背景色
              ),
              onPressed: _rewardedAd == null ? null : () {
                _showRewardedAd();
              },
              // battery_charge
              child: Container(
                width: 250,
                child: Center(
                  child: Text(
                    "リワード広告視聴で広告\n非表示期間を貯める(${App.addHours}時間)",
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: App.BTNfontsize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
