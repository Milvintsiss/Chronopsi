
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuration{
  bool isDarkTheme;
  String logIn;
  bool concatenateSimilarLessons;
  bool cleanDisplay;

  SharedPreferences sharedPreferences;
  int countKey;
  PackageInfo packageInfo;
}