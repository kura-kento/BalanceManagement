import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SelectMonthWidget extends StatelessWidget {
  const SelectMonthWidget({this.tapLeft, this.tapRight, this.text});
  final tapLeft;
  final tapRight;
  final text;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Row(children: <Widget>[
        Expanded(
          flex:1,
          child: IconButton(
            onPressed: tapLeft,
            iconSize:30,
            icon: const Icon(Icons.arrow_left),
          ),
        ),
        Expanded(
          flex:5,
          //アイコン
          child:Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              text,
              style: const TextStyle(
                  fontSize: 30
              ),
            ),
          ),
        ),
        Expanded(
          flex:1,
          //アイコン
          child: IconButton(
            onPressed: tapRight,
            iconSize:30,
            icon: const Icon(Icons.arrow_right),
          ),
        ),
      ]),
    );
  }
}
