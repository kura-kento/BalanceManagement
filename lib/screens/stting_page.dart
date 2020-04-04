import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Text('${SharedPrefs.getUnit()}'),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            SharedPrefs.setUnit("円");
          });
        },
      ),
    );
  }
}
