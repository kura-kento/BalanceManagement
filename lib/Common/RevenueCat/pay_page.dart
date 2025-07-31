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

  @override
  void initState() {
    super.initState();
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
                          title: "広告"
                      ),
                      Container(),
                      // 購入
                      ElevatedButton(
                        onPressed: () async {
                          await manager.initInAppPurchase(); // 初期化
                        },
                        child: Container(
                          color: Colors.red,
                          height: 200,
                          width: 300,
                        ),),
                      // 復元
                      InkWell(
                        onTap: () {
                          manager.restorePurchase("NoAds");
                        },
                        child: Container(
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey,width: 0.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            height: 50,
                            child: Center(
                              child: Text(
                                "購入情報を復元する",
                                style: TextStyle(color:Colors.red,fontSize: 24),
                              ),),),
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
