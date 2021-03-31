import 'package:flutter_app/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPrefs {
  static void putString(Keys key, String value) {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    _prefs.then((SharedPreferences prefs) {
      prefs.setString(key.toString(), value);
    });
  }

  static void putBoolean(Keys key, bool value) {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    _prefs.then((SharedPreferences prefs) {
      prefs.setBool(key.toString(), value);
    });
  }

  static Future<String> getString(Keys key) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var value = _prefs.getString(key.toString());
    if (value == null)
      return "";
    else
      return value;
  }

  static Future<bool> getBoolean(Keys key) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var value = _prefs.getBool(key.toString());
    if (value == null)
      return false;
    else
      return value;
  }

  static Future<bool> clearPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.clear();
  }
}
