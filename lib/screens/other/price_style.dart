import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../main.dart';
import '../../utils/admob_banner.dart';
import '../../utils/shared_prefs.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
          child: BannerBody(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: const Text(
                  '金額の色 変更',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Column(
                children: [
                  SizedBox(height: 50,),
                  Transform.scale(
                      scale: 2,
                      child: squareText(pickerPlusColor,pickerMinusColor),
                  ),
                  SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate([pickerPlusColor, pickerMinusColor].length, (index) {
                        Color color = [pickerPlusColor, pickerMinusColor][index];
                        return  Expanded(
                          flex: 1,
                          child: ClipRect(
                            child: ColorPicker(
                              labelTypes: [],
                              enableAlpha:false,
                              displayThumbColor: false,
                              portraitOnly: true,
                              pickerColor: color,
                              // paletteType: PaletteType.hsv,
                              onColorChanged: (Color value) {
                                // print('0x${value.value.toRadixString(16).toUpperCase()}');
                                if (index == 0) {
                                  pickerPlusColor = value;

                                } else {
                                  pickerMinusColor = value;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      }),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('※変更した場合、アプリが再起動されます',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: const CircleBorder(),
                      minimumSize: const Size(60, 60),
                    ),
                    onPressed: () {
                      String _plusColor = '0x${pickerPlusColor.toARGB32().toRadixString(16).toUpperCase()}';
                      SharedPrefs.setPlusColor(_plusColor);
                      String _minusColor = '0x${pickerMinusColor.toARGB32().toRadixString(16).toUpperCase()}';
                      SharedPrefs.setMinusColor(_minusColor);
                      RestartWidget.restartApp(context);
                    },
                    child: const Text('変更', style: TextStyle(fontSize: 18, color: Colors.white),),
                    // child: Icon(icon),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
  Widget squareText(plusColor,minusColor) {
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
            Expanded(flex: 1,
              child: Align(alignment:Alignment.topRight,
                child: Container(),),
            ),
            //　プラス金額
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    '100${SharedPrefs.getUnit()}',
                    style: TextStyle(color: plusColor),
                    minFontSize: 3,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            //　マイナス金額
            Expanded(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    '-100${SharedPrefs.getUnit()}',
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
