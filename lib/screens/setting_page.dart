import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/admob.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/widget/reward_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'category_form.dart';

class SettingPage extends StatefulWidget {

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final BannerAd myBanner = AdMob.admobBanner();
  final BannerAd myBanner2 = AdMob.admobBanner2();
  DatabaseHelper databaseHelper = DatabaseHelper();
  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = <Category>[];
  TextEditingController unitController = TextEditingController();
  TextEditingController passwordController = TextEditingController(text: SharedPrefs.getPassword());

  RewardedAd _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  @override
  void initState(){
    updateListViewCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    myBanner.load();
    myBanner2.load();

    return Column(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SharedPrefs.getAdPositionTop()
              ? AdMob.adContainer(myBanner)
              : Container(),
        ),
        Expanded(
          child: Scaffold(
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
                                ListTile(
                                    title: Text('パスワードの有無'),
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
                                      onChanged: (String value){
                                        SharedPrefs.setPassword(value);
                                      },
                                    ),
                                  )
                                ),
                                Divider(color: Colors.grey,height:0),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.all(15.0),
                                    child: Center(child: Text(
                                      AppLocalizations.of(context).addPosition + "（" + (SharedPrefs.getAdPositionTop() ? AppLocalizations.of(context).bottom:AppLocalizations.of(context).top) + "${AppLocalizations.of(context).changeTo}）",
                                      textAlign: TextAlign.center,
                                      textScaleFactor: 1.5,
                                    )),
                                  ) ,
                                  onTap: (){
                                    setState(() {
                                      SharedPrefs.setAdPositionTop(!SharedPrefs.getAdPositionTop());
                                    });
                                  },
                                ),
                                Divider(color: Colors.grey,height:0),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.all(15.0),
                                    child: Center(child: Text(
                                      "${AppLocalizations.of(context).categoryEditing}（${AppLocalizations.of(context).plus}）",
                                      textScaleFactor: 1.5,
                                    )),
                                  ) ,
                                  onTap: (){
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CategoryPage(moneyValue: MoneyValue.income);
                                        },
                                      ),
                                    );
                                  },
                                ),
                                Divider(color: Colors.grey,height:0),
                                InkWell(
                                  child: Container(
                                      padding: EdgeInsets.all(15.0),
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(child: Text(
                                        "${AppLocalizations.of(context).categoryEditing}（${AppLocalizations.of(context).minus}）",
                                        textScaleFactor: 1.5,
                                      ))
                                  ),
                                  onTap: (){
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CategoryPage(moneyValue: MoneyValue.spending,);
                                        },
                                      ),
                                    );
                                  },
                                ),
                                Divider(color: Colors.grey,height:0),
                                Padding(
                                    padding: EdgeInsets.only(top:5,bottom:5),
                                    child:Column(
                                      children: <Widget>[
                                        Text("${AppLocalizations.of(context).unit}${AppLocalizations.of(context).edit}"),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Text("${AppLocalizations.of(context).unit}：",
                                                textAlign: TextAlign.center,
                                                textScaleFactor: 1.5,
                                              ),
                                            ),
                                            Expanded(
                                              flex:2,
                                              child: TextField(
                                                onTap: (){
                                                  unitController.text = SharedPrefs.getUnit();
                                                },
                                                controller: unitController,
                                                decoration: InputDecoration(
                                                    labelText: '${SharedPrefs.getUnit()}',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0)
                                                    )
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: FlatButton(
                                                    color: Colors.grey[400],
                                                    onPressed: (){
                                                      setState(() {
                                                        SharedPrefs.setUnit("${unitController.text}");
                                                        FocusScope.of(context).unfocus();
                                                      });
                                                    },
                                                    child: Center(
                                                      child: AutoSizeText(
                                                        AppLocalizations.of(context).update,
                                                        minFontSize: 4,
                                                        maxLines: 1,
                                                        style: TextStyle(fontSize: 25),
                                                      )
                                                    ),
                                                  ),
                                                )
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                Padding(
                                  padding:EdgeInsets.only(top:10.0),
                                ),
                                Divider(color: Colors.grey,height:0),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.all(15.0),
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context).deleteAllBalancedata,
                                        textScaleFactor: 1.5,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (BuildContext context)
                                        {
                                          return CupertinoAlertDialog(
                                            title: Text(AppLocalizations.of(context).deleteAllDialog),
                                            //content: Text(""),
                                            actions: <Widget>[
                                              CupertinoDialogAction(
                                                child: Text(AppLocalizations.of(context).delete),
                                                onPressed: () =>
                                                    allDelete(),
                                                isDestructiveAction: true,
                                              ),
                                              CupertinoDialogAction(
                                                child: Text(AppLocalizations.of(context).cancel),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
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
          ),
        ),
        SharedPrefs.getAdPositionTop()
            ? Container()
            : AdMob.adContainer(myBanner2),
      ],
    );
  }
  void moveToLastScreen(){
    Navigator.pop(context);
  }

  Widget expandedNull(value){
    return Expanded(
        flex: value,
        child:Container(
          child:Text(""),
        )
    );
  }

  Future<void> updateListViewCategory() async{
//全てのDBを取得
     List<Category> _categoryList = await databaseHelperCategory.getCategoryList(true);
      setState(() {
        this.categoryList = _categoryList;
      });
  }

  String labelTextCategory(){
    String _labelTextCategory = "";
    for(var i = 0;i < categoryList.length;i++){
      if(i == 0){
        _labelTextCategory = categoryList[i].title;
      }
    }
    return _labelTextCategory;
  }
//ダイアログ

  Future<void> allDelete() async{
      await databaseHelper.allDeleteCalendar();
      Navigator.of(context).pop();
  }

//カテゴリーの名前を取得。
  List<Category> categories(value){
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
    String _id;
    for(var i=0;i<categoryList.length;i++){
      if(categoryList[i].plus == value){
        _id = categoryList[i].id.toString();
      }
    }
    return _id;
  }
  String labelText(number,value){
    String _title;
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
      return _title;
  }
}
