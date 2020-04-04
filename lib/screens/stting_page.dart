import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  List<String> _categories = ["購入","売上"];
  String _selectCategory = "購入";

  var _labelText = 'Select Date';
  DateTime _date = new DateTime.now();

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
        body: Container(
          //他の画面をタップすると入力画面が閉じる。
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
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
                        child: Row(
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
                                  return _categories.map((String category){
                                    return Text(
                                      category,
                                    );
                                  }).toList();
                                },
                                items: _categories.map((category){
                                  return DropdownMenuItem(
                                    value: category,
                                    child:Text(
                                      category
                                    ),
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
                                    labelText: 'タイトル',
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

                                    });
                                  },child: Text("更新"),
                                ),
                              )
                            )

                          ],
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(top:15,bottom:15),
                        child:Row(
                          children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text("単位",
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
                        )
                    ),
                    Padding(
                      padding:EdgeInsets.only(top:15.0,bottom:15.0),
                    ),
                    Padding(
                        padding:EdgeInsets.only(top:15.0,bottom:15.0),
                        child:Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: <Widget>[
                                  DropdownButton<String>(
                                    value: _selectCategory,
                                    onChanged: (String newValue){
                                      setState(() {
                                        _selectCategory = newValue;
                                      });
                                    },
                                    selectedItemBuilder: (context){
                                      return _categories.map((String category){
                                        return Text(
                                          category,
                                        );
                                      }).toList();
                                    },
                                    items: _categories.map((category){
                                      return DropdownMenuItem(
                                        value: category,
                                        child:Text(
                                            category
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  DropdownButton<String>(
                                    value: _selectCategory,
                                    onChanged: (String newValue){
                                      setState(() {
                                        _selectCategory = newValue;
                                      });
                                    },
                                    selectedItemBuilder: (context){
                                      return _categories.map((String category){
                                        return Text(
                                          category,
                                        );
                                      }).toList();
                                    },
                                    items: _categories.map((category){
                                      return DropdownMenuItem(
                                        value: category,
                                        child:Text(
                                            category
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                ],
                              )
                            ),
                            Expanded(
                              flex: 1,
                                child: RaisedButton(
                                  color: Theme.of(context).primaryColorDark,
                                  textColor: Theme.of(context).primaryColorLight,
                                  child: Text(
                                    'データ削除',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      //debugPrint("Save button clicked");
                                      //_save(Calendar.withId(widget.selectCalendarList.id,Utils.toInt(numberController.text)*(_selectedItem == _items[0] ? 1 : -1),'${titleController.text}','${titleController.text}',widget.selectCalendarList.date) );
                                      _selectDate(context);
                                    });
                                  },
                                )
                            ),
                          ],
                        )
                    )
                  ],
                )
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: (){
      setState(() {
        SharedPrefs.setUnit("円");
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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360))
    );
    if(picked != null) setState(() => _date = picked);
  }
}
