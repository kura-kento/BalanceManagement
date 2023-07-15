import 'package:balancemanagement_app/screens/home_page.dart';
import 'package:balancemanagement_app/screens/other/password_screen.dart';
import 'package:balancemanagement_app/utils/CostomTheme.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'i18n/message.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(
    ProviderScope(
      child: RestartWidget(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [const Locale('ja', 'JP'), const Locale('en')],
      localizationsDelegates: [const AppLocalizationsDelegate(), GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate, DefaultCupertinoLocalizations.delegate],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.white70),
        primaryColor: Color(int.parse(SharedPrefs.getCustomColor())),
        fontFamily: "Noto Sans JP",
          cupertinoOverrideTheme: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(fontSize: 20.0, color: Colors.black87, fontFamily: "Noto Sans JP"),
                pickerTextStyle: TextStyle(fontSize: 20.0, color: Colors.black87, fontFamily: "Noto Sans JP"),
              )
          )
      ),
      home: FutureBuilder(
          //AsyncSnapshot = future:　の中
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            } else {
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
    WidgetsFlutterBinding.ensureInitialized();
    if(SharedPrefs.getIsPassword()){
      return PassLock();
    }else{
      return HomePage();
    }
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

//todo データ削除時　スナップショット
//todo データ削除　月ごとに
//todo　お問い合わせ(画像、募金)
//todo　カラーテーマ
//todo　広告の位置ボタン選択レイアウト
// ・グラフページ「合計」タブ、マイナスの時もプラス表記の不具合修正
// ・「編集ページ」整数が小数点表記となる不具合修正
//小数点追加
