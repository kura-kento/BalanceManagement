import 'dart:async';

import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/screens/other/setting_detail.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/widget/daialog_select.dart';
import 'package:balancemanagement_app/widget/reward_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class SettingPage extends StatefulWidget {

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<Category> categoryList = <Category>[];
  TextEditingController passwordController = TextEditingController(text: SharedPrefs.getPassword());

  @override
  void initState() {
    updateListViewCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(
              children: [
                Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey[300],
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(AppLocalizations.of(context).setting, style: TextStyle(fontSize: 20,color: Colors.black)),
                    )
                ),
                Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          RewardWidget(),
                          Divider(color: Colors.grey,height:0),
                          SelectDialog(),
                          Divider(color: Colors.grey,height:0),
                          ListTile(
                            title: Text('詳細設定',style: TextStyle(fontWeight: FontWeight.bold),),
                            leading: Icon(Icons.settings, color: Theme.of(context).iconTheme.color,),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SettingDetail();
                                  },
                                ),
                              );
                            },
                          ),
                          Divider(color: Colors.grey,height:0),
                          ListTile(
                              leading: Icon(Icons.password, color: Theme.of(context).iconTheme.color,),
                              title: Text('パスワードの有無',style: TextStyle(fontWeight: FontWeight.bold)),
                              trailing: CupertinoSwitch(
                                value: SharedPrefs.getIsPassword(),
                                onChanged: (bool value) {
                                  setState(() {
                                    SharedPrefs.setIsPassword(value);
                                  });
                                },
                              )
                          ),
                          ListTile(
                            title: Container(
                              padding: EdgeInsets.only(top: 10),
                              child: TextField(
                                controller: passwordController,
                                maxLength: 8,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                  // FilteringTextInputFormatter.allow(RegExp(r'[0–9]+'))
                                ],
                                decoration: InputDecoration(
                                  labelText: "パスワード",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (String value) {
                                  SharedPrefs.setPassword(value);
                                },
                              ),
                            )
                          ),
                          Divider(color: Colors.grey,height:0),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context).deleteAllBalancedata,
                                  style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onTap: () {
                                setState(() {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Text(AppLocalizations.of(context).deleteAllDialog),
                                        //content: Text(""),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text(AppLocalizations.of(context).delete),
                                            onPressed: () => allDelete(context),
                                            isDestructiveAction: true,
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(AppLocalizations.of(context).cancel),
                                            onPressed: () => Navigator.of(context).pop(),
                                            isDefaultAction: true,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                            },
                          ),
                          Divider(color: Colors.grey,height:0),
                        ],
                      )
                  ),
                ),
              ],
            ),
        ),
    );
  }

  // void moveToLastScreen(context) {
  //   Navigator.pop(context);
  // }

  Future<void> updateListViewCategory() async{
//全てのDBを取得
     List<Category> _categoryList = await DatabaseHelper().getCategoryList(true);
      setState(() {
        this.categoryList = _categoryList;
      });
  }

  String labelTextCategory(){
    String _labelTextCategory = "";
    for(var i = 0;i < categoryList.length;i++){
      if(i == 0){
        _labelTextCategory = categoryList[i].title ?? '';
      }
    }
    return _labelTextCategory;
  }
//ダイアログ

  Future<void> allDelete(context) async{
      await DatabaseHelper().allDeleteCalendar();
      Navigator.of(context).pop();
  }

//カテゴリーの名前を取得。
  List<Category> categories(value) {
    List<Category> _categories = [];
    if(value){
      for(var i = 0; i < categoryList.length; i++){
        if(categoryList[i].plus == value){
          _categories.add(categoryList[i]);
        }
      }
    }else{
      for(var i = 0; i < categoryList.length; i++){
        if(categoryList[i].plus == value){
          _categories.add(categoryList[i]);
        }
      }
    }
    return _categories;
  }
  String dropDownButton(value){
    String? _id;
    for(var i=0;i<categoryList.length;i++){
      if(categoryList[i].plus == value){
        _id = categoryList[i].id.toString();
      }
    }
    return _id ?? ''; // TODO 間違ってるかも[?? '']
  }
  String labelText(number,value){
    String? _title;
      if(number == ""){
        for(var i = 0; i < categoryList.length; i++){
          if(categoryList[i].plus == value){
            _title= categoryList[i].title;
          }
        }
      }else{
        for(var i = 0 ;i < categoryList.length; i++) {
          if(categoryList[i].id == int.parse(number)){
            _title= categoryList[i].title;
          }
        }
      }
      return _title ?? ''; // TODO 間違ってるかも[?? '']
  }
}
