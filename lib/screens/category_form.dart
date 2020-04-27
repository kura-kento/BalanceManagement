import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key,this.plusOrMinus}) : super(key: key);
  final String plusOrMinus;
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  List<TextEditingController> incomeTitleControllerList = List<TextEditingController>();
  TextEditingController spendingTitleController = TextEditingController();

  @override
  void initState(){
    updateListViewCategory(widget.plusOrMinus == "plus" ? true : false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("カテゴリー編集"),
      ),
      body:  GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),

      child:SingleChildScrollView(
          child: Column(children: categoryListWidget())
      ),
      ),
    );
  }

  List<Widget> categoryListWidget(){
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
                  controller: incomeTitleControllerList[i],
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
                    onPressed: (){
                        _update(categoryList[i].id,incomeTitleControllerList[i].text, widget.plusOrMinus == "plus" ? true : false);
                        updateListViewCategory(widget.plusOrMinus == "plus" ? true : false);
                        setState(() {});
                    },child: Center(child: Text("更新")),
                  ),
                )
            )
          ],
        ),
      );
    }
      return _list;
  }

  Future<void> updateListViewCategory(value) async{
//収支どちらか全てのDBを取得
    List<Category> _categoryList = await databaseHelperCategory.getCategoryList(value);
      this.categoryList = _categoryList;
      List<TextEditingController> _controllerList = List<TextEditingController>();
      for(int i=0;i < categoryList.length;i++){
        if(categoryList[i].plus == value){
          _controllerList.add(TextEditingController());
        }
      }
      incomeTitleControllerList = _controllerList;

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
    await databaseHelperCategory.updateCategory(Category.withId(_id,after,value));
    print(_id);
  }
}

