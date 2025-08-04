import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Admob/admob_banner.dart';
import '../Widget/appbar.dart';
import '../app.dart';
import 'InAppPurchaseManager.dart';

class PayPage extends StatefulWidget {
  const PayPage({Key? key}) : super(key: key);

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  String? userId = null;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  // ユーザー情報の取得
  getUserInfo() async {
    // firebaseに既に登録済みかを判定する。
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      userId = auth.currentUser?.uid ?? null;
    }
    // AppleIDを紐付けている？

    // まだない場合や未購入の場合は購入画面に進める。
    // 購入の処理でfirebaseにアカウントが紐づけられる。
    // 14日間無料トライアル　 14日間のお試し

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: App.bgColor,
      child: SafeArea(
        child: Scaffold(
          body: BannerBody(
            child: Consumer(
                builder: (context, ref, _) {
                  final manager = ref.watch(inAppPurchaseManager);
                  return Column(
                    children: [
                      CustomAppBar(
                          leftWidget: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          title: "プレミアム登録"
                      ),
                      //　どんな特典があるか
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.not_interested, color: Colors.red, size: 40,),
                              title: Text("広告の無効化"),
                              subtitle: Text("邪魔な広告を消して、ストレスフリーに使用できます。"),
                            ),
                            ListTile(
                              leading: Icon(Icons.wb_cloudy_outlined, color: Colors.amber, size: 40,),
                              title: Text("iCloud同期"),
                              subtitle: Text("デバイス間で入力データを自動で同期。バックアップや機種変更にも対応可能。"),
                            ),
                            Container(
                              child: Text("※サブスクリプションの内容は変更される場合があります。"),
                            ),
                          ],
                        ),
                      ),
                      // 購入
                      ElevatedButton(
                        onPressed: () async {
                          await manager.initInAppPurchase(); // 初期化
                        },
                        child: Container(
                          height: 50,
                          width: 300,
                          child: Center(child: Text("プレミアムに加入する")),
                        ),),
                      // 復元
                      InkWell(
                        onTap: () {
                          manager.restorePurchase("NoAds");
                        },
                        child: Center(
                          child: Text(
                            "サブスクリプションを復元",
                            style: TextStyle(color:App.premiumColor,fontSize: 24,fontWeight: FontWeight.bold),
                          ),),
                      )
                    ],
                  );
                }
              ),
            ),
          ),
        )
    );
  }
}
