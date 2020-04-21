
class Category {

  int _id;
  String _title;
  bool _plus;


  Category(this._title, this._plus);

  Category.withId(this._id, this._title, this._plus);

  int get id => _id;

  String get title => _title;

  bool get plus => _plus;

  set title(String newTitle) {
    if ( newTitle.length <=  20 ){
      this._title = newTitle;
    }
  }

  set plus(bool newPlus) {
      this._plus = newPlus;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {};

    map['id'] = _id;
    map['title'] = _title;
    map['plus'] = _plus.toString();

    return map;
  }

  // Mapオブジェクトからオブジェクトを抽出する
  Category.fromMapObject(Map<String, dynamic> map) {
    //print(map);
    this._id = map['id'];
    this._title = map['title'];
    this._plus = map['plus'] == "true" ? true:false;
  }
}
