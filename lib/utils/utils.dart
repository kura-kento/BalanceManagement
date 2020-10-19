
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
     int _value = 0;
     if(value != ""){_value = int.parse(value.toString());}
    return _value;
  }
//何文字以上で…に変える

}

