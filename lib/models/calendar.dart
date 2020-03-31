import 'package:intl/intl.dart';

class Calendar {

  int _id;
  int _money;
  String _title;
  String _memo;
  DateTime _date;

  Calendar(this._money, this._title, this._memo, this._date);

  Calendar.withId(this._id, this._money, this._title, this._memo, this._date);

  int get id => _id;

  int get money => _money;

  String get title => _title;

  String get memo => _memo;

  DateTime get date => _date;

  set money(int newMoney) {
    if ( newMoney.toString().length <=  7 ){
      this._money = newMoney;
    }
  }

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set memo(String newMemo) {
    if (newMemo.length <= 255) {
      this._memo = newMemo;
    }
  }

  set date(DateTime newDate) {
    this._date = newDate;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {};

    map['id'] = _id;
    map['money'] = _money;
    map['title'] = _title;
    map['memo'] = _memo;
    map['date'] = DateFormat('yyyy-MM-dd HH:mm').format(_date);

    return map;
  }

  // MapオブジェクトからCalendarオブジェクトを抽出する
  Calendar.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._money = map['money'];
    this._title = map['title'];
    this._memo = map['memo'];
    this._date = DateTime.parse(map['date']);
  }
}
