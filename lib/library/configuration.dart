import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuration{
  bool isDarkTheme;
  String logIn;
  bool concatenateSimilarLessons;

  SharedPreferences sharedPreferences;
  PackageInfo packageInfo;
}