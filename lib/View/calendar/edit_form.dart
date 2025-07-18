import 'package:balancemanagement_app/Common/Admob/admob_banner.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/Common/Admob/admob.dart';
import 'package:balancemanagement_app/models/DB/database_help.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:balancemanagement_app/Common/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../../Common/app.dart';
import 'calendar_page.dart';
import 'category_form.dart';

enum InputMode{
  create,
  edit
}

class EditForm extends ConsumerStatefulWidget {
  EditForm({Key? key, this.calendar, required this.inputMode, required this.parentFn}) : super(key: key);
  final Function parentFn;
  final Calendar? calendar;
  final InputMode inputMode;

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends ConsumerState<EditForm> {
  final BannerAd myBanner = AdMob.admobBanner();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = [];
  List<Category> categoryList = [];
  bool _isDisabled = false;
  MoneyValue moneyValue = MoneyValue.income;

  List<Category> _categoryItems =[Category.withId(0, "（空白）", true)];
  int _selectCategory = 0;

  late TextEditingController titleController;
  TextEditingController priceController = TextEditingController(text: '0');
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
    // print(widget.calendar?.toMap());

    // プラスかマイナスか？
    if (widget.inputMode == InputMode.edit) { // 編集
      moneyValue = calendarMoney >= 0 ? MoneyValue.income : MoneyValue.spending;
    } else { // 新規の場合は前回のボタンを同じにする
      moneyValue = SharedPrefs.getIsPlusButton() ? MoneyValue.income : MoneyValue.spending;
    }

    titleController = TextEditingController(text: '${widget.calendar?.title}');
    memoController = TextEditingController(text: '${widget.calendar?.memo}');

    //編集フォームでドロップダウンの位置決め
    List<Category>_categoryItems = await updateListViewCategory(moneyValue == MoneyValue.income);
    List<int> _category = _categoryItems.map((category) => category.id ?? 0).toList();
    _selectCategory = _category.indexOf(widget.calendar?.categoryId ?? 0);
    scrollController = FixedExtentScrollController(initialItem: _selectCategory);

    // 描画完了後？
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // カテゴリーのプルダウンの位置
      var moneyText = '${Utils.formatNumber(calendarMoney  * (calendarMoney < 0 ? -1:1 ))}';
      priceController = TextEditingController(text: moneyText);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // if (FocusScope.of(context).hasFocus) {
    //   FocusScope.of(context).requestFocus(new FocusNode());
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    selectDay = ref.watch(selectDayProvider);

    return Container(
      color: App.bgColor,
      child: SafeArea(
        child: BannerBody(
          child: Scaffold(
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
                          onPressed: () => moveToLastScreen(),
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
                        child: dustButton(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      child: ListView(
                        children: <Widget>[
                          Row(children: btnPlusMinus()),
                          Padding(
                            padding: App.padding,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(left: 10),
                                      height: 55,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: false ? Theme.of(context).colorScheme.primary : Color(0x99666666), width: 1.3,),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(_categoryItems[_selectCategory].title ?? "", style: TextStyle(fontWeight: FontWeight.normal),),
                                    ),
                                    // カテゴリボタンを押した時のプルダウンボタン
                                    onTap: () {
                                      pullDownVoid();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: TextField(
                                      controller: titleController,
                                      decoration: InputDecoration(
                                          labelText: AppLocalizations.of(context).title,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /*
                          * 金額　フォーム
                          */
                          Padding(
                            padding: App.padding,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Spacer(flex: 1,),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      //autofocus: true,
                                        controller: priceController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,}'))
                                        ],
                                        decoration: InputDecoration(
                                            labelText: moneyValue == MoneyValue.income
                                                ?
                                            AppLocalizations.of(context).income
                                                :
                                            AppLocalizations.of(context).spending,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            )
                                        )
                                    ),
                                  )
                                ]),
                          ),
                          Padding(
                              padding: App.padding,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Theme.of(context).primaryColorDark,
                                  foregroundColor: Theme.of(context).primaryColorLight,
                                ),
                                child: Text(
                                  AppLocalizations.of(context).save,
                                  textScaleFactor: 1.5,
                                ),
                                onPressed: _isDisabled ? null : () {
                                  setState(() => _isDisabled = true);
                                  _save();
                                  moveToLastScreen();
                                  widget.parentFn('保存に成功しました');
                                  // setState(() {});
                                },
                              ),
                          ),
                          Padding(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> btnPlusMinus() {
    List<Widget> _list = [];
    [MoneyValue.income,MoneyValue.spending].asMap().forEach((index,element) {
      if(index == 1) {
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

 moveToLastScreen() async {
    //
    // await new Future.delayed(new Duration(microseconds: 3000));
    Future.delayed(Duration(milliseconds: 1000))
        .then((_) {
      FocusScope.of(context).unfocus();
      Navigator.pop(context);
    });
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
    return Center(
      child: Text(
        category.title ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 32),
      ),
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

    // List<Category> _categoryList = await DatabaseHelper().getCategoryList(calendarMoney >= 0);
    // List<int> _category = _categoryList.map((category) => category.id ?? 0).toList();
    // _selectCategory = _category.indexOf(widget.calendar?.categoryId ?? 0)+1;
    // scrollController = FixedExtentScrollController(initialItem: _selectCategory);
  }

  Widget dustButton() {
    if(widget.inputMode == InputMode.edit) {
      return IconButton(
        onPressed: () {
          _delete(widget.calendar?.id ?? 0); // TODO [widget.calendarId ?? 0]ではない
          moveToLastScreen();
          setState(() {});
        },
        icon: Icon(Icons.delete),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // プルダウン
  void pullDownVoid() {
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
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xff999999),
                      width: 0.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.of(context).edit,
                        style: TextStyle(color: Colors.cyan),
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
                        AppLocalizations.of(context).done,
                        style: TextStyle(color: Colors.cyan),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                color: Color(0xffffffff),
                height: MediaQuery.of(context).size.height / 3,
                child: CupertinoPicker(
                    scrollController: scrollController,
                    diameterRatio: 1.0,
                    itemExtent: 40.0,
                    children: _categoryItems.map(_pickerItem).toList(),
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _selectCategory = index;
                      });
                    }),
              ),
            ],
          );
        });
      },
    );
  }
}