import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/screens/other/price_style.dart';
import 'package:balancemanagement_app/screens/other/setting_detail.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/widget/daialog_select.dart';
import 'package:balancemanagement_app/widget/reward_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import '../../utils/app.dart';

class SettingPage extends StatefulWidget {

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<Category> categoryList = <Category>[];
  TextEditingController passwordController = TextEditingController(text: SharedPrefs.getPassword());
  Widget dividerWidget = Divider(color: Colors.grey[300], height:0);
  TextEditingController unitController = TextEditingController(text: SharedPrefs.getUnit());
  @override
  void initState() {
    updateListViewCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Container(
                height: 55,
                width: MediaQuery.of(context).size.width,
                color: App.bgColor,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(AppLocalizations.of(context).setting, style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold,)),
                )
            ),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      RewardWidget(),
                      dividerWidget,
                      SelectDialog(),
                      dividerWidget,
                      ListTile(
                        title: const Text('金額の色',style: TextStyle(fontWeight: FontWeight.bold),),
                        leading: const Icon(Icons.color_lens_outlined),
                        onTap: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const PriceStyle();
                              },
                            ),
                          );
                        },
                      ),
                      dividerWidget,
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
                        title: TextField(
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
                        )
                      ),
                      dividerWidget,
                      ListTile(
                          leading: Icon(Icons.text_format, color: Theme.of(context).iconTheme.color,),
                          title: Text("単位を変更",style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              foregroundColor: Colors.black,
                              backgroundColor: App.NoAdsButtonColor, //ボタンの背景色
                            ),
                            onPressed: () {
                              setState(() {
                                SharedPrefs.setUnit("${unitController.text}");
                                FocusScope.of(context).unfocus();
                              });
                            },
                            child: AutoSizeText(
                              AppLocalizations.of(context).update,
                              minFontSize: 4,
                              maxLines: 1,
                              textScaleFactor: 1.5,
                              style: TextStyle(fontSize: App.BTNfontsize),
                            ),
                          ),
                      ),
                      ListTile(
                          title: TextField(
                            controller: unitController,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).unit,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)
                                )
                            ),
                          )
                      ),
                      dividerWidget,
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
                      dividerWidget,
                    ],
                  )
              ),
            ),
          ],
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
