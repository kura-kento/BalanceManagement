import 'package:intl/intl.dart';

class Utils{
  //カンマ区切り
  static String commaSeparated(number){
    final formatter = NumberFormat("#,###");
    var result = formatter.format(number);
    return result;
  }

//int型に変更
  static int toInt(value) {
    final int _value = int.parse(value.toString());
    return _value;
  }

}