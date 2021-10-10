import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const unit = 'unit';
  static const tapIndex = 'tapTitle';
  static const loginCount = 'loginCount';
  static const adPositionTop = 'adPositionTop';
  static const isPassword = 'isPassword';
  static const password = 'password';

  static SharedPreferences _sharedPreferences;

  static Future<void> setInstance() async {
    if (null != _sharedPreferences)
      return;
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setUnit(String value) => _sharedPreferences.setString(unit, value);
  static String getUnit() => _sharedPreferences.getString(unit) ?? '円';
  //static Future<void> removeUnit() => _sharedPreferences.remove(unit);

  static Future<bool> setLoginCount(int value) => _sharedPreferences.setInt(loginCount, value);
  static int getLoginCount() => _sharedPreferences.getInt(loginCount) ?? 0;

  static Future<bool> setTapIndex(String value) => _sharedPreferences.setString(tapIndex, value);
  static String getTapIndex() => _sharedPreferences.getString(tapIndex) ?? 'both';

  static Future<bool> setAdPositionTop(bool value) => _sharedPreferences.setBool(adPositionTop, value);
  static bool getAdPositionTop() => _sharedPreferences.getBool(adPositionTop) ?? true;

  static Future<bool> setIsPassword(bool value) => _sharedPreferences.setBool(isPassword, value);
  static bool getIsPassword() => _sharedPreferences.getBool(isPassword) ?? false;
  //
  static Future<bool> setPassword(String value) => _sharedPreferences.setString(password, value);
  static String getPassword() => _sharedPreferences.getString(password) ?? '0000';
}
