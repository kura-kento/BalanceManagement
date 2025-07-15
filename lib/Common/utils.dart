import 'dart:math';

import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Utils {
  //カンマ区切り
  static String commaSeparated(dynamic number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

//int型に変更
  static int toInt(value) {
    if(value != '')
      return int.parse(value.toString());
    else
      return 0;
  }

  static double toDouble(value) {
     if(value != '')
       return double.parse(value.toString());
     else
       return 0;
  }

  //int型に変更
  static String zeroPadding(value) {
    if(value.length == 1) {
      return ' ' + value ;
    }else{
      return value;
    }
  }
//何文字以上で…に変える
  static double parseSize(context, value) {
    return value * MediaQuery.of(context).size.width / 375.0;
  }

  // 小数点0の場合は切り上げする。
  static String formatNumber(value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toString();
    }
  }

  // 設定している箇所で四捨五入を行う
  static double round(double num) {
    int decimalPlace = SharedPrefs.getDecimalPlace();
    int digits =  pow(10, decimalPlace).toInt();
    return (num * digits).round() / digits;
  }
}

