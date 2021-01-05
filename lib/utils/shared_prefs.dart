import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {

  static final unit = 'unit';
  static final tapIndex = 'tapTitle';
  static final loginCount = 'loginCount';
  static final adPositionTop = 'adPositionTop';

  static SharedPreferences _sharedPreferences;

  static Future<void> setInstance() async {
    if (null != _sharedPreferences) return;
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setUnit(String value) => _sharedPreferences.setString(unit, value);
  static String getUnit() => _sharedPreferences.getString(unit) ?? '円';
  //static Future<void> removeUnit() => _sharedPreferences.remove(unit);

  static Future<bool> setLoginCount(int value) => _sharedPreferences.setInt(loginCount, value);
  static int getLoginCount() => _sharedPreferences.getInt(loginCount) ?? 0;

  static Future<bool> setTapIndex(String value) => _sharedPreferences.setString(tapIndex, value);
  static String getTapIndex() => _sharedPreferences.getString(tapIndex) ?? "both";

  static Future<bool> setAdPositionTop(bool value) => _sharedPreferences.setBool(adPositionTop, value);
  static bool getAdPositionTop() => _sharedPreferences.getBool(adPositionTop) ?? true;
  //admob用コード
//  static final clickTime = 'clickTime';
//
//  static Future<bool> setClickTime(String value) => _sharedPreferences.setString(clickTime, value);
//  static String getClickTime() => _sharedPreferences.getString(clickTime) ?? "2020-04-10 00:00:00";

}
