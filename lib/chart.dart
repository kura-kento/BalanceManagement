import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// 共通チャートデータクラス
class ChartData {
    double y;
    String x;
    String z;
    String textMoney;


    ChartData(this.x, this.y,this.z,this.textMoney): super();
    }

// チャートの描写をする為に位置計算などして表示するクラス
    class ChartContainer extends StatelessWidget {

    // チャートの上マージン
    final double _chartTopMargin = 30.0;
    // チャートの左右マージン
    final double _chartSideMargin = 20.0;
    // チャートの高さ
    final double _chartHeight = 240.0;
    // 目盛り数値の高さ初期値３７.０
    final double _scaleNumHeight = 36.0;
    // 目盛りに表示させる数値の配列
    List<String> _scaleNumbers;
    // チャートのデータ配列
    final List<ChartData> _charDataList;
    // チャートのタイトル
    final _chartTitle;

    ChartContainer(this._charDataList, this._chartTitle): super();

    // チャートのデータを生成し返す（グラフに共通地に変換）
    List<ChartData> _getChartDataList() {
    List<double> list = List<double>();

    var yMin = 0.0;
    var yMax = 0.0;
    var coarseVal = 0.0;
    var coarese = 0.0;
    var coareseDigit = 0;

    while(coarese < 1.0){

    for (var chatData in _charDataList) {
    list.add(chatData.y * math.pow(10, (coareseDigit)));
    }
    list.sort();
    yMin = list.first;
    yMax = list.last;

    // 最大値と最小値の差
    double _differenceVal = yMax - yMin;

    // 目盛り単位数を求める（2d ≤ w）
    // http://www.eng.niigata-u.ac.jp/~nomoto/21.html
    coarseVal = _differenceVal / 2.0;
    coarese = coarseVal.round().toDouble();
    coareseDigit++;
    }

    _scaleNumbers = List<String>();
    double scaleYMax = 0;
    double scaleYMin = 0;

    var digit = 0;
    while(coarese > 10.0){
    coarese /= 10.0;
    digit++;
    }

    List<int> scaleValues = [1, 2, 5];
    bool isFinish = false;
    var count = 0;
    var multiple = 0;
    int scaleUnitVal = 0;
    while(!isFinish){
    scaleUnitVal = scaleValues[count] * math.pow(10, (digit + multiple));
    if ((scaleUnitVal * 2) > coarseVal) {
    isFinish = true;
    }

    if (count == (scaleValues.length - 1)) {
    count = 0;
    multiple++;
    } else {
    count++;
    }
    }

    // 目盛りの数値が整数値か
    var isInteger = _isIntegerInData(_charDataList);

    // 目盛りの下限値を算出
    var lowerScaleVal = yMin - (yMin % scaleUnitVal);
    _addScaleNumberList(lowerScaleVal, isInteger, coareseDigit);


    // 目盛りの数値一覧を生成する
    var scaleVal = lowerScaleVal;
    scaleYMin = lowerScaleVal;
    while(yMax > scaleVal){
      scaleVal += scaleUnitVal;
      scaleYMax = scaleVal;
      _addScaleNumberList(scaleVal, isInteger, coareseDigit);
    }
    _scaleNumbers = _scaleNumbers.reversed.toList();


    // 一座標の数値を算出
    double _unitPoint = 100.0 / (scaleYMax - scaleYMin);

    List<ChartData> _chartList = List<ChartData>();
    for (var chatData in _charDataList) {
      double _newY= (100.0 - (((chatData.y * math.pow(10, (coareseDigit - 1))) - scaleYMin) * _unitPoint)) / 100.0;
      _chartList.add(new ChartData(chatData.x, _newY,chatData.z,chatData.textMoney));
    }
    return _chartList;
  }

  // 目盛り数リストに追加
  void _addScaleNumberList(double num, bool isInteger, int pow) {

    if (num == 0){
      _scaleNumbers.add('0');
    } else {

      if (pow > 1){
        var n = num / math.pow(10, (pow - 1));
        _scaleNumbers.add(n.toString());
        return;
      }

      if (isInteger) {
        int _num = num.toInt();
        _scaleNumbers.add(_num.toString());
      } else {
        _scaleNumbers.add(num.toString());
      }
    }
  }


  // データ内の数値はすべて整数か判断
  bool _isIntegerInData(List<ChartData> list) {
    for (var data in list) {
      if (!_isInteger(data.y)) {
        return false;
      }
    }
    return true;
  }

  // 整数値か判断
  bool _isInteger(double x) {
    return (x.round() == x);
  }

  // 日付のレイアウトを生成し返す
  Widget _getDateLayout(List<ChartData> list) {
    // レイアウト配列
    List<Widget> _dateLayoutList = List<Widget>();

    for (var chartData in list) {
      Widget widget = (Expanded(child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height:20,
              child: Text(
                chartData.z,
                style: TextStyle(
                    color: Colors.grey,
                ),
              ),
            ),
            Text(
              chartData.x,
              style: TextStyle(
                  color: Colors.grey
              ),
            ),
          ],
        ),
        alignment: Alignment.topCenter,
      ),));
      _dateLayoutList.add(widget);
    }
    return Row(children:_dateLayoutList);
  }

  // 数値のレイアウトを生成し返す
  Widget _getChartNumberLayout() {
    // レイアウト配列
    List<Widget> barLayoutList = List<Widget>();
    var _horizontalBarNum = _scaleNumbers.length;

    // グラフ目盛り数値のマージン計算
    var marginHeight = (_chartHeight - _chartTopMargin * 2) / (_horizontalBarNum - 1) - _scaleNumHeight;

    for (var i = 0; i < _horizontalBarNum; i++) {
      Widget widget = (Container(
        child: AutoSizeText(
          "${Utils.commaSeparated(double.parse(_scaleNumbers[i]))}${SharedPrefs.getUnit()}",
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey
          ),
          minFontSize: 4,
          maxLines: 1,
        ),
        height: _scaleNumHeight,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.only(top: (i == 0 ? 0 : marginHeight)),
      )
      );
      barLayoutList.add(widget);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: barLayoutList,
    );
  }



  @override
  Widget build(BuildContext context) {
    List<ChartData> _chartDataList = _getChartDataList();

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            height: 32,
            child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 0, top: 5.0, bottom: 0),
              alignment: Alignment.centerLeft,
              child: Text(
                _chartTitle,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          Expanded(child:Row(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                width: 50,
                child: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: _getChartNumberLayout(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    //修正
                    width: _charDataList.length <= 4 ? 430 : (65.0*_charDataList.length),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomPaint(
                          painter: ChartPainter(_scaleNumbers.length, _chartTopMargin, _chartDataList, _chartSideMargin),
                          child: Container(
                              height: _chartHeight
                          ),
                        ),
                        Expanded(child: Container(
                            margin: EdgeInsets.symmetric(horizontal: _chartSideMargin),
                            child: _getDateLayout(_chartDataList)
                        ),),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
        ]
    );
  }
  graphWidth(){
   // GraphPage.graphMonth();
  }

}

// チャートグラフ
class ChartPainter extends CustomPainter {
  final _circleSize = 7.0;
  var _horizontalBarNum;
  var _horizontalAdjustHeight = 10.0;
  var _varticalAdjustWidth = 20.0;
  List<ChartData> _chartList = List<ChartData>();

  ChartPainter(this._horizontalBarNum, this._horizontalAdjustHeight, this._chartList, this._varticalAdjustWidth): super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;
    var rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);


    // 横線
    paint.color = Colors.grey;
    var horizontalHeight = (size.height - _horizontalAdjustHeight * 2) / (_horizontalBarNum - 1);
    for (var i = 0; i < _horizontalBarNum; i++) {
      var y = horizontalHeight * i + _horizontalAdjustHeight;
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), paint);
    }

    // ポイントの描写
    if(_chartList.length ==1 && _chartList[0].textMoney == "0") {

    }else {
      for (var i = 0; i < _chartList.length; i++) {
        _createPoint(canvas, size, paint, _chartList[i].y, i);
      }
    }
  }

  void _createPoint(Canvas canvas, Size size, Paint paint, double y, int count) {
    double pointY = _horizontalAdjustHeight + ((size.height - _horizontalAdjustHeight * 2) * y);
    double scopeWidth = size.width - (_varticalAdjustWidth * 2);
    double pointX = (scopeWidth / (_chartList.length * 2) * (count + 1)) + (scopeWidth / (_chartList.length * 2) * count) + _varticalAdjustWidth;
    double textPointY = _horizontalAdjustHeight + ((size.height - _horizontalAdjustHeight * 2) * y)-28;
    double textPointX = (scopeWidth / (_chartList.length * 2) * (count + 1)) + (scopeWidth / (_chartList.length * 2) * count) + _varticalAdjustWidth-((_chartList[count].textMoney.length+1)/2)*6;

    // 円背景
    paint.color = Colors.white;
    canvas.drawCircle(Offset(pointX, pointY), _circleSize, paint);

    // 円線
    Paint line = new Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
        Offset(pointX, pointY),
        _circleSize,
        line
    );
    //その月の金額
        TextSpan span = TextSpan(
                          style: TextStyle(
                              fontSize: 14.0-(_chartList[count].textMoney.length/1.5),
                              color: Colors.grey
                          ),
                        text: "${Utils.commaSeparated(int.parse(_chartList[count].textMoney))}${SharedPrefs.getUnit()}",
                      );


        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(textPointX, textPointY));



  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

