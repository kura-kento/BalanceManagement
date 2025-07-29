import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:flutter/material.dart';

import '../../models/DB/database_help.dart';

enum MoneyValue{
  income,
  spending
}

class CategoryPage extends StatefulWidget {
  CategoryPage({Key? key,required this.moneyValue}) : super(key: key);
  final MoneyValue moneyValue;

@override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> categoryList = [];
  List<TextEditingController> titleControllerList = [];

  @override
  void initState() {
    updateListViewCategory(widget.moneyValue == MoneyValue.income);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).categoryEditing),
        ),
        body:  Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: categoryListWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryListWidget() {
    List<Widget> _list = [];
    for (int i = 0; i < categoryList.length; i++) {
      _list.add(
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onTap: () {
                    titleControllerList[i].text = categoryList[i].title ?? '';
                  },
                  controller: titleControllerList[i],
                  decoration: InputDecoration(
                      labelText: categoryList[i].title,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.grey[400],
              ),
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                _update(categoryList[i].id,titleControllerList[i].text, widget.moneyValue);
                this.categoryList = await DatabaseHelper().getCategoryList( widget.moneyValue == MoneyValue.income);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("更新に成功しました。"),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
              child: Center(
                child: AutoSizeText(
                  AppLocalizations.of(context).update,
                  style: TextStyle(color:Colors.black, fontSize: 24),
                )
              ),
            ),
          ],
        ),
      );
    }

    return (titleControllerList.length == 0) ? Container() : SingleChildScrollView(
      child: Column(children: _list),
    );
  }

  Future<void> updateListViewCategory(value) async {
//収支どちらか全てのDBを取得
      this.categoryList = await DatabaseHelper().getCategoryList(value);
      List<TextEditingController> _controllerList = [];
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
    int? _id;
    //削除予定
    for(var i=0;i<categoryList.length;i++) {
      if (categoryList[i].id == beforeId){
        _id = categoryList[i].id;
        break;
      }
    }
    if (_id != null) {
      await DatabaseHelper().updateCategory(Category.withId(_id,after,(value == MoneyValue.income)));
    }
    // print(_id);
  }
}

