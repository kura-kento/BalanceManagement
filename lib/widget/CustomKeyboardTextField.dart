import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CustomKeyboardTextField extends StatefulWidget {
  @override
  _CustomKeyboardTextFieldState createState() => _CustomKeyboardTextFieldState();
}

class _CustomKeyboardTextFieldState extends State<CustomKeyboardTextField>{
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry overlayEntry;

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
      // Calculate the expression
      try {
        // final expression = Parser().parse(currentValue);
        // final double result = expression.evaluate(EvaluationType.REAL, ContextModel());
        // _textEditingController.text = result.toString();
      } catch (e) {
        _textEditingController.text = 'Error';
      }
    } else if (value == 'C') {
      // Clear the TextField
      _textEditingController.clear();
    } else {
      // Append the pressed key to the TextField
      final newText = '$currentValue$value';
      _textEditingController.text = newText;
    }
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // ウィジェットをオーバーレイに追加
    //   overlayEntry = createOverlayEntry(_onKeyPressed);
    //   Overlay.of(context).insert(overlayEntry);
    // });

    return Column(
      children: [
        TextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          keyboardType: TextInputType.none,
            decoration: InputDecoration(
                labelText: '金額',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                )
            )
        ),
        SizedBox(height: 16.0),
        CustomKeyboard(onKeyPressed: _onKeyPressed,),
      ],
    );
  }

  OverlayEntry createOverlayEntry(_onKeyPressed) {
    OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 800,  // ウィジェットの高さを設定する（必要に応じてサイズを調整）
          color: Colors.white,  // ウィジェットの背景色を設定する（必要に応じてカスタマイズ）
          child: CustomKeyboard(onKeyPressed: _onKeyPressed),  // 表示したいウィジェットを指定する
        ),
      ),
    );
  }
}

class CustomKeyboard extends StatelessWidget {
  CustomKeyboard({this.onKeyPressed});
  final Function(String) onKeyPressed;

  BoxBorder _border = Border.all(width: 1.0, color:Colors.red);
  EdgeInsetsGeometry _margin = EdgeInsets.all(2.5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: _margin,
      decoration: BoxDecoration(
          border: _border,
          color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildKeyboardKey('7'),
              _buildKeyboardKey('8'),
              _buildKeyboardKey('9'),
              _buildKeyboardKey('÷'),
              _buildKeyboardKey('AC'),
            ],
          ),
          Row(
            children: [
              _buildKeyboardKey('4'),
              _buildKeyboardKey('5'),
              _buildKeyboardKey('6'),
              _buildKeyboardKey('×'),
              _buildKeyboardKey('Del'),
            ],
          ),
          Row(
            children: [
              _buildKeyboardKey('1'),
              _buildKeyboardKey('2'),
              _buildKeyboardKey('3'),
              _buildKeyboardKey('-'),
              _buildKeyboardKey('OK'),
            ],
          ),
          Row(
            children: [
              _buildKeyboardKey('0'),
              _buildKeyboardKey('00',flex: 2),
              _buildKeyboardKey('+'),
              _buildKeyboardKey('OK'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardKey(String value, {flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => onKeyPressed(value),
        child: Container(
          height: 80.0,
          alignment: Alignment.center,
          margin: _margin,
          decoration: BoxDecoration(
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
      ),
    );
  }
}