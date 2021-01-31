import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:flutter/material.dart';

enum MoneyValue{
  income,
  spending
}

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key,this.moneyValue}) : super(key: key);
  final MoneyValue moneyValue;

@override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  List<TextEditingController> titleControllerList = List<TextEditingController>();

  @override
  void initState() {
    updateListViewCategory(widget.moneyValue == MoneyValue.income);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).categoryEditing),
      ),
      body:  Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),

            child: categoryListWidget()
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryListWidget(){
    List<Widget> _list = [];
    for (int i = 0; i < categoryList.length; i++) {
      _list.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onTap: (){
                    titleControllerList[i].text = categoryList[i].title;
                  },
                  controller: titleControllerList[i],
                  //style: textStyle,
                  decoration: InputDecoration(
                      labelText: categoryList[i].title,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    padding: EdgeInsets.all(20.0),
                    color: Colors.grey[400],
                    onPressed: () async{
                        _update(categoryList[i].id,titleControllerList[i].text, widget.moneyValue);
                        this.categoryList = await databaseHelperCategory.getCategoryList( widget.moneyValue == MoneyValue.income);
                        setState(() {});
                    },
                    child: Center(
                      child: AutoSizeText(
                        AppLocalizations.of(context).update,
                        minFontSize: 4,
                        maxLines: 1,
                        style: TextStyle(fontSize: 25),
                      )
                    ),
                  ),
                )
            ),
          ],
        ),
      );
    }

    return (titleControllerList.length==0) ? Container() : SingleChildScrollView(
      child: Column(children: _list),
    );
  }

  Future<void> updateListViewCategory(value) async{
//収支どちらか全てのDBを取得
      this.categoryList = await databaseHelperCategory.getCategoryList(value);
      List<TextEditingController> _controllerList = List<TextEditingController>();
      for(int i=0;i < categoryList.length;i++){
        if(categoryList[i].plus == value){
          _controllerList.add(TextEditingController());
        }
      }
      titleControllerList = _controllerList;
    setState(() {});
  }
  //アップデート
  Future <void> _update(beforeId,after,value) async {
    int _id;
    //削除予定
    for(var i=0;i<categoryList.length;i++) {
      if (categoryList[i].id == beforeId){
        _id = categoryList[i].id;
        break;
      }
    }
    await databaseHelperCategory.updateCategory(Category.withId(_id,after,(value == MoneyValue.income)));
    print(_id);
  }
}

