import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../Common/Admob/admob_banner.dart';
import '../../Common/app.dart';
import '../../Common/shared_prefs.dart';
import '../../Common/utils.dart';
import '../../main.dart';

class PriceStyle extends StatefulWidget {
  const PriceStyle({super.key});

  @override
  _PriceStyleState createState() => _PriceStyleState();
}

class _PriceStyleState extends State<PriceStyle> {
  Color pickerPlusColor = Color(int.parse(SharedPrefs.getPlusColor()));
  Color currentPlusColor = Color(int.parse(SharedPrefs.getPlusColor()));

  Color pickerMinusColor = Color(int.parse(SharedPrefs.getMinusColor()));
  Color currentMinusColor = Color(int.parse(SharedPrefs.getMinusColor()));

  TextStyle listTileStyle = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
          child: BannerBody(
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: App.isSmall(context) ? 40 : 50,
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text(
                  'カレンダー 詳細設定',
                  style: TextStyle(
                    fontSize: 20,
                    // color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Column(
                children: [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.5,
                        child: squareText(pickerPlusColor,pickerMinusColor,0),
                      ),
                      Container(width: 25),
                      Transform.scale(
                        scale: 1.5,
                        child: squareText(pickerPlusColor,pickerMinusColor,100),
                      ),
                    ],),
                  SizedBox(height: 15,),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: ListTile(
                                  minTileHeight: 40,
                                  leading: Icon(Icons.visibility_off, color: Theme.of(context).iconTheme.color,),
                                  title: Text('0円を表示させない', style: listTileStyle),
                                  trailing: CupertinoSwitch(
                                    value: SharedPrefs.getIsZeroHidden(),
                                    onChanged: (bool value) {
                                      setState(() {
                                        SharedPrefs.setIsZeroHidden(value);
                                      });
                                    },
                                  )
                              ),
                            ),
                            ListTile(
                                title: Text('メモのアイコンを非表示', style: listTileStyle),
                                leading: Icon(Icons.note_outlined, color: Theme.of(context).iconTheme.color,),
                                trailing: CupertinoSwitch(
                                  value: SharedPrefs.getIsMemoHidden(),
                                  onChanged: (bool value) {
                                    setState(() {
                                      SharedPrefs.setIsMemoHidden(value);
                                    });
                                  },
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: ListTile(
                                minTileHeight: 40,
                                leading: Icon(Icons.format_size, color: Theme.of(context).iconTheme.color,),
                                title: Row(children: [
                                  Text('日付サイズ変更', style: listTileStyle),
                                  Text(' ※不具合解消用', textAlign: TextAlign.start ,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
                                ],),
                              ),
                            ),
                            Slider(
                              value: SharedPrefs.getTextSize(),
                              min: 0,
                              max: 20,
                              divisions: 40,
                              activeColor:App.NoAdsButtonColor,
                              label: SharedPrefs.getTextSize().toString(),
                              onChanged: (double) {
                                SharedPrefs.setTextSize(double);
                                setState(() {});
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: ListTile(
                                minTileHeight: 40,
                                leading: Icon(Icons.color_lens_outlined, color: Theme.of(context).iconTheme.color,),
                                title: Text('金額の色変更', style: listTileStyle),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate([pickerPlusColor, pickerMinusColor].length, (index) {
                                  Color color = [pickerPlusColor, pickerMinusColor][index];
                                  return  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(border: Border.all(color:Colors.grey)),
                                        height: App.isSmall(context) ? 200 : 300,
                                        child: MaterialPicker(
                                          pickerColor: color,
                                          onColorChanged: (Color value) {
                                                if (index == 0) {
                                                  pickerPlusColor = value;
                                                } else {
                                                  pickerMinusColor = value;
                                                }
                                                setState(() {});
                                          },),
                                      ),
                                    ),
                                  );
                                }),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black54, //ボタンの背景色
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                String _plusColor = '0x${pickerPlusColor.toARGB32().toRadixString(16).toUpperCase()}';
                                SharedPrefs.setPlusColor(_plusColor);
                                String _minusColor = '0x${pickerMinusColor.toARGB32().toRadixString(16).toUpperCase()}';
                                SharedPrefs.setMinusColor(_minusColor);
                                RestartWidget.restartApp(context);
                              },
                              child: const Text('色変更', style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
                              // child: Icon(icon),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('※色を変更した場合、アプリが再起動されます',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
  Widget squareText(plusColor,minusColor, money) {
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50/3,
                    color: money == 0 ? Colors.red[300] : Colors.transparent ,
                    child: Center(
                      child: Text(
                        '25',
                        style: TextStyle(
                          fontSize: Utils.parseSize(context, SharedPrefs.getTextSize()),
                          color: money == 0 ? Colors.white : Colors.black87,
                          height: 0.75,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 3,
                  child: Container(
                    padding: EdgeInsets.only(right: 2),
                    alignment: Alignment.centerRight,
                    child: (!SharedPrefs.getIsMemoHidden()) ? Icon(Icons.note_outlined, size: 13,) : Container(),),
                ),
              ],
            ),
            //　プラス金額
            SharedPrefs.getIsZeroHidden() && money == 0
                ?
            Container()
                :
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    '$money${SharedPrefs.getUnit()}',
                    style: TextStyle(color: plusColor),
                    minFontSize: 3,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            //　マイナス金額
            SharedPrefs.getIsZeroHidden() && money == 0
                ?
            Container()
                :
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    '${money == 0 ? '' : '-'}$money${SharedPrefs.getUnit()}',
                    style: TextStyle(color: minusColor),
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
