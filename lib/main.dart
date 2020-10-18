import 'package:balancemanagement_app/screens/home_page.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        supportedLocales: [Locale("ja","JP")],
        localizationsDelegates: [GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate,DefaultCupertinoLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(color: Colors.white70),
          primarySwatch: Colors.grey,
        ),
        home: FutureBuilder(
          //AsyncSnapshot = future:　の中
          builder: (BuildContext context ,AsyncSnapshot snapshot){
            if(snapshot.hasData){
              return snapshot.data;
            }else{
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          future: setting(),
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      );
  }
  Future<Widget> setting()async{
    //await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SharedPrefs.setInstance();
    DatabaseHelper.db = await DatabaseHelper.initializeDatabase();
    DatabaseHelperCategory.db = await DatabaseHelperCategory.initializeDatabase();
    return HomePage();
  }
}

