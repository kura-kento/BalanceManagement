import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {

  static final unit = 'unit';
  static final tapIndex = 'tapTitle';

  static SharedPreferences _sharedPreferences;

  static Future<void> setInstance() async {
    if (null != _sharedPreferences) return;
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setUnit(String value) => _sharedPreferences.setString(unit, value);
  static String getUnit() => _sharedPreferences.getString(unit) ?? '円';
  //static Future<void> removeUnit() => _sharedPreferences.remove(unit);



  static Future<bool> setTapIndex(String value) => _sharedPreferences.setString(tapIndex, value);
  static String getTapIndex() => _sharedPreferences.getString(tapIndex) ?? "both";
}
