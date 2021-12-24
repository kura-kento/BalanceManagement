
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Utils{
  //カンマ区切り
  static String commaSeparated(int number){
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
}

