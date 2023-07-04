
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

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

  static String numDel(number) {
    return number.substring(0, number.length - 1);
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
  static String evaluate(value) {
    try {
      final expression = Parser().parse(value);
      final double result = expression.evaluate(EvaluationType.REAL, ContextModel());
      return result.toString();
    } catch (e) {
      return 'Error';
    }
  }

}

