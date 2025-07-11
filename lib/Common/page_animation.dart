import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;
  SlidePageRoute({required this.page, required this.settings})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) {
      return page;
    },
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget page,
        ) {
      return FadeTransition(opacity: animation, child: page);
    },
  );
}

//new RotationTransition(
//turns: animation,
//child: new ScaleTransition(
//scale: animation,
//child: new FadeTransition(
//opacity: animation,
//child: new SecondPage(),
//),
//));