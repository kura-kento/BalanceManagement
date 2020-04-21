import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
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

  List<Category> _categoryItems =[Category.withId(0, "カテゴリー", true)];
  int _selectCategory = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  FixedExtentScrollController scrollController = FixedExtentScrollController();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  @override
  void initState() {
    updateListViewCategory();
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
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Padding(
                padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                child: Column(
                  children: <Widget>[
                    Row( children: btnPlusMinus(), ),
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
                            )
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
                          ),
                        ),
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
                          )
                        )
                      ],
                    ),
                    Padding(
                        padding:EdgeInsets.only(top:20.0,bottom:15.0),
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Center(
                            child: Text(
                              '保存',
                              textScaleFactor: 1.5,
                            ),
                          ),
                          onPressed: (){
                            setState(() {
                              _save(Calendar(Utils.toInt(numberController.text)*(_selectedItem == _items[0]? 1 : -1),'${titleController.text}','${titleController.text}',widget.selectDay,_categoryItems[_selectCategory].id) );
                              moveToLastScreen();
                            });
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
              _selectedItem = value;
              updateListViewCategory();
              _selectCategory = 0;
              setState(() { });
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
   // print(result);
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

  //空白
  Widget expandedNull(value){
    return Expanded(
        flex: value,
        child:Container(
          child:Text(""),
        )
    );
  }

  Future <String> categoryTitle(value)async{
    Category _categoryList = await databaseHelperCategory.getCategoryId(value);
    return _categoryList.title;
  }

}


