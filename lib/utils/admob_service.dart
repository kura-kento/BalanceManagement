// import 'dart:io';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:flutter/material.dart';
//
// class AdMobService {
//   String getBannerAdUnitId() {
//     // iOSとAndroidで広告ユニットIDを分岐させる
//     if (Platform.isAndroid) {
//       // Androidの広告ユニットID
//       return 'ca-app-pub-7136658286637435/7436653342';
//     } else if (Platform.isIOS) {
//       // iOSの広告ユニットID
//       return 'ca-app-pub-7136658286637435/7202771519';
//     }
//     return null;
//   }
//
//   Widget admobBanner() {
//     return AdmobBanner(
//       adUnitId: AdMobService().getBannerAdUnitId(),
//       adSize: AdmobBannerSize(
//         width: 750,
//         height: 60,
//         name: 'FULL_BANNER',
//       ),
//     );
//   }
// }
