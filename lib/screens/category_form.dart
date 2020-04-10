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

  TextEditingController incomeTitleController = TextEditingController();
  TextEditingController spendingTitleController = TextEditingController();

  @override
  void initState(){
    updateListViewCategory();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //ここに入れてもいいのか？
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
          child: Column(
              children: CategoryList()
          )
      ),

    );
  }

  List<Widget> CategoryList(){
    List<Widget> _list = [];
    for (int i = 0; i < categoryList.length; i++) {
      _list.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: TextField(
                controller: incomeTitleController,
                //style: textStyle,
                decoration: InputDecoration(
                    labelText: categoryList[i].title,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    padding: EdgeInsets.all(20.0),
                    color: Colors.grey[400],
                    onPressed: (){
                      setState(() {
                        _update(categoryList[i].id,incomeTitleController.text,true);
                      });
                    },child: Text("更新"),
                  ),
                )
            )
          ],
        ),
      );
    }
      return _list;
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    List<Category> _categoryList = await databaseHelperCategory.getCategoryList(true);
    setState(() {
      this.categoryList = _categoryList;
    });
  }
  //アップデート
  Future <void> _update(before,after,value) async {
    int _id;
    //削除予定
    for(var i=0;i<categoryList.length;i++) {
      if (categoryList[i].id == int.parse(before)){
        _id = categoryList[i].id;
        break;
      }
    }
    await databaseHelperCategory.updateCategory(Category.withId(_id,after,value));
    print(_id);
  }
}

