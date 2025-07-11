import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const unit = 'unit';
  static const tapIndex = 'tapTitle';
  static const loginCount = 'loginCount';
  static const adPositionTop = 'adPositionTop';
  static const isPassword = 'isPassword';
  static const password = 'password';
  static const rewardTime = 'rewardTime';

  static SharedPreferences? _sharedPreferences;

  static Future<void> setInstance() async {
    if (null != _sharedPreferences)
      return;
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool>? setUnit(String value) => _sharedPreferences?.setString(unit, value);
  static String getUnit() => _sharedPreferences?.getString(unit) ?? '円';
  //static Future<void> removeUnit() => _sharedPreferences.remove(unit);

  static Future<bool>? setLoginCount(int value) => _sharedPreferences?.setInt(loginCount, value);
  static int getLoginCount() => _sharedPreferences?.getInt(loginCount) ?? 0;

  static Future<bool>? setTapIndex(String value) => _sharedPreferences?.setString(tapIndex, value);
  static String getTapIndex() => _sharedPreferences?.getString(tapIndex) ?? 'both';

  static const tapInt = 'tapInt';
  static Future<bool>? setTapInt(int value) => _sharedPreferences?.setInt(tapInt, value);
  static int getTapInt() => _sharedPreferences?.getInt(tapInt) ?? 0;

  static Future<bool>? setAdPositionTop(bool value) => _sharedPreferences?.setBool(adPositionTop, value);
  static bool getAdPositionTop() => _sharedPreferences?.getBool(adPositionTop) ?? true;

  static Future<bool>? setIsPassword(bool value) => _sharedPreferences?.setBool(isPassword, value);
  static bool getIsPassword() => _sharedPreferences?.getBool(isPassword) ?? false;

  static const isPlus = 'isPlus';
  static Future<bool>? setIsPlus(bool value) => _sharedPreferences?.setBool(isPlus, value);
  static bool getIsPlus() => _sharedPreferences?.getBool(isPlus) ?? true;

  static const isPlusButton = 'isPlusButton';
  static Future<bool>? setIsPlusButton(bool value) => _sharedPreferences?.setBool(isPlusButton, value);
  static bool getIsPlusButton() => _sharedPreferences?.getBool(isPlusButton) ?? true;

  // 金額の色
  static const plusColor = 'plusColor';
  static Future<bool>? setPlusColor(String value) => _sharedPreferences?.setString(plusColor, value);
  static String getPlusColor() => _sharedPreferences?.getString(plusColor) ?? '0x${Colors.lightBlueAccent.toARGB32().toRadixString(16).toUpperCase()}';

  static const minusColor = 'minusColor';
  static Future<bool>? setMinusColor(String value) => _sharedPreferences?.setString(minusColor, value);
  static String getMinusColor() => _sharedPreferences?.getString(minusColor) ?? '0x${Colors.redAccent.toARGB32().toRadixString(16).toUpperCase()}';

  static const textSize = 'textSize';
  static Future<bool>? setTextSize(double value) => _sharedPreferences?.setDouble(textSize, value);
  static double getTextSize() => _sharedPreferences?.getDouble(textSize) ?? 11.0;

  // 固定メモ
  static const memo = 'memo';
  static Future<bool>? setMemo(String value) => _sharedPreferences?.setString(memo, value);
  static String getMemo() => _sharedPreferences?.getString(memo) ?? '';

  //0円を表示させない
  static const isZeroHidden = 'isZeroHidden';
  static Future<bool>? setIsZeroHidden(bool value) => _sharedPreferences?.setBool(isZeroHidden, value);
  static bool getIsZeroHidden() => _sharedPreferences?.getBool(isZeroHidden) ?? false;

  //共通
  static Future<bool>? setPassword(String value) => _sharedPreferences?.setString(password, value);
  static String getPassword() => _sharedPreferences?.getString(password) ?? '0000';
  //【共通】リワード広告
  static Future<bool>? setRewardTime(String value) => _sharedPreferences?.setString(rewardTime, value);
  static String getRewardTime() => _sharedPreferences?.getString(rewardTime) ?? '2021-01-01 00:00:00';

  //【共通】レビューの冷却期間
  static const reviewSkipTime = 'reviewSkipTime';
  static Future<bool>? setReviewSkipTime(String value) => _sharedPreferences?.setString(reviewSkipTime, value);
  static String getReviewSkipTime() => _sharedPreferences?.getString(reviewSkipTime) ?? '2021-01-01 00:00:00';
}
