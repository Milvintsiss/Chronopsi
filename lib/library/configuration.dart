import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chronopsi/local_database.dart';
import 'package:chronopsi/local_moor_database.dart';

const bool CONCATENATE_SIMILAR_LESSONS_DEFAULT_VALUE = true;
const bool CLEAN_DISPLAY_DEFAULT_VALUE = true;
const int CACHE_KEEPING_DURATION_DEFAULT_VALUE = 3;

const String logInKey = 'logIn';
const String passwordKey = 'password';
const String tokenMyLearningBoxKey = 'tokenMyLearningBox';
const String sessionIdMyLearningBoxKey = 'sessionIdMyLearningBox';
const String cacheKeepingDurationKey = 'cacheKeepingDuration';
const String cleanDisplayKey = 'cleanDisplay';
const String concatenateSimilarLessonsKey = 'concatenateSimilarLessons';

class Configuration{
  bool isDarkTheme;
  String logIn;
  String password;
  bool concatenateSimilarLessons;
  bool cleanDisplay;
  int cacheKeepingDuration;

  SharedPreferences sharedPreferences;
  LocalDatabase localDatabase;
  LocalMoorDatabase localMoorDatabase;
  PackageInfo packageInfo;
}