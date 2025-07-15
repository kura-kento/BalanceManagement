import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:flutter/material.dart';

class App {
   static int graphLength = 10;

   static Color bgColor = Color(0xffE0E0E0); // grey[300]
   // static Color plusColor = Colors.lightBlueAccent;
   // static Color minusColor = Colors.redAccent;
   static Color plusColor = Color(int.parse(SharedPrefs.getPlusColor()));
   static Color minusColor = Color(int.parse(SharedPrefs.getMinusColor()));
   static double dayTextSize = SharedPrefs.getTextSize();

   static Color NoAdsButtonColor = Color(0xffFFD865);

   static int addHours = 60;

   static double BTNfontsize = 12;

   static int infinityPage = 10000;

   static final EdgeInsets padding = const EdgeInsets.only(top: 15);

   static double appbar_height = 40.0;
   static Color primary_color = Color(0xffFFD865);

   static Widget title(String title, Color fontColor, {double fontSize = 20.0}) {
      return  Text(
         title,
         style: TextStyle(
            fontSize: fontSize,
            color: fontColor ?? Colors.white,
            fontWeight: FontWeight.bold,
         ),
      );
   }

   // 縦のサイズが小さい
   static bool isSmall(context) {
      return MediaQuery.of(context).size.height < 700;
   }

   static double sizeConvert(context,double size) {
      return size;
      // if(isIPad(context)) {
      //    return size * 1.5;
      // } else {
      //    return size;
      // }
   }


}