import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateForm extends StatefulWidget {

  CreateForm({Key key, this.selectDay}) : super(key: key);
  final DateTime selectDay;

  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {

  static var _fluctuation = ['プラス','マイナス'];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
          appBar: AppBar(
            title: Text("新規追加フォーム"),
            leading: IconButton(icon: Icon(
                Icons.arrow_back),
              onPressed: (){
                //
                moveToLastScreen();
              },
            ),
          ),
          body: Padding(
              padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
              child: ListView(
                children: <Widget>[

                  ListTile(
                    title: DropdownButton(
                        items: _fluctuation.map((String dropDownStirngItem){
                          return DropdownMenuItem<String>(
                            value: dropDownStirngItem,
                            child: Text(dropDownStirngItem),
                          );
                        }).toList(),

                        style: textStyle,

                        value: 'プラス',

                        onChanged: (valueSelectedByUser){
                          debugPrint('User selected $valueSelectedByUser');
                        }
                    ),
                  ),
                  //second Element
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
                  //third element
                  Padding(
                      padding: EdgeInsets.only(top:15,bottom:15),
                      child:TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                          labelText: '収支',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      )
                      )
/*
                       TextField(
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (value){
                          debugPrint('Something changed in Description Text Field');
                        },
                        decoration: InputDecoration(
                            labelText: '収支',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)
                            )
                        ),
                      )
*/
                  ),

                  //Fourth Element
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
                                    debugPrint("Delete button clicked");
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
                                    debugPrint("Save button clicked");
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
        );
  }

  void moveToLastScreen(){
    Navigator.pop(context);
  }
}


//作成フォーム（削除予定）
class CreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("追加フォーム"),
          bottom: TabBar(
            tabs: <Widget>[Tab(text: "プラス"), Tab(text: "マイナス")],
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Container(
            color: Colors.white,
          ),
        ]),
      ),
    );
  }
}