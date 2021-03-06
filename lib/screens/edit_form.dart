import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/admob.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_store_listing/flutter_store_listing.dart';
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

  MoneyValue moneyValue = MoneyValue.income;

  List<Category> _categoryItems =[Category.withId(0, "カテゴリー", true)];
  int _selectCategory = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  FixedExtentScrollController scrollController = FixedExtentScrollController();

  @override
  void initState() {
    if(widget.inputMode == InputMode.edit){
      moneyValue = widget.selectCalendarList.money >= 0 ? MoneyValue.income:MoneyValue.spending;
      numberController = TextEditingController(text: '${widget.selectCalendarList.money * (widget.selectCalendarList.money < 0 ? -1:1 )}');
      titleController = TextEditingController(text: '${widget.selectCalendarList.title}');
      memoController = TextEditingController(text: '${widget.selectCalendarList.memo}');
      defaultButton();
    }
    updateListViewCategory();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //ここに入れてもいいのか？
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Container(
      color: Colors.grey[300],
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
            body: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: AdMob.banner(),
                    ),
                    Container(
                      color: Colors.grey[300],
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IconButton(icon: Icon(
                                Icons.arrow_back),
                              onPressed: () => moveToLastScreen(),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(widget.inputMode == InputMode.edit ? "編集フォーム" : "新規追加フォーム")),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
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
                                                                        return CategoryPage(moneyValue: moneyValue);
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
                                                                style: TextStyle(color: Colors.cyan),
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
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                          )
                                      )
                                  )
                                ],
                                ),
                                Row(children: <Widget>[
                                  expandedNull(1),
                                  Expanded(
                                    flex: 2,
                                    child:Padding(
                                        padding: EdgeInsets.only(top:15,bottom:15),
                                        child:TextFormField(
                                          //autofocus: true,
                                            controller: numberController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              WhitelistingTextInputFormatter.digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                                labelText: moneyValue == MoneyValue.income ? "収入":"支出",
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
                                ),
                                TextField(
                                  controller: memoController,
                                  minLines: 5,
                                  maxLength: 1000,
                                  decoration: InputDecoration(
                                    labelText: 'メモ',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0)
                                    ),
                                  ),
                                  maxLines: null,
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
  List<Widget> btnPlusMinus(){
    List<Widget> _list = [];
    [MoneyValue.income,MoneyValue.spending].asMap().forEach((index,element) {
      _list.add(
        Expanded(
          flex: 1,
          child: RaisedButton(
            child: Text(index == 0 ? "プラス" : "マイナス"),
            color: (index == 0 ? Colors.blue:Colors.red)[100 + (moneyValue == element ? 300:0)],
            textColor: moneyValue == element ? Colors.white : Colors.grey[400],
            onPressed: () {
              moneyValue = element;
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
   moveToLastScreen() async{
    FocusScope.of(context).unfocus();
    await new Future.delayed(new Duration(microseconds: 3000));
    Navigator.pop(context);
  }

  Future <void> _save() async {
    if (widget.inputMode == InputMode.edit) {  // Case 1: Update operation
      await databaseHelper.updateCalendar(Calendar.withId(widget.selectCalendarList.id,
                                                                  Utils.toInt(numberController.text)*(moneyValue == MoneyValue.income ? 1 : -1),
                                                                  '${titleController.text}',
                                                                  '${memoController.text}',
                                                                  widget.selectCalendarList.date,
                                                                  _categoryItems[_selectCategory].id)
      );
    } else { // Case 2: Insert Operation
      await databaseHelper.insertCalendar(Calendar(Utils.toInt(numberController.text)*(moneyValue == MoneyValue.income ? 1 : -1),
                                                            '${titleController.text}',
                                                            '${memoController.text}',
                                                            widget.selectDay,
                                                            _categoryItems[_selectCategory].id));
    }
  }
  Future <void> _delete(int id) async{
    await databaseHelper.deleteCalendar(id);
  }
  Widget _pickerItem(Category category) {
    return Center(
      child: Text(
        category.title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 32),
      ),
    );
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    this.categoryList = await databaseHelperCategory.getCategoryList(moneyValue == MoneyValue.income);
    List<Category> _categoryItemsCache =[Category.withId(0, "空白", moneyValue == MoneyValue.income)];
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
      List<Category> _categoryList = await databaseHelperCategory.getCategoryList(moneyValue == MoneyValue.income ? true:false);
      List<int> _category = List<int>();
      _categoryList.forEach((Category category){
        _category.add(category.id);
      });
    _selectCategory = _category.indexOf(widget.selectCalendarList.categoryId)+1;
  }
}