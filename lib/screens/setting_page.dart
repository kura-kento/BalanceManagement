import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'category_form.dart';

class SettingPage extends StatefulWidget {

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

  TextEditingController unitController = TextEditingController();

  @override
  void initState(){
    updateListView();
    updateListViewCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //ここに入れてもいいのか？
    TextStyle textStyle = Theme.of(context).textTheme.title;

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
                      child: Text("設定", style: TextStyle(fontSize: 20,color: Colors.black)),
                    )
                ),
                SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            child: Center(child: Text(
                              "カテゴリー編集（プラス）",
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
                                "カテゴリー編集（マイナス）",
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
                                Text("単位編集"),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text("  単位：",
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
                                        style: textStyle,
                                        decoration: InputDecoration(
                                            labelText: '${SharedPrefs.getUnit()}',
                                            labelStyle: textStyle,
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
                                            },child: Center(child: Text("更新")),
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
                                '収支データの全削除',
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
                                    title: Text("全ての収支データを消しますか？"),
                                    //content: Text(""),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: Text("削除"),
                                        onPressed: () =>
                                            allDelete(),
                                        isDestructiveAction: true,
                                      ),
                                      CupertinoDialogAction(
                                        child: Text("キャンセル"),
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
              ],

            ),
          ),
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
  void updateListView() {
//全てのDBを取得
    Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
    calendarListFuture.then((calendarList) {
      setState(() {
        this.calendarList = calendarList;
      });
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

  void allDelete(){
    for(var i = 0; i < calendarList.length; i++){
      _delete(calendarList[i].id);
    }
    Navigator.of(context).pop();
  }

  Future <void> _delete(int id) async{
    int result;
    result = await databaseHelper.deleteCalendar(id);
  }
//カテゴリーの名前を取得。
  List<Category> categories(value){
    List<Category> _categories = List<Category>();
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
