
class Category {

  int _id;
  String _spending;
  String _income;

  Category(this._income, this._spending);

  Category.withId(this._id, this._income, this._spending);

  int get id => _id;

  String get income => _income;

  String get spending => _spending;

  set income(String newIncome) {
    if ( newIncome.length <=  20 ){
      this._income = newIncome;
    }
  }

  set spending(String newSpending) {
    if ( newSpending.length <=  20 ){
      this._income = newSpending;
    }
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {};

    map['id'] = _id;
    map['income'] = _income;
    map['spending'] = _spending;

    return map;
  }

  // MapオブジェクトからCalendarオブジェクトを抽出する
  Category.fromMapObject(Map<String, dynamic> map) {
    //print(map);
    this._id = map['id'];
    this._income = map['income'];
    this._spending = map['spending'];
  }
}
