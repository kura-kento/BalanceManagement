import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final inAppPurchaseManager = ChangeNotifierProvider((ref) => InAppPurchaseManager());

class InAppPurchaseManager with ChangeNotifier {
  bool isSubscribed = false;
  late Offerings offerings;


  // 初期値
  Future<void> initInAppPurchase() async {

    try {
      //consoleにdebug情報を出力する
      await Purchases.setLogLevel(LogLevel.debug);
      late PurchasesConfiguration configuration;

      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration("goog_stzxsffGUBTYsfxreXhPBAmkopS");
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration("appl_JNKTMdLweRntJMSqIUzgbNObpLt"); //ios用のRevenuecat APIキー
      }
      await Purchases.configure(configuration);
      //offeringsを取ってくる
      offerings = await Purchases.getOfferings();

      // firebaseのidと、revenuecatのuserIdを一緒にしている場合、firebaseAuthのuidでログイン


      // このアプリを使用している人のID
      final result = await Purchases.logIn("unique_user_id");
      await getPurchaserInfo(result.customerInfo);
      final package = offerings.current?.availablePackages.first;

      if (package != null) {
        final purchaseResult = await Purchases.purchasePackage(package);
        print("購入完了: ${purchaseResult.entitlements.active.keys}");
      }

      //今アクティブになっているアイテムは以下のように取得可能
      print("アクティブなアイテム ${result.customerInfo.entitlements.all}");
      print("アクティブなアイテム ${result.customerInfo.entitlements.active.keys}");
    } catch (e) {
      print("initInAppPurchase error caught! ${e.toString()}");
    }

  }

  Future<void> getPurchaserInfo(CustomerInfo customerInfo) async {
    try {
      // RevenueCat内 Product catalog > entitlement > Identifer
      isSubscribed = await updatePurchases(customerInfo, "NoAds");

    } on PlatformException catch (e) {
      print(" getPurchaserInfo error ${e.toString()}");
    }
  }

  Future<bool> updatePurchases(CustomerInfo purchaserInfo, String entitlement) async {
    var isPurchased = false;
    final entitlements = purchaserInfo.entitlements.all;
    if (entitlements.isEmpty) {
      print("entitlements.isEmpty");
      isPurchased = false;
    }
    if (!entitlements.containsKey(entitlement)) {
      print("そもそもentitlementが設定されて無い場合");
      isPurchased = false;
    } else if (entitlements[entitlement]!.isActive) {
      print("設定されていて、activeになっている場合");
      isPurchased = true;
    } else {
      isPurchased = false;
    }
    return isPurchased;
  }
  // 復元
  Future<void> restorePurchase(String entitlement) async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      final isActive = await updatePurchases(customerInfo, entitlement);
      if (!isActive) {
        print("購入情報なし");
      } else {
        await getPurchaserInfo(customerInfo);
        print("${entitlement} 購入情報あり　復元する");
      }
    } on PlatformException catch (e) {
      print("purchase repo  restorePurchase error ${e.toString()}");
    }
  }
}
