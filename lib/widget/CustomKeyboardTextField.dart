import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
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
  bool isCustomKeyBoard = SharedPrefs.getIsCustomKeyBoard();

  // TODO　カーソルが移動した時の処理
  @override
  void initState() {
    super.initState();
    // _focusNode.addListener(_onFocusChange);
    // _focusNode.requestFocus();
    isCustomKeyBoard = true;
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 65,
          child: KeyboardActions(
            config: _buildConfig(context),
            child: TextField(
              controller: _textEditingController,
              focusNode: _focusNode,
              keyboardType: isCustomKeyBoard ? TextInputType.none : const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,}'))
              ],
              // showCursor: false,
              decoration: InputDecoration(
                  labelText: selectOperation == null ? '金額' : selectOperationText,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                  ),
              ),
            ),
          ),
        ),
       // CustomKeyboard(),
      ],
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor:  const Color(0xFFd5d7de),
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
            footerBuilder: (_) => CustomKeyboard2(),
            focusNode: _focusNode,
            toolbarButtons: [
              (node) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.calculate_outlined, size: 40, color: Colors.cyan,),
                    onPressed: () {
                      SharedPrefs.setIsCustomKeyBoard(!isCustomKeyBoard);
                      setState(() {});
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                _textEditingController.text = Utils.calculation(_textEditingController.text,'×','1.08');
                                moveToLastCharacter();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '税込8%',
                                  style: const TextStyle(
                                      color: Colors.cyan, fontSize: 15),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _textEditingController.text = Utils.calculation(_textEditingController.text,'×','1.1');
                                moveToLastCharacter();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '税込10%',
                                  style: const TextStyle(
                                      color: Colors.cyan, fontSize: 15),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                node.unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '完了',
                                  style: const TextStyle(
                                      color: Colors.cyan, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          }
        ]),
      ],
    );
  }

  // フォーカスを最後飲み時に置く
  void moveToLastCharacter() {
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textEditingController.text.length),
    );
  }
}

// CustomKeyboard側の実装
class CustomKeyboard2 extends StatelessWidget
    implements PreferredSizeWidget {
  final ValueNotifier<String> notifier;

  CustomKeyboard2({Key key, this.notifier}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(350);
  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  OverlayEntry overlayEntry;
  String selectOperation = null;
  String selectOperationText = '';
  // final TextEditingController selectOperationController = TextEditingController();
  TextEditingController changeController;
  BoxBorder _border = Border.all(width: 1.0, color:Colors.red);
  double _margin = 2.5;
  bool isCustomKeyBoard = SharedPrefs.getIsCustomKeyBoard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: preferredSize.height,
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
                  _buildKeyboardKey('=',flex: null, height: (70.0+_margin) * 2),
                ],),
            ),
          ],
        ),
      ),
    );
  }

  // フォーカスを最後飲み時に置く
  void moveToLastCharacter() {
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textEditingController.text.length),
    );
  }

  Widget _buildKeyboardKey(String value, {flex = 1, height = 70.0}) {
    Widget btn = GestureDetector(
      onTap: () => _onKeyPressed(value),
      child: Container(
        // width: MediaQuery.of(context).size.width / 5,
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
    moveToLastCharacter();
    // setState(() {});
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
}