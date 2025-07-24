import 'dart:math';

import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

import 'app.dart';


class Utils {
  //カンマ区切り
  static String commaSeparated(dynamic number) {
    final formatter = NumberFormat('#,###.#####');
    return formatter.format(Utils.round(number));
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
    // double _double = Utils.round(value);
    if (value == value.roundToDouble()) {
      return value.round().toString();
    } else {
      return value.toString();
    }
  }

  // 設定している箇所で四捨五入を行う
  static double round(num) { // Utils.round()
    int decimalPlace = SharedPrefs.getDecimalPlace();
    int digits =  pow(10, decimalPlace).toInt();
    return (num * digits).round() / digits;
  }


  static String numDel(number) {
    return number.substring(0, number.length - 1);
  }

  //四則演算　変換
  static String parseOperation(value) {
    if(value == '×') {
      return '*';
    }else if(value == '÷') {
      return '/';
    }
    return value;
  }

  //　文字列を計算する
  static String calculation(String front,String operation,String back) {
    double _front = double.parse(front);
    double _back  = double.parse(back);
    double? result;
    try {
      if(operation == '+') {
        result = (_front + _back);
      } else if (operation == '-') {
        result = (_front - _back);
      } else if (operation == '×') {
        result = (_front * _back);
      } else if (operation == '÷') {
        result = (_front / _back);
      }
      return formatNumber(result);
    } catch (e) {
      return 'Error';
    }
  }

  // 数字が含まれているか
  static bool isNumber(String value) {
    RegExp exp = RegExp(r'([0-9.]+)');
    bool is_number = exp.hasMatch(value);
    return is_number;
  }

  static Color getMoneyColor(money) {
    if (isNumber(money.toString())) {
      if (formatNumber(money) == '0') {
        return Colors.black87;
      };
      return money >= 0
          ? App.plusColor : App.minusColor;
    } else {
      return Colors.black87;
    }
  }
}

