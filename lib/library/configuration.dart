import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vge/local_database.dart';
import 'package:vge/local_moor_database.dart';

const bool IS_DARK_THEME_DEFAULT_VALUE = true;
const bool CONCATENATE_SIMILAR_LESSONS_DEFAULT_VALUE = true;
const bool CLEAN_DISPLAY_DEFAULT_VALUE = true;
const int CACHE_KEEPING_DURATION_DEFAULT_VALUE = 3;

class Configuration{
  bool isDarkTheme;
  String logIn;
  bool concatenateSimilarLessons;
  bool cleanDisplay;
  int cacheKeepingDuration;

  SharedPreferences sharedPreferences;
  LocalDatabase localDatabase;
  LocalMoorDatabase localMoorDatabase;
  int countKey;
  PackageInfo packageInfo;
}