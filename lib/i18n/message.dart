import 'package:flutter/material.dart';

class Messages
{
  Messages({
    @required this.space,
    @required this.monday,
    @required this.tuesday,
    @required this.wednesday,
    @required this.thursday,
    @required this.friday,
    @required this.saturday,
    @required this.sunday,
    
    @required this.annualTotal,
    @required this.monthlyTotal,
    @required this.monthlyTotalPlus,
    @required this.monthlyTotalMinus,

    @required this.plus,
    @required this.minus,
    @required this.title,
    @required this.income,
    @required this.save,
    @required this.calendar,
    @required this.graph,
    @required this.setting,
    @required this.memo,
    @required this.totalValue,
    @required this.done,

    @required this.edit,
    @required this.spending,
    @required this.newAdditionPage,
    @required this.editPage,
    @required this.update,
    @required this.categoryEditing,
    @required this.addPosition,
    @required this.unit,
    @required this.top,
    @required this.bottom,
    @required this.changeTo,
    @required this.deleteAllBalancedata,

    @required this.deleteAllDialog,
    @required this.delete,
    @required this.cancel,
    @required this.wednesday1,
    
    @required this.weekAgo,
    @required this.weekLater,
  });

  final String space;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;

  final String calendar;
  final String graph;
  final String annualTotal;
  final String monthlyTotal;
  final String monthlyTotalPlus;
  final String monthlyTotalMinus;
  final String plus;
  final String minus;
  final String title;
  final String income;
  final String save;
  final String setting;
  final String memo;
  final String totalValue;
  final String done;

  final String edit;
  final String spending;
  final String newAdditionPage;
  final String editPage;
  final String update;
  final String categoryEditing;
  final String addPosition;
  final String unit;
  final String top;
  final String bottom;
  final String changeTo;
  final String deleteAllBalancedata;

  final String deleteAllDialog;
  final String delete;
  final String cancel;
  final String wednesday1;

  final String Function(int) weekAgo;
  final String Function(int) weekLater;

  factory Messages.of(Locale locale)
  {
    switch (locale.languageCode) {
      case 'ja':
        return Messages.ja();
      case 'en':
        return Messages.en();
      default:
        return Messages.en();
    }
  }

  factory Messages.ja() => Messages(
  //カレンダーページ
    space: '（空白）',
    monday: '月',
    tuesday: '火',
    wednesday: '水',
    thursday: '木',
    friday: '金',
    saturday: '土',
    sunday: '日',

    annualTotal: '年合計',
    monthlyTotal: '月合計',
    monthlyTotalPlus: '年合計（プラス）',
    monthlyTotalMinus: '月合計（マイナス）',
  //編集ページ
    plus: 'プラス',
    minus: 'マイナス',
    title: 'タイトル',
    income: '収入',
    spending: '支出',
    save: '保存',
    calendar: 'カレンダー',
    graph: 'グラフ',
    setting: '設定',
    memo: 'メモ',
    totalValue: '合計値：月',
    done: '決定',
    edit: '編集',
    newAdditionPage: '新規追加ページ',
    editPage: '編集ページ',
    update: '更新',
    categoryEditing: 'カテゴリー編集',

    addPosition: '広告の位置',
    unit: '単位',

    top: '上',
    bottom: '下',
    changeTo: 'に変更',
    deleteAllBalancedata: '収支データの全削除',

    deleteAllDialog: '全ての収支データを削除しますか？',
    delete: '削除',
    cancel: 'キャンセル',
    wednesday1: '水',

    weekAgo: (day) => '$day週間前の日記',
    weekLater: (day) => '$day週間後の日記',
  );

  factory Messages.en() => Messages(
    space: ' (Blank)',
    monday: 'Mo.',
    tuesday: 'Tu.',
    wednesday: 'We.',
    thursday: 'Th.',
    friday: 'Fr.',
    saturday: 'Sa.',
    sunday: 'Su.',
    calendar: 'calendar',
    graph: 'graph',
    annualTotal: 'Annual total',
    monthlyTotal: 'Monthly total',
    monthlyTotalPlus: 'Monthly total (+)',
    monthlyTotalMinus: 'Monthly total (-)',
    plus: 'plus',
    minus: 'minus',
    title: 'title',
    income: 'income',
    spending: 'spending',
    save: 'Save',
    setting: 'Setting',
    memo: 'memo',
    totalValue: 'Total value: Month',
    done: 'done',
    edit: 'edit',
    newAdditionPage: 'newAdditionPage',
    editPage: 'editPage',
    update: 'update',
    categoryEditing: 'Category editing',

    addPosition: 'Advertisement position',
    unit: 'unit',

    top: 'top',
    bottom: 'bottom',
    changeTo: 'change to',
    deleteAllBalancedata: 'Delete all balance data',

    deleteAllDialog: 'Do you want to delete all balance data?',
    delete: 'Delete',
    cancel: 'Cancel',
    wednesday1: 'We.',

    weekAgo: (day) => 'Diary $day weeks ago',
    weekLater: (day) => 'Diary after $day weeks',
  );
}

class AppLocalizations
{
  final Messages messages;

  AppLocalizations(Locale locale): this.messages = Messages.of(locale);

  static Messages of(BuildContext context)
  {
    return Localizations.of<AppLocalizations>(context, AppLocalizations).messages;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>
{
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}