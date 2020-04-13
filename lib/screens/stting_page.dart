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

  TextEditingController incomeTitleController = TextEditingController();
  TextEditingController spendingTitleController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  String _selectCategoryIncome = "";
  String _selectCategorySpending = "";


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
        appBar: AppBar(
            title: Text("編集フォーム"),
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: FlatButton(
                          child: Text("カテゴリー編集（収入）"),
                          onPressed: (){
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CategoryPage(plusOrMinus:"plus");
                                  },
                                ),
                            );
                          },
                        ),
                      ),
                      Row(children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top:15,bottom:15),
                          )
                      ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(top:15,bottom:15),
                          child: Column(
                            children: <Widget>[
                              Text("カテゴリー編集(収入)"),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: DropdownButton<String>(
                                      value: dropDownButton(true),
                                      onChanged: (String newValue){
                                        setState(() {
                                          _selectCategoryIncome = newValue;
                                        });
                                      },
                                      //閉じているとき
                                      selectedItemBuilder: (context){
                                          return categories(true).map((Category category){
                                          return Text("選択");
                                        }).toList();
                                      },
                                      //開いている時
                                      items: categories(true).map((Category category){
                                        //ドロップダウンボタンの押したときのデータ（value）表示（text）
                                        return DropdownMenuItem(
                                          value: category.id.toString(),
                                          child:Text(category.title),
                                        );
                                      }).toList(),
                                    )
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: incomeTitleController,
                                      style: textStyle,
                                      decoration: InputDecoration(
                                          labelText: labelText(_selectCategoryIncome,true),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0)
                                          )
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: FlatButton(
                                        padding: EdgeInsets.all(20.0),
                                        color: Colors.grey[400],
                                        onPressed: (){
                                          setState(() {
                                            _update(_selectCategoryIncome,incomeTitleController.text,true);
                                          });
                                        },child: Text("更新"),
                                      ),
                                    )
                                  )
                                ],
                              ),
                              Text("カテゴリー編集(支出)"),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      flex: 1,
                                      child: DropdownButton<String>(
                                        value: dropDownButton(false),
                                        onChanged: (String newValue){
                                          setState(() {
                                            _selectCategorySpending = newValue;
                                          });
                                        },
                                        selectedItemBuilder: (context){
                                          return categories(false).map((Category category){
                                            return Text("選択");
                                          }).toList();
                                        },
                                        items: categories(false).map((Category category){
                                          return DropdownMenuItem(
                                            value: category.id.toString(),
                                            child:Text(category.title),
                                          );
                                        }).toList(),
                                      )
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: spendingTitleController,
                                      style: textStyle,
                                      decoration: InputDecoration(
                                          labelText: labelText(_selectCategorySpending,false),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0)
                                          )
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: FlatButton(
                                          padding: EdgeInsets.all(20.0),
                                          color: Colors.grey[400],
                                          onPressed: (){
                                            setState(() {
                                              _update(_selectCategorySpending,spendingTitleController.text,false);
                                            });
                                          },child: Text("更新"),
                                        ),
                                      )
                                  )
                                ],
                              ),
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(top:15,bottom:15),
                          child:Column(
                            children: <Widget>[
                              Text("単位編集"),
                              Row(
                                children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text("単位：",
                                    style: TextStyle(fontSize: 20,),
                                  ),
                                ),
                                Expanded(
                                  flex:2,
                                  child: TextField(
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
                                        padding: EdgeInsets.all(20.0),
                                        color: Colors.grey[400],
                                        onPressed: (){
                                          setState(() {
                                            SharedPrefs.setUnit("${unitController.text}");
                                          });
                                        },child: Text("更新"),
                                      ),
                                    )
                                )
                                ],
                              ),
                            ],
                          )
                      ),
                      Padding(
                        padding:EdgeInsets.only(top:15.0,bottom:15.0),
                      ),
                      Padding(
                          padding:EdgeInsets.only(top:15.0,bottom:15.0),
                            child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                '収支データの全削除',
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
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
                            )
                        ),
                    ],
                  )
              ),
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

  Future <void> _update(before,after,value) async {
    int _id;
    //削除予定
    for(var i=0;i<categoryList.length;i++) {
      if (categoryList[i].id == int.parse(before)){
        _id = categoryList[i].id;
        break;
      }
    }
    await databaseHelperCategory.updateCategory(Category.withId(_id,after,value));
    print(_id);
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
    print(result);
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
