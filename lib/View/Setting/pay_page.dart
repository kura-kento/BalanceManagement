import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Common/RevenueCat/InAppPurchaseManager.dart';

class PayPageTest extends StatelessWidget {
  const PayPageTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, _) {
          final manager = ref.watch(inAppPurchaseManager);
          return ListTile(
            title: const Text('広告無効（有料）',style: TextStyle(fontWeight: FontWeight.bold),),
            leading: const Icon(Icons.calendar_month),
            onTap: () async {
              await manager.initInAppPurchase(); // 初期化
            },
          );
        }
    );
  }
}
