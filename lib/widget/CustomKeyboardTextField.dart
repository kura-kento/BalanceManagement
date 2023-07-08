import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:core';

import '../utils/utils.dart';

class CustomKeyboardTextField extends StatefulWidget {
  @override
  _CustomKeyboardTextFieldState createState() => _CustomKeyboardTextFieldState();
}

class _CustomKeyboardTextFieldState extends State<CustomKeyboardTextField>{
  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  OverlayEntry overlayEntry;
  String selectOperation = null;
  String selectOperationText = '';
  // final TextEditingController selectOperationController = TextEditingController();
  TextEditingController changeController;
  BoxBorder _border = Border.all(width: 1.0, color:Colors.red);
  double _margin = 2.5;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _focusNode.requestFocus();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    // ウィジェットをオーバーレイに追加
    // overlayEntry = createOverlayEntry(_onKeyPressed);
    // Overlay.of(context).insert(overlayEntry);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    // _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
     if(_focusNode.hasFocus) {
       // overlayEntry = createOverlayEntry(_onKeyPressed);
       // Overlay.of(context).insert(overlayEntry);
     }
  }

  void _onKeyPressed(String value) {
    final currentValue = _textEditingController.text;

    if (value == '=') {
      _textEditingController.text = Utils.calculation(
          selectOperationText,
          selectOperation,
          _textEditingController.text
      );
      operationClear();
    } else if(['+','-','×','÷'].contains(value)) {
      print(('2+2*3'));
      // ストックにあるか
      if(selectOperationText != '') {
        // 未記入　ストック有り　
        if (_textEditingController.text == '') {
            print("未記入　ストック有り");
            selectOperation = value;
        } else {
          print("記入　ストック有り 計算する");
          _textEditingController.text = Utils.calculation(
              selectOperationText,
              selectOperation,
              _textEditingController.text
          );
          operationStock(value);
        }
      } else {
        // 未記入　ストック無し
        if (_textEditingController.text == '') {
          print("未記入　ストック無し 何も起こらない（エラーを出したい）");
        } else {
          print("記入　ストック無し");
          operationStock(value);
        }
      }
    } else if (value == 'Del') {
       if(_textEditingController.text != '') {
         _textEditingController.text = Utils.numDel(_textEditingController.text);
       }
    } else if (value == 'AC') {
      operationClear();
      _textEditingController.clear();
    } else {
      final newText = '$currentValue$value';

      bool isMatch = new RegExp(r'^\d+\.?\d*$').hasMatch(newText);
      if(isMatch) {
        _textEditingController.text = newText;
      } else {
        print("正規表現 マッチ間違い");
      }
    }
    setState(() {});
  }
  void operationClear() {
    selectOperationText = '';
    selectOperation = null;
  }

  void operationStock(value) {
    selectOperationText = _textEditingController.text; //ストックに移動
    _textEditingController.clear(); //未記入にする
    selectOperation = value; //四則演算を登録
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          keyboardType: TextInputType.none,
          decoration: InputDecoration(
              labelText: selectOperation == null ? '金額' : selectOperationText,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
              ),
          ),
        ),
        SizedBox(height: 16.0),
        CustomKeyboard(),
      ],
    );
  }

  // OverlayEntry createOverlayEntry(_onKeyPressed) {
  //   OverlayEntry(
  //     builder: (context) => Positioned(
  //       bottom: 0,
  //       left: 0,
  //       right: 0,
  //       child: Container(
  //         height: 800,  // ウィジェットの高さを設定する（必要に応じてサイズを調整）
  //         color: Colors.white,  // ウィジェットの背景色を設定する（必要に応じてカスタマイズ）
  //         child: CustomKeyboard(onKeyPressed: _onKeyPressed),  // 表示したいウィジェットを指定する
  //       ),
  //     ),
  //   );
  // }

  Widget CustomKeyboard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_margin),
      decoration: BoxDecoration(
        border: _border,
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildKeyboardKey('7'),
                    _buildKeyboardKey('8'),
                    _buildKeyboardKey('9'),
                    _buildKeyboardKey('÷'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeyboardKey('4'),
                    _buildKeyboardKey('5'),
                    _buildKeyboardKey('6'),
                    _buildKeyboardKey('×'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeyboardKey('1'),
                    _buildKeyboardKey('2'),
                    _buildKeyboardKey('3'),
                    _buildKeyboardKey('-'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeyboardKey('0',flex: 2),
                    _buildKeyboardKey('.'),
                    _buildKeyboardKey('+'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildKeyboardKey('AC',flex: null),
                _buildKeyboardKey('Del',flex: null),
                _buildKeyboardKey('=',flex: null, height: (80.0+_margin) * 2),
              ],),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardKey(String value, {flex = 1, height = 80.0}) {
    Widget btn = GestureDetector(
      onTap: () => _onKeyPressed(value),
      child: Container(
        height: height,
        alignment: Alignment.center,
        margin: EdgeInsets.all(_margin),
        decoration: BoxDecoration(
          color: value == selectOperation ? Colors.yellow : Colors.transparent,
          border: _border,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
      ),
    );

    if (flex == null) {
      return btn;
    } else {
      return Expanded(
        flex: flex,
        child: btn,
      );
    }
  }
}