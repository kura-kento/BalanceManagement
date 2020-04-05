import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum Answers{
  YES,
  NO
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

  TextEditingController titleController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  String _selectCategory = "購入";

  String _value = '';

  void _setValue(String value) => setState(() => _value = value);

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
            leading: IconButton(icon: Icon(
                Icons.arrow_back),
              onPressed: () => moveToLastScreen(),
            ),
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Padding(
                padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                child: Column(
                  children: <Widget>[
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
                            Text("カテゴリー編集"),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: DropdownButton<String>(
                                    value: _selectCategory,
                                    onChanged: (String newValue){
                                      setState(() {
                                        _selectCategory = newValue;
                                      });
                                    },
                                    selectedItemBuilder: (context){
                                      return categories(true).map((String title){
                                        return Text(
                                          title,
                                        );
                                      }).toList();
                                    },
                                    items: categories(true).map((title){
                                      return DropdownMenuItem(
                                        value: title,
                                        child:Text(title),
                                      );
                                    }).toList(),
                                  )
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: titleController,
                                    style: textStyle,
                                    onChanged: (value){
                                      debugPrint('Something changed in Title Text Field');
                                    },
                                    decoration: InputDecoration(
                                        labelText: _selectCategory,
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
                                  onChanged: (value){
                                    debugPrint('Something changed in Title Text Field');
                                  },
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
                              '全てのデータ削除',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                openDialog(context);
                                //_save(Calendar.withId(widget.selectCalendarList.id,Utils.toInt(numberController.text)*(_selectedItem == _items[0] ? 1 : -1),'${titleController.text}','${titleController.text}',widget.selectCalendarList.date) );
                              });
                            },
                          )
                      ),
                  ],
                )
            ),
          ),

        floatingActionButton: FloatingActionButton(
          onPressed: (){
            setState(() {
              _save(Category("その他",true));
            });
          },
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

  Future <void> _save(Category category) async {
    int result;
    if (category.id != null) {  // Case 1: Update operation
      result = await databaseHelperCategory.updateCategory(category);
    } else { // Case 2: Insert Operation
      result = await databaseHelperCategory.insertCategory(category);
    }
    print(result);
  }

  Future<void> updateListViewCategory() async{
//全てのDBを取得
     List<Category> _categoryList = await databaseHelperCategory.getCategoryList();
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

  void openDialog(BuildContext context) {
    showDialog<Answers>(
      context: context,
      builder: (BuildContext context) => new SimpleDialog(
        title: new Text('全ての収支データを消しますか？'),
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              flex: 1,
              child: createDialogOption(context, Answers.YES, 'はい'),
            ),
            Expanded(
              flex: 1,
              child: createDialogOption(context, Answers.NO, 'いいえ'),
            )
            ]
          )
        ],
      ),
    ).then((value) {
      switch(value) {
        case Answers.YES:
          _setValue('はい');
          break;
        case Answers.NO:
          _setValue('いいえ');
          break;
      }
    });
  }

  createDialogOption(BuildContext context, Answers answer, String str) {
    return SimpleDialogOption(child: Text(str),onPressed: (){
      if(str == "はい"){
        for(var i = 0; i < calendarList.length; i++){
          _delete(calendarList[i].id);
        }
      }
      Navigator.pop(context, answer);
      },);
  }

  Future <void> _delete(int id) async{
    int result;
    result = await databaseHelper.deleteCalendar(id);
    print(result);
  }

  List<String> categories(value){
    List<String> _categories = List<String>();
    for(var i=0;i<categoryList.length;i++){
      if(value){
        _categories.add(categoryList[i].title);
      }
    }
    return _categories;
  }
}
