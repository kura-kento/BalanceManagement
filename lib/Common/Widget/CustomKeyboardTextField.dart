
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'dart:core';

import '../app.dart';
import '../shared_prefs.dart';
import '../utils.dart';


final priceControllerProvider = StateProvider<TextEditingController>((ref) => TextEditingController());
final selectOperationTextProvider = StateProvider<String>((ref) => '');

class CustomKeyboardTextField extends ConsumerStatefulWidget {
  CustomKeyboardTextField({Key? key});

  @override
  _CustomKeyboardTextFieldState createState() => _CustomKeyboardTextFieldState();
}

class _CustomKeyboardTextFieldState extends ConsumerState<CustomKeyboardTextField> {
  FocusNode _focusNode = FocusNode();
  late TextEditingController priceController;
  String? selectOperation; // 四則演算
  late String selectOperationText; // 計算の前の数字（一時保存）
  double common_height = 230;
  bool isCustomKeyBoard = SharedPrefs.getIsCustomKeyBoard();

  // TODO　カーソルが移動した時の処理
  @override
  void initState() {
    super.initState();
    // isCustomKeyBoard = true;
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // priceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("カスタムキーボード build");
    priceController = ref.watch(priceControllerProvider);
    selectOperationText = ref.watch(selectOperationTextProvider);
    if(MediaQuery.of(context).size.height > 800){
      common_height = 260;
    }

    return Column(
      children: [
        Container(
          height: 65,
          child: KeyboardActions(
            config: _buildConfig(context),
            child: TextField(
              controller: priceController,
              focusNode: _focusNode,
              keyboardType: isCustomKeyBoard ? TextInputType.none : const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,}'))
              ],
              // showCursor: false,
              decoration: InputDecoration(
                labelText: selectOperationText == '' ? '金額' : selectOperationText,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor:  App.keyboardBackgroundColor,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
            footerBuilder: !isCustomKeyBoard ? null : (_) => PreferredSize(
                preferredSize: Size.fromHeight(common_height),
                child: CustomKeyboard2(
                  selectOperation: selectOperation,
                )
            ),
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
                            isCustomKeyBoard = !isCustomKeyBoard;
                            FocusScope.of(context).unfocus();
                            setState(() {});
                            // TODO 閉じ切るまで待つ処理を入れる
                            Future.delayed(Duration(milliseconds: 500))
                                .then((_) {
                              _focusNode.requestFocus();
                              setState(() {});
                            });
                            // FocusScope.of(context).requestFocus(_focusNode);
                            // setState(() {});
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
                                      priceController.text = Utils.calculation(priceController.text,'×','1.08');
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
                                      priceController.text = Utils.calculation(priceController.text,'×','1.1');
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
    priceController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceController.text.length),
    );
  }
}


// CustomKeyboard側の実装
class CustomKeyboard2 extends ConsumerStatefulWidget {
  CustomKeyboard2({Key? key, this.selectOperation}) : super(key: key);
  var selectOperation;

  @override
  _CustomKeyboard2State createState() => _CustomKeyboard2State();

}
class _CustomKeyboard2State extends ConsumerState<CustomKeyboard2> {
  late TextEditingController priceController;
  late String selectOperationText;
  double common_height = 230;
  double _margin = 2;
  bool isCustomKeyBoard = SharedPrefs.getIsCustomKeyBoard();

  @override
  Widget build(BuildContext context) {
    priceController = ref.watch(priceControllerProvider);
    selectOperationText = ref.watch(selectOperationTextProvider);

    if(MediaQuery.of(context).size.height > 800) {
      common_height = 260;
    }

    return Container(
      height: common_height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: _margin + 5,horizontal: _margin + 5),
      decoration: BoxDecoration(
        color: App.keyboardBackgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: ListView(
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
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
              ].reversed.toList(),
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView(
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildKeyboardKey('AC',flex: null),
                _buildKeyboardKey('Del',flex: null),
                _buildKeyboardKey('=',flex: null, height: (45.0 + (_margin)) * 2),
              ].reversed.toList(),),
          ),
        ],
      ),
    );
  }

  // フォーカスを最後飲み時に置く
  void moveToLastCharacter() {
    priceController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceController.text.length),
    );
  }

  Widget _buildKeyboardKey(String value, {flex = 1, height = 45.0}) {
    Widget btn = Container(
      margin: EdgeInsets.all(_margin),
      padding: EdgeInsets.zero,
      height: height,
      // width: 1000, // 画面いっぱいに
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: value == widget.selectOperation ? Colors.yellow : Colors.white,
          foregroundColor: Colors.black87,
        ),
        onPressed: () => _onKeyPressed(value),
        child: Center(
          child: Text(
            value,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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
    print(value);
    final currentValue = priceController.text;

    if (value == '=') {
      // 未記入　ストック有り
      if(selectOperationText != '' && priceController.text == '') {
        priceController.text = selectOperationText;
        operationClear();
      } else {
        priceController.text = Utils.calculation(
            selectOperationText,
            widget.selectOperation,
            priceController.text
        );
        operationClear();
      }

    } else if(['+','-','×','÷'].contains(value)) {
      // ストックにあるか
      if(selectOperationText != '') {
        // 未記入　ストック有り　
        if (priceController.text == '') {
          print("未記入　ストック有り");
          widget.selectOperation = value;
        } else {
          print("記入　ストック有り 計算する");
          priceController.text = Utils.calculation(
              selectOperationText,
              widget.selectOperation,
              priceController.text
          );
          operationStock(value);
        }
      } else {
        // 未記入　ストック無し
        if (priceController.text == '') {
          print("未記入　ストック無し 何も起こらない（エラーを出したい）");
        } else {
          print("記入　ストック無し");
          operationStock(value);
        }
      }
    } else if (value == 'Del') {
      if(priceController.text != '') {
        priceController.text = Utils.numDel(priceController.text);
      }
    } else if (value == 'AC') {
      operationClear();
      priceController.clear();
    } else {
      final newText = '$currentValue$value';

      bool isMatch = new RegExp(r'^\d+\.?\d*$').hasMatch(newText);
      if(isMatch) {
        priceController.text = newText;
      } else {
        print("正規表現 マッチ間違い");
      }
    }
    moveToLastCharacter();
    setState(() {});
  }

  void operationClear() {
    ref.read(selectOperationTextProvider.notifier).state = '';
    widget.selectOperation = null;
  }

  void operationStock(value) {
    ref.read(selectOperationTextProvider.notifier).state = priceController.text; //ストックに移動
    priceController.clear(); //未記入にする
    widget.selectOperation = value; //四則演算を登録
  }
}