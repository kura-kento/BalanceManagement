// import 'package:diary_app/utils/admob.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import '../main.dart';
import 'app.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker();

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  // final BannerAd myBanner = AdMob.admobBanner();
  // final BannerAd myBanner2 = AdMob.admobBanner2();

  final _controller = CircleColorPickerController(
    initialColor: Color(int.parse(SharedPrefs.getCustomColor())),
  );

  @override
  Widget build(BuildContext context) {
    // print('isNoAds:' + AdMob.isNoAds().toString());
    // if(AdMob.isNoAds() == false){
    //   myBanner.load();
    //   myBanner2.load();
    // }

    return SafeArea(
        child: Column(
          children: [
            // SharedPrefs.getAdPositionTop()
            //     ? AdMob.adContainer(myBanner)
            //     : Container(),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: _controller.color,
                  title: const Text(
                    'テーマカラー変更',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: Column(
                  children: [
                    Center(
                      child: CircleColorPicker(
                        controller: _controller,
                        onChanged: (color) {
                          setState(() => _controller.color = color);
                        },
                        size: const Size(240, 240),
                        strokeWidth: 4,
                        thumbSize: 36,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('※変更した場合、アプリが再起動されます',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _controller.color, //ボタンの背景色
                        shape: const CircleBorder(),
                        minimumSize: const Size(45, 45),
                      ),
                      onPressed: () {
                        String _color = '0xFF${_controller.color.value.toRadixString(16).substring(2, 8)}';
                        SharedPrefs.setCustomColor(_color);
                        App.primary_color = Color(int.parse(SharedPrefs.getCustomColor()));
                        RestartWidget.restartApp(context);
                      },
                      child: const Text('変更',style: TextStyle(color: Colors.white),),
                      // child: Icon(icon),
                    ),
                  ],
                ),
              ),
            ),
            // SharedPrefs.getAdPositionTop()
            //     ? Container()
            //     : AdMob.adContainer(myBanner2),
          ],
        )
    );
  }
}
