
import 'package:intl/intl.dart';

class Utils{
  //カンマ区切り
  static String commaSeparated(number){
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
//何文字以上で…に変える

}

