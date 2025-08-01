import 'package:balancemanagement_app/Common/Admob/admob_banner.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/models/DB/database_help.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:balancemanagement_app/Common/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../Common/Widget/CustomKeyboardTextField.dart';
import '../../Common/app.dart';
import 'calendar_page.dart';
import 'category_form.dart';

enum InputMode{
  create,
  edit
}

class EditForm extends ConsumerStatefulWidget {
  EditForm({Key? key, this.calendar, required this.inputMode}) : super(key: key);
  // final Function parentFn;
  final Calendar? calendar;
  final InputMode inputMode;

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends ConsumerState<EditForm> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = [];
  List<Category> categoryList = [];
  bool _isDisabled = false;
  MoneyValue moneyValue = MoneyValue.income;

  List<Category> _categoryItems =[Category.withId(0, "（空白）", true)];
  int _selectCategory = 0;

  late TextEditingController titleController;
  late TextEditingController priceController; //プロバイダー化
  late TextEditingController memoController;
  late FixedExtentScrollController scrollController;
  late DateTime selectDay;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    num calendarMoney = widget.calendar?.money ?? 0;

    // プラスかマイナスか？
    if (widget.inputMode == InputMode.edit) { // 編集
      moneyValue = calendarMoney >= 0 ? MoneyValue.income : MoneyValue.spending;
    } else { // 新規の場合は前回のボタンを同じにする
      moneyValue = SharedPrefs.getIsPlusButton() ? MoneyValue.income : MoneyValue.spending;
    }

    titleController = TextEditingController(text: widget.calendar?.title ?? '');
    memoController = TextEditingController(text: widget.calendar?.memo ?? '');

    //編集フォームでドロップダウンの位置決め
    List<Category>_categoryItems = await updateListViewCategory(moneyValue == MoneyValue.income);
    List<int> _category = _categoryItems.map((category) => category.id ?? 0).toList();
    _selectCategory = _category.indexOf(widget.calendar?.categoryId ?? 0);
    scrollController = FixedExtentScrollController(initialItem: _selectCategory);

    // 描画完了後？
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // カテゴリーのプルダウンの位置
      var moneyText = widget.calendar == null ? '' : '${Utils.formatNumber(calendarMoney  * (calendarMoney < 0 ? -1:1 ))}';
      ref.read(priceControllerProvider.notifier).state = TextEditingController(text: moneyText);
      setState(() {});
    });
  }

  void handleBack(BuildContext context, String? message) async {
    // キーボードを閉じる
    FocusScope.of(context).unfocus();

    // 最大500ms待つ（50ms × 15回）
    for (int i = 0; i < 15; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      // キーボードが閉じたか確認
      if (MediaQuery.of(context).viewInsets.bottom == 0) {
        break;
      }
    }
    // 画面を戻す
    Navigator.of(context).pop(message);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    priceController = ref.watch(priceControllerProvider);
    selectDay = ref.watch(selectDayProvider);

    return Container(
      color: App.bgColor,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: BannerBody(
            child: Scaffold(
              resizeToAvoidBottomInset: true, // キーボードを避ける
              body: Column(
                children: <Widget>[
                  Container(
                    color: App.bgColor,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => handleBack(context, null),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Align(
                             alignment: Alignment.bottomCenter,
                             child: Text(DateFormat('yyyy年MM月dd日').format(selectDay),style: TextStyle(fontSize: 18),),),
                        ),
                        Expanded(
                          flex: 1,
                          child: saveButton(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0,),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(children: btnPlusMinus()),
                              Padding(
                                padding: App.padding,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(flex: 1,
                                      child: categoryWidget(),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(flex: 2,
                                        child: titleWidget()
                                    ),
                                  ],
                                ),
                              ),
                              moneyWidget(),
                              memoWidget(),
                              dustButton(),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> btnPlusMinus() {
    List<Widget> _list = [];
    [MoneyValue.income,MoneyValue.spending].asMap().forEach((index,element) {
      if (index == 1) {
        _list.add(SizedBox(width: 8));
      }
      final baseColor = (index == 0) ? App.plusColor : App.minusColor;
      _list.add(
        Expanded(
          flex: 1,
          child: ElevatedButton(
            child: Text(
              index == 0 ? AppLocalizations.of(context).plus : AppLocalizations.of(context).minus,
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              backgroundColor: (moneyValue == element ? baseColor : Color.alphaBlend(Color(0x80FAFAFA),baseColor)),
              foregroundColor: moneyValue == element ? Colors.white : Colors.grey[400],
            ),
            onPressed: () {
              moneyValue = element;
              SharedPrefs.setIsPlusButton(element == MoneyValue.income);
              updateListViewCategory(element == MoneyValue.income);
              _selectCategory = 0;
              scrollController = FixedExtentScrollController(initialItem: _selectCategory);
              setState(() {});
            },
          ),
        ),
      );
    });
    return _list;
  }

  Future <void> _save() async {
    if (widget.inputMode == InputMode.edit) {
      // TODO [widget.calendarId ?? 0]ではないかと
      await databaseHelper.updateCalendar(
          Calendar.withId(
              widget.calendar?.id ?? 0,
              Utils.toDouble(priceController.text)*(moneyValue == MoneyValue.income ? 1 : -1),
              '${titleController.text}',
              '${memoController.text}',
              widget.calendar?.date,
              _categoryItems[_selectCategory].id)
      );
    } else {
      await databaseHelper.insertCalendar(Calendar(Utils.toDouble(priceController.text)*(moneyValue == MoneyValue.income ? 1 : -1),
                                                            '${titleController.text}',
                                                            '${memoController.text}',
                                                              selectDay,
                                                            _categoryItems[_selectCategory].id));
    }
  }

  Future <void> _delete(int id) async {
    await databaseHelper.deleteCalendar(id);
  }

  Widget _pickerItem(Category category) {
    return Text(
      category.title ?? '',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, fontFamily: "Noto Sans JP",color: category.id == 0  ? Colors.grey : Colors.black),
    );
  }

  Future<List<Category>> updateListViewCategory(bool isPlus) async {
    //収支どちらか全てのDBを取得
    this.categoryList = await DatabaseHelper().getCategoryList(isPlus);

    _categoryItems = [
      Category.withId(0, AppLocalizations.of(context).space, moneyValue == MoneyValue.income),
      ...categoryList
    ];
    setState(() {});
    return _categoryItems;
  }

  Widget saveButton() {
    return IconButton(
      onPressed: _isDisabled ? null : () {
        setState(() => _isDisabled = true);
        _save();
        handleBack(context,'保存に成功しました');
      },
      icon: Icon(Icons.save,size: 32,),
    );
  }

  Widget categoryWidget() {
    return InkWell(
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10,right: 2),
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: false ? Theme.of(context).colorScheme.primary : Color(0x99666666), width: 1.3,),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _categoryItems[_selectCategory].title ?? "",
                style: TextStyle(color:_categoryItems[_selectCategory].id == 0  ? Colors.grey : Colors.black, fontWeight: FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down_outlined)
          ],
        ),
      ),
      // カテゴリボタンを押した時のプルダウンボタン
      onTap: () => pullDownVoid(),
    );
  }

  Widget titleWidget() {
    return Container(
      height: 60,
      child: Center(
        child: TextField(
          controller: titleController,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context).title,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        ),
      ),
    );
  }

  Widget moneyWidget() {
    return Padding(
      padding: App.padding,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 1,),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: CustomKeyboardTextField(),)
          ]
      ),
    );
  }

  Widget memoWidget() {
    return Padding(
      padding: App.padding,
      child: TextField(
        controller: memoController,
        minLines: 5,
        maxLength: 1000,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).memo,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0)),
        ),
        maxLines: null,
      ),
    );
  }

  Widget dustButton() {
    if (widget.inputMode == InputMode.edit) {
      return Container(
        padding: EdgeInsets.only(top: 10),
        alignment: Alignment.bottomRight,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: Icon(Icons.delete, color: Colors.white,size: 20,)
          ),
          label: Text(
            AppLocalizations.of(context).delete,
            style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
          ),
          onPressed: _isDisabled ? null : () async {
            bool result = await showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text("確認", style: TextStyle(fontFamily: "Noto Sans JP")),
                    content: Text("削除します。よろしいですか？", style: TextStyle(fontFamily: "Noto Sans JP")),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('キャンセル'),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      CupertinoDialogAction(
                        child: Text('削除'),
                        isDestructiveAction: true,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  );
                }
            );
            if (result) {
              _delete(widget.calendar?.id ?? 0); // TODO [widget.calendarId ?? 0]ではない
              handleBack(context,'削除に成功しました。');
              setState(() {});
            }
          },
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // プルダウン
  void pullDownVoid() {
    TextStyle cyanTextStyle = TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: "Noto Sans JP");
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState1) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  border: Border(bottom: BorderSide(color: Color(0xff999999), width: 0.0,),),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.of(context).edit,
                        style: cyanTextStyle,
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return CategoryPage(moneyValue: moneyValue);
                            },
                          ),
                        );
                        updateListViewCategory(moneyValue == MoneyValue.income);
                        setState1(() {});
                      },
                    ),
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.of(context).close,
                        style: cyanTextStyle,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Container(
                color: Color(0xffffffff),
                height: MediaQuery.of(context).size.height / 2,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: CupertinoActionSheet(
                    actions: _categoryItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return CupertinoUserInterfaceLevel(
                        data: CupertinoUserInterfaceLevelData.base,
                        child: CupertinoActionSheetAction(
                          onPressed: () {
                            _selectCategory = index;
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: _pickerItem(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}