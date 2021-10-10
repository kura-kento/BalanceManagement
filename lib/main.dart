import 'package:balancemanagement_app/screens/home_page.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'i18n/message.dart';

//final myAppKey = GlobalKey<MyApp>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        supportedLocales: [
          const Locale('ja','JP'),
          const Locale('en')
        ],
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(color: Colors.white70),
          primarySwatch: Colors.grey,
        ),
        home: FutureBuilder(
          //AsyncSnapshot = future:　の中
          builder: (BuildContext context ,AsyncSnapshot snapshot){
            if(snapshot.hasData){
              return snapshot.data;
            }else{
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          future: setting(),
        ),
      );
  }
  Future<Widget> setting()async{
    //await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SharedPrefs.setInstance();
    DatabaseHelper.db = await DatabaseHelper.initializeDatabase();
    DatabaseHelperCategory.db = await DatabaseHelperCategory.initializeDatabase();
    WidgetsFlutterBinding.ensureInitialized();
    return HomePage();
  }
}

//todo データ削除時　スナップショット
//todo データ削除　月ごとに
//todo
//todo
