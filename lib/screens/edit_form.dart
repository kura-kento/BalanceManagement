import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'category_form.dart';

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
  List<Calendar> calendarList = List<Calendar>();

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  List<String> _items = ["プラス","マイナス"];
  String _selectedItem = "プラス";

  List<Category> _categoryItems =[Category.withId(0, "カテゴリー", true)];
  int _selectCategory = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  FixedExtentScrollController scrollController = FixedExtentScrollController();

  @override
  void initState() {
    if(widget.inputMode == InputMode.edit){
      _selectedItem = widget.selectCalendarList.money >= 0 ? _items[0]:_items[1];
      numberController = TextEditingController(text: '${widget.selectCalendarList.money * (widget.selectCalendarList.money < 0 ? -1:1 )}');
      titleController = TextEditingController(text: '${widget.selectCalendarList.title}');
      defaultButton();
    }
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
                dustButton(),
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
                                return StatefulBuilder(
                                  builder: (context, setState1) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xffffffff),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(0xff999999),
                                                width: 0.0,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              CupertinoButton(
                                                child: Text('編集',
                                                  style: TextStyle(
                                                      color: Colors.cyan
                                                  ),
                                                ),
                                                onPressed: () async{
                                                  await Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return CategoryPage(plusOrMinus:_selectedItem == "プラス"? "plus":"minus");
                                                        },
                                                      )
                                                  );
                                                  updateListViewCategory();
                                                  setState1(() {});
                                                },
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 5.0,
                                                ),
                                              ),
                                              CupertinoButton(
                                                child: Text('決定',
                                                      style: TextStyle(
                                                      color: Colors.cyan
                                                      ),
                                                ),
                                                onPressed: () {
                                                  moveToLastScreen();
                                                },
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 5.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: Color(0xffffffff),
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
                                        ),
                                      ],
                                    );
                                  }
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
                                _save();
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

  Future <void> _save() async {

    int result;
    if (widget.inputMode == InputMode.edit) {  // Case 1: Update operation
      result = await databaseHelper.updateCalendar(Calendar.withId(widget.selectCalendarList.id,
                                                                  Utils.toInt(numberController.text)*(_selectedItem == _items[0] ? 1 : -1),
                                                                  '${titleController.text}','${titleController.text}',
                                                                  widget.selectCalendarList.date,
                                                                  _categoryItems[_selectCategory].id)
      );
    } else { // Case 2: Insert Operation
      result = await databaseHelper.insertCalendar(Calendar(Utils.toInt(numberController.text)*(_selectedItem == _items[0]? 1 : -1),
                                                            '${titleController.text}',
                                                            '${titleController.text}',
                                                            widget.selectDay,
                                                            _categoryItems[_selectCategory].id));
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
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 32),
    );
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    this.categoryList = await databaseHelperCategory.getCategoryList(_selectedItem == "プラス");
    List<Category> _categoryItemsCache =[Category.withId(0, "空白", _selectedItem == "プラス")];
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
  Widget dustButton(){
    if(widget.inputMode == InputMode.edit){
      return IconButton(
        onPressed: () {
          _delete(widget.selectCalendarList.id);
          moveToLastScreen();
          setState(() {});
        },
        icon: Icon(Icons.delete),
      );
    }else{
      return SizedBox.shrink();
    }
  }
//編集フォームでドロップダウンの位置決め
  Future<void> defaultButton() async{
      List<Category> _categoryList = await databaseHelperCategory.getCategoryList(_selectedItem == "プラス"? true:false);
      List<int> _category = List<int>();
      _categoryList.forEach((Category category){
        _category.add(category.id);
      });
    _selectCategory = _category.indexOf(widget.selectCalendarList.categoryId)+1;
  }
}