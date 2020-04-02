import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class CreateForm extends StatefulWidget {

  CreateForm({Key key, this.selectDay}) : super(key: key);
  final DateTime selectDay;

  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {

  static var _fluctuation = ['プラス','マイナス'];

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  DatabaseHelper databaseHelper = DatabaseHelper();


  List<Calendar> calendarList = List<Calendar>();

  @override
  void initState() {
    updateListView();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
          appBar: AppBar(
            title: Text("新規追加フォーム"),
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
                      title: DropdownButton(
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
                                      _save(Calendar(Utils.toInt(numberController.text),'${titleController.text}','${titleController.text}',widget.selectDay) );
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


//作成フォーム（削除予定）
class CreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("追加フォーム"),
          bottom: TabBar(
            tabs: <Widget>[Tab(text: "プラス"), Tab(text: "マイナス")],
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Container(
            color: Colors.white,
          ),
        ]),
      ),
    );
  }
}