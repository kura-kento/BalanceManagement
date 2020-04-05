import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateForm extends StatefulWidget {

  CreateForm({Key key, this.selectDay}) : super(key: key);
  final DateTime selectDay;

  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {

  List<String> _items = ["プラス","マイナス"];
  String _selectedItem = "プラス" ;

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

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
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Padding(
                padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                child: ListView(
                  children: <Widget>[
                    Row( children: btnPlusMinus(), ),
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
                                      _save(Calendar(Utils.toInt(numberController.text)*(_selectedItem == _items[0]? 1 : -1),'${titleController.text}','${titleController.text}',widget.selectDay) );
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

}