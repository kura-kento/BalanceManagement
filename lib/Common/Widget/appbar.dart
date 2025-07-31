import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app.dart';

class CustomAppBar extends StatefulWidget {
  CustomAppBar({
    super.key,
    this.title,
    this.leftWidget,
    this.rightWidget,
  });

  String? title;
  Widget? leftWidget;
  Widget? rightWidget;
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  double appbarHeight = 55;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: appbarHeight,
      color:  Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(minWidth: 50,),
            child: widget.leftWidget ?? null,),
          Expanded(
            child: Center(child: App.title(widget.title ?? ''),)
          ),
          Container(
            constraints: BoxConstraints(minWidth: 50,),
            child: widget.rightWidget ?? null,),
        ],
      ),
    );
  }
}

