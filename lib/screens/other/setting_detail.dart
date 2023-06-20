import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../i18n/message.dart';
import '../../utils/app.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/utils.dart';

class SettingDetail extends StatefulWidget {
  const SettingDetail({Key key}) : super(key: key);

  @override
  State<SettingDetail> createState() => _SettingDetailState();
}

class _SettingDetailState extends State<SettingDetail> {

  TextEditingController unitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('詳細設定'),),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Divider(color: Colors.grey,height:0),
                    ListTile(
                        title: Text('0円を表示させない'),
                        trailing: CupertinoSwitch(
                          value: SharedPrefs.getIsZeroHidden(),
                          onChanged: (bool value) {
                            setState(() {
                              SharedPrefs.setIsZeroHidden(value);
                            });
                          },
                        )
                    ),
                    squareText(),
                    Container(height: 5.0,),
                    Divider(color: Colors.grey,height:0),
                    Padding(
                      padding: EdgeInsets.only(top:5,bottom:5),
                      child:Column(
                        children: <Widget>[
                          Text("${AppLocalizations.of(context).unit}${AppLocalizations.of(context).edit}"),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text("${AppLocalizations.of(context).unit}：",
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 1.5,
                                ),
                              ),
                              Expanded(
                                flex:2,
                                child: TextField(
                                  onTap: () {
                                    unitController.text = SharedPrefs.getUnit();
                                  },
                                  controller: unitController,
                                  decoration: InputDecoration(
                                      labelText: '${SharedPrefs.getUnit()}',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0)
                                      )
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: App.NoAdsButtonColor, //ボタンの背景色
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        SharedPrefs.setUnit("${unitController.text}");
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                    child: AutoSizeText(
                                      AppLocalizations.of(context).update,
                                      minFontSize: 4,
                                      maxLines: 1,
                                      textScaleFactor: 1.5,
                                      style: TextStyle(fontSize: App.BTNfontsize),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    ),
                  ],
                )
             )
          ),
      ),
    );
  }

  Widget squareText() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xff999999),
          width: 1.0,
        ),
      ),
      child: Container(
        color: Colors.grey[100],
        height: 50,
        width: 50,
        child: Column(
          children: [
            const Spacer(flex: 1),
            //　プラス金額
            SharedPrefs.getIsZeroHidden()
              ?
            Container()
                :
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    '0${SharedPrefs.getUnit()}',
                    style: TextStyle(color: App.plusColor),
                    minFontSize: 3,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            //　マイナス金額
            SharedPrefs.getIsZeroHidden()
                ?
            Container()
                :
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    '0${SharedPrefs.getUnit()}',
                    style: TextStyle(color: App.minusColor),
                    minFontSize: 3,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
