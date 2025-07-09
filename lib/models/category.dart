
class Category {

  int? id;
  String? title;
  bool? plus;


  Category(this.title, this.plus);

  Category.withId(this.id, this.title, this.plus);

  // int get id => id;
  //
  // String get title => title;
  //
  // bool get plus => plus;
  //
  // set title(String newTitle) {
  //   if ( newTitle.length <=  20 ){
  //     this.title = newTitle;
  //   }
  // }
  //
  // set plus(bool newPlus) {
  //     this.plus = newPlus;
  // }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {};

    map['id'] = id;
    map['title'] = title;
    map['plus'] = plus.toString();

    return map;
  }

  // Mapオブジェクトからオブジェクトを抽出する
  Category.fromMapObject(Map<String, dynamic> map) {
    //print(map);
    this.id = map['id'];
    this.title = map['title'];
    this.plus = map['plus'] == "true" ? true:false;
  }
}
