import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditForm extends StatefulWidget {

  EditForm({Key key, this.selectCalendarList}) : super(key: key);

  final Calendar selectCalendarList;

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<String> _items = ["プラス","マイナス"];
  String _selectedItem = "プラス";

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    _selectedItem = widget.selectCalendarList.money >= 0 ? _items[0]:_items[1];
    numberController = TextEditingController(text: '${widget.selectCalendarList.money * (widget.selectCalendarList.money < 0 ? -1:1 )}');
    titleController = TextEditingController(text: '${widget.selectCalendarList.title}');
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
            actions: <Widget>[
              IconButton(
                onPressed: () {
                    setState(() {
                      _delete(widget.selectCalendarList.id);
                      moveToLastScreen();
                    });
                },
                icon: Icon(Icons.delete),
              ),
            ]
        ),
        body: Container(
          //他の画面をタップすると入力画面が閉じる。
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Padding(
                padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                child: ListView(
                  children: <Widget>[
                    Row(children: btnPlusMinus()),
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
                                labelText: _selectedItem == _items[0] ? "収入":"支出",
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
                                      _save(Calendar.withId(widget.selectCalendarList.id,Utils.toInt(numberController.text)*(_selectedItem == _items[0] ? 1 : -1),'${titleController.text}','${titleController.text}',widget.selectCalendarList.date,0) );
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
  List<Widget> btnPlusMinus(){
    List<Widget> _list = [];
    _items.forEach((value){
      _list.add(Expanded(
        flex: 1,
        child: RaisedButton(
          child: Text(value),
          color: (value == _items[0]? Colors.blue : Colors.red)[100+ (_selectedItem == value ? 300 : 0)],
          textColor: _selectedItem == value ? Colors.white : Colors.grey[400],
          onPressed: () {
            setState(() {
              _selectedItem = value ;
            });
          },
        ),
      ),
      );
    });
    return _list;
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
  Future <void> _delete(int id) async{
    int result;
      result = await databaseHelper.deleteCalendar(id);
    print(result);
  }

}