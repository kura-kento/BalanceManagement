import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputMode{
  create,
  edit
}

class EditForm extends StatefulWidget {

  EditForm({Key key, this.selectCalendarList, this.inputMode,this.selectDay}) : super(key: key);

  final DateTime selectDay;
  final Calendar selectCalendarList;
  final InputMode inputMode;

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<String> _items = ["プラス","マイナス"];
  String _selectedItem = "プラス";

  List<Category> _categoryItems =[Category.withId(0, "カテゴリー", true)];
  int _selectCategory = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  @override
  void initState() {
    _selectedItem = widget.selectCalendarList.money >= 0 ? _items[0]:_items[1];
    numberController = TextEditingController(text: '${widget.selectCalendarList.money * (widget.selectCalendarList.money < 0 ? -1:1 )}');
    titleController = TextEditingController(text: '${widget.selectCalendarList.title}');
    updateListViewCategory();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //ここに入れてもいいのか？
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.inputMode == InputMode.edit ? "編集フォーム" : "新規追加フォーム"),
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
                    Row(children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          child:Row(children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(_categoryItems[_selectCategory].title),
                            ),
                            Expanded(
                              flex: 1,
                              child:Text("＞"),
                            )
                          ],

                          ),
                          onPressed: (){
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(context).size.height / 3,
                                  child: CupertinoPicker(
                                      scrollController: FixedExtentScrollController(
                                          initialItem: _selectCategory
                                      ) ,
                                      diameterRatio: 1.0,
                                      itemExtent: 40.0,
                                      children: _categoryItems.map(_pickerItem).toList(),
                                      onSelectedItemChanged: (int index){
                                        setState(() {
                                          _selectCategory = index;
                                        });
                                      }
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child:Padding(
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
                        )
                      )
,
                      ],
                    ),
                    Row(children: <Widget>[
                      expandedNull(1),
                      Expanded(
                        flex: 2,
                        child:Padding(
                            padding: EdgeInsets.only(top:15,bottom:15),
                            child:TextFormField(
                                autofocus: true,
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
                      )
                      ],
                    ),
                    Padding(
                        padding:EdgeInsets.only(top:15.0,bottom:15.0),
                          child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              '保存',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: (){

                                _save(Calendar.withId(widget.selectCalendarList.id,Utils.toInt(numberController.text)*(_selectedItem == _items[0] ? 1 : -1),'${titleController.text}','${titleController.text}',widget.selectCalendarList.date,_categoryItems[_selectCategory].id) ,context);
                                moveToLastScreen();
                                setState(() {});
                            },
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
              _selectedItem = value ;
              updateListViewCategory();
              _selectCategory = 0;
              setState(() {});
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

  Future <void> _save(Calendar calendar ,BuildContext context1) async {
    if(calendar.title.length > 30){
      print("桁数が");
    }

    int result;
    if (calendar.id != null) {  // Case 1: Update operation
      result = await databaseHelper.updateCalendar(calendar);
    } else { // Case 2: Insert Operation
      result = await databaseHelper.insertCalendar(calendar);
    }
    //print(result);
  }
  Future <void> _delete(int id) async{
    int result;
      result = await databaseHelper.deleteCalendar(id);
    //print(result);
  }
  Widget _pickerItem(Category category) {
    return Text(
      category.title,
      style: const TextStyle(fontSize: 32),
    );
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    List<Category> _categoryList = await databaseHelperCategory.getCategoryList(_selectedItem == "プラス"? true:false);
    this.categoryList = _categoryList;
    List<Category> _categoryItemsCache =[Category.withId(0, "空白", _selectedItem == "プラス"? true:false)];
    for(int i=0;i<categoryList.length;i++){
      _categoryItemsCache.add(categoryList[i]);
    }
    _categoryItems= _categoryItemsCache;
    setState(() {});
  }
  Widget expandedNull(value){
    return Expanded(
        flex: value,
        child:Container(
          child:Text(""),
        )
    );
  }

}