import 'package:balancemanagement_app/screens/home_page.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        theme: ThemeData(
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
                  child: CircularProgressIndicator(
                  ),
                ),
              );
            }
          },
          future: method(),
        )
      );
  }
  Future<Widget> method()async{
    await SharedPrefs.setInstance();

    DatabaseHelper.db = await DatabaseHelper.initializeDatabase() ;
    return HomePage();
  }
}
