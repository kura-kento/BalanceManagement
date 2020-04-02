import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class EditForm extends StatefulWidget {

  EditForm({Key key, this.selectCalendarList}) : super(key: key);

  final Calendar selectCalendarList;

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<String> _items = ["プラス","マイナス"];
  String _selectedItem = "プラス" ;

  List<Calendar> calendarList = List<Calendar>();

  @override
  void initState() {
    updateListView();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //ここに入れてもいいのか？
    TextEditingController titleController = TextEditingController(text: '${widget.selectCalendarList.title}');
    TextEditingController numberController = TextEditingController(text: '${widget.selectCalendarList.money}');

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
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      title: DropdownButton<String>(
                        value: _selectedItem,
                        onChanged: (String newValue){
                          setState(() {
                            _selectedItem = newValue;
                          });
                        },
                        selectedItemBuilder: (context){
                          return _items.map((String item) {
                            return Text(
                              item,
                              style: TextStyle(color: Colors.pink),
                            );
                          }).toList();
                        },
                        items: _items.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: item == _selectedItem
                                  ? TextStyle(fontWeight: FontWeight.bold)
                                  : TextStyle(fontWeight: FontWeight.normal),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top:15,bottom:15),
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
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(top:15,bottom:15),
                        child:TextFormField(
                            controller: numberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                                labelText: '収支',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)
                                )
                            )
                        )
                    ),
                    Padding(
                        padding:EdgeInsets.only(top:15.0,bottom:15.0),
                        child:Row(
                          children: <Widget>[
                            Expanded(
                                child: RaisedButton(
                                  color: Theme.of(context).primaryColorDark,
                                  textColor: Theme.of(context).primaryColorLight,
                                  child: Text(
                                    'キャンセル',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      //debugPrint("Delete button clicked");
                                      moveToLastScreen();
                                    });
                                  },
                                )
                            ),
                            Container(width:5.0),

                            Expanded(
                                child: RaisedButton(
                                  color: Theme.of(context).primaryColorDark,
                                  textColor: Theme.of(context).primaryColorLight,
                                  child: Text(
                                    '保存',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      //debugPrint("Save button clicked");
                                      _save(Calendar.withId(widget.selectCalendarList.id,Utils.toInt(numberController.text),'${titleController.text}','${titleController.text}',widget.selectCalendarList.date) );
                                      updateListView();
                                      moveToLastScreen();
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
        )
    );
  }

  void moveToLastScreen(){
    Navigator.pop(context);
  }

  Future <void> _save(Calendar calendar) async {
    int result;
    if (calendar.id != null) {  // Case 1: Update operation
      result = await databaseHelper.updateCalendar(calendar);
    } else { // Case 2: Insert Operation
      result = await databaseHelper.insertCalendar(calendar);
    }
    print(result);
  }

  void updateListView() {
//データベースと接続するパスを取得する（起動時１回のみ処理）
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
//全てのDBを取得
      Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
      calendarListFuture.then((calendarList) {
        setState(() {
          this.calendarList = calendarList;
        });
      });
    });
  }
}
/*
DropdownButton(
items: _fluctuation.map((String dropDownStirngItem){
return DropdownMenuItem<String>(
value: dropDownStirngItem,
child: Text(dropDownStirngItem),
);
}).toList(),
style: textStyle,
value: 'プラス',
onChanged: (valueSelectedByUser){
debugPrint('User selected $valueSelectedByUser');
}
),

 */