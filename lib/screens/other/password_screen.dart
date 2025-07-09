import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import '../../utils/shared_prefs.dart';
import 'faceId.dart';

class PassLock extends StatefulWidget {
  const PassLock({Key? key, this.returnPage}) : super(key: key);

  final returnPage;
  @override
  State<PassLock> createState() => _PassLockState();
}

class _PassLockState extends State<PassLock> {

  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();//入力状況を感知
  bool isAuthenticated = false;
  String? passLockMessage; //エラーメッセージ
  late String pass;
  late int passwordDigits;
  String? biometricType;

  @override
  void initState() {
    // TODO: implement initState
    _getAvailableBiometrics();
    super.initState();
    pass = SharedPrefs.getPassword();
    passwordDigits = pass.length;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _verificationNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primary_color = Theme.of(context).primaryColor;
    Color primary_color_lightness = HSLColor.fromColor(primary_color).withLightness(0.6,).toColor();
    // Color primary_color_lightness2 = HSLColor.fromColor(primary_color).withLightness(1.5,).toColor();

    return  Stack(
      children: [
        PasscodeScreen(
          title: Column(
            children: <Widget>[
              const Icon(Icons.lock, size: 30),
              const Text(
                "パスワード",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              Text(
                // '設定したパスワードを入力してください',
                passLockMessage ?? '設定したパスワードを入力してください',//メッセージを表示します。
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          passwordDigits: passwordDigits,
          circleUIConfig: CircleUIConfig(
            borderColor: Theme.of(context).dividerColor,
            fillColor: Theme.of(context).dividerColor,
            circleSize: 20,
          ),
          keyboardUIConfig: KeyboardUIConfig(
            primaryColor: Theme.of(context).dividerColor,
            digitTextStyle: const TextStyle(fontSize: 25),
            deleteButtonTextStyle: const TextStyle(fontSize: 15),
            // digitSize: 75,
          ),
          passwordEnteredCallback: _onPasscodeEntered,//パスワードが入力された時の処理
          deleteButton: Icon(Icons.cancel, size: 45.0),
          cancelButton: Icon(Icons.cancel, size: 45.0),
          cancelCallback:  _onPasscodeCancelled, //パスワードが入力がキャンセルされた時の処理
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: primary_color,
          // digits: digits,
        ),
        Positioned(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 24, bottom: 48),
              child: faceButton(),
            ),
          ),
        ),
      ],
    );
  }

  //パスワードが桁数まで入力された発動する処理
  _onPasscodeEntered(String enteredPasscode) {
    //パスワードのチェック
    bool isValid = pass == enteredPasscode;
    _verificationNotifier.add(isValid); //パスコードが正しいかどうかをパスコード画面に通知してます。
    if (isValid) {
      // 解錠
      navigationPop(context);
    } else {
      passLockMessage = "パスワードが一致しません";
      setState(() { });
    }
  }

  //入力がキャンセルされたら発動する処理
  _onPasscodeCancelled() async {
  }

  Widget faceButton() {
    return biometricType == null
        ?
    Container()
        :
    CupertinoButton(
      child: Icon(
        biometricType == 'touch' ? Icons.fingerprint : MdiIcons.faceRecognition,
        color: biometricType == 'touch' ? Colors.deepOrangeAccent : Colors.blue,
        size: 50,
      ),
      onPressed: () {
        onFace();
      },
    );
  }

  Future<void> onFace() async {
    bool isLock = await FaceId.authenticate();
    if(isLock) {
      Future.delayed(Duration.zero, () {
        navigationPop(context);
      });
    }
  }

  void navigationPop(context) {
    if(widget.returnPage != null) {
      Future.delayed(Duration.zero, ()
      {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.returnPage),
        );
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    final auth = LocalAuthentication();
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) return;

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
        biometricType = 'face';
        // Face ID.
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        biometricType = 'touch';
      }
    }
    setState(() {});
  }
}