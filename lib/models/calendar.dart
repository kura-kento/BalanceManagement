import 'package:intl/intl.dart';

class Calendar {

  int? id;
  double? money;
  String? title;
  String? memo;
  DateTime? date;
  int? categoryId;

  Calendar(this.money, this.title, this.memo, this.date, this.categoryId);

  Calendar.withId(this.id, this.money, this.title, this.memo, this.date, this.categoryId);

  // int get id => _id;
  // double get money => _money;
  // String get title => _title;
  // String get memo => _memo;
  // DateTime get date => _date;
  // int get categoryId => _categoryId;

  // set money(double newMoney) {
  //   print(newMoney);
  //   if ( newMoney.toString().length <=  6 ){
  //     this.money = newMoney;
  //   }
  // }
  //
  // set title(String newTitle) {
  //   if (newTitle.length <= 255) {
  //     this.title = newTitle;
  //   }
  // }
  //
  // set memo(String newMemo) {
  //   if (newMemo.length <= 255) {
  //     this.memo = newMemo;
  //   }
  // }
  //
  // set date(DateTime newDate) {
  //   this.date = newDate;
  // }
  //
  // set categoryId(int newCategoryId) {
  //     this.categoryId = newCategoryId;
  // }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['money'] = money;
    map['title'] = title;
    map['memo'] = memo;
    map['date'] = DateFormat('yyyy-MM-dd HH:mm').format(date!);
    map['categoryId'] = categoryId;
return map;
}

// MapオブジェクトからCalendarオブジェクトを抽出する
Calendar.fromMapObject(Map<String, dynamic> map) {
//    print(map);
    this.id = map['id'];
    this.money = map['money'];
    this.title = map['title'];
    this.memo = map['memo'];
    this.date = DateTime.parse(map['date']);
    this.categoryId = map['categoryId'];
    }
}
