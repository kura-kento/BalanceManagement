import 'package:flutter/material.dart';

class App {
   static int graphLength = 10;

   static Color plusColor = Colors.lightBlueAccent[200];
   static Color minusColor = Colors.redAccent[200];

   static Color NoAdsButtonColor = Color(0xffFFD865);

   static int addHours = 40;

   static double BTNfontsize = 10;

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
}