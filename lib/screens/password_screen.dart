import 'dart:async';

import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lock_screen/flutter_lock_screen.dart';
import 'package:local_auth/local_auth.dart';

import 'home_page.dart';

class PassLock extends StatefulWidget {
  const PassLock({Key key}) : super(key: key);

  @override
  _PassLockState createState() => _PassLockState();
}

class _PassLockState extends State<PassLock>{
  bool isFingerprint = false;

  Future<Null> biometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
          // biometricOnly: true,
          // useErrorDialogs: true,
          // stickyAuth: false
      );
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    if (authenticated) {
      setState(() {
        isFingerprint = true;
      });
    }
  }
  // @override
  // void initState() {
  //   Timer.periodic(const Duration(seconds: 1), (timer) {
  //     biometrics();
  //   });
  //   super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    var map = SharedPrefs.getPassword().split('');
    var myPass = List.generate(map.length, (index) => int.parse(map.toList()[index]));
 
    return Scaffold(
      body: LockScreen(
          title: "パスワードを入力",
          passLength: myPass.length,
          bgImage: "assets/images/bg.jpeg",
          fingerPrintImage: Image.asset("assets/images/fingerprint.png",color: Theme.of(context).cardColor),
          showFingerPass: true,
          fingerFunction: biometrics,
          fingerVerify: isFingerprint,
          borderColor: Theme.of(context).cardColor,
          showWrongPassDialog: true,
          wrongPassContent: "再度入力してください",
          wrongPassTitle: "パスワードが違います",
          wrongPassCancelButtonText: "Cancel",
          passCodeVerify: (passcode) async {
            for (int i = 0; i < myPass.length; i++) {
              if (passcode[i] != myPass[i]) {
                return false;
              }
            }

            return true;
          },
          onSuccess: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
                  return HomePage();
                }));
          }),
    );
  }
}
