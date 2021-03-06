import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as p;

import 'library/configuration.dart';
import 'library/myLearningBox_helper.dart';

const String urlMyLearningBox = 'https://mylearningbox.reseau-cd.fr';

Future<List<Grade>> getGradesFromMyLearningBox(
    Configuration configuration) async {
  List<Grade> grades = [];

  Dio dio = Dio();

  String sessionId =
      configuration.sharedPreferences.getString(sessionIdMyLearningBoxKey);
  Map<String, String> headers = addSessionIdToHeaders({}, sessionId);

  var res = await dio.get('$urlMyLearningBox/grade/report/overview/index.php',
      options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          }));

  if (res.headers['location'] != null &&
      res.headers['location'][0] ==
          'https://mylearningbox.reseau-cd.fr/login/index.php') {
    print('Not logged in.');
    await connectToMyLearningBox(
        configuration, configuration.logIn, configuration.password);
    return getGradesFromMyLearningBox(configuration);
  }

  Document document = p.parse(res.data);
  document.getElementsByTagName('tbody')[0].children.forEach((element) {
    grades.add(Grade(
      label: element.getElementsByTagName('a')[0].innerHtml.trim(),
      value: element.querySelectorAll('.c1')[0].innerHtml,
      rank: element.querySelectorAll('.c2')[0].innerHtml,
      link: element
          .getElementsByTagName('a')[0]
          .outerHtml
          .split('href="')[1]
          .split('">')[0].replaceAll('&amp;', '&'),
    ));
  });
  return grades;
}

Future<bool> connectToMyLearningBox(
    Configuration configuration, String logIn, String password) async {
  Dio dio = Dio();

  //getting connection token and sessionID of connection
  var res = await dio.get('$urlMyLearningBox/login/index.php',
      options: Options(responseType: ResponseType.bytes));

  Document document = p.parse(res.data);
  String loginToken = document
      .getElementById('login')
      .children[6]
      .outerHtml
      .split("value=\"")
      .last
      .replaceAll("\">", "");

  Map<String, String> formMap = {
    'username': logIn,
    'password': password,
    'logintoken': loginToken
  };

  Map<String, String> responseHeaders =
      convertMapOfStringAndListOfStringToMapOfStringAndString(res.headers.map);
  String sessionId = getSessionIdFromResponseHeaders(responseHeaders);
  Map<String, String> headers = addSessionIdToHeaders({}, sessionId);
  print("Login token: $loginToken");
  print("SessionId: $sessionId");

  //attempt to get the user token and the sessionID
  res = await dio.post(
    '$urlMyLearningBox/login/index.php',
    data: FormData.fromMap(formMap),
    options: Options(
        contentType: "application/x-www-form-urlencoded",
        headers: headers,
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        }),
  );

  if (res.headers.map['location'][0] == '$urlMyLearningBox/login/index.php') {
    print("Login or password is wrong");
    return false;
  }

  responseHeaders =
      convertMapOfStringAndListOfStringToMapOfStringAndString(res.headers.map);
  sessionId = getSessionIdFromResponseHeaders(responseHeaders);
  headers = addSessionIdToHeaders({}, sessionId);

  String token = responseHeaders['location'].split('=')[1];
  print("User token: $token");
  print("SessionId: $sessionId");

  //attempt to validate the sessionID
  res = await dio.get('$urlMyLearningBox/login/index.php',
      queryParameters: {'testsession': token},
      options: Options(
          headers: headers,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          }));

  responseHeaders =
      convertMapOfStringAndListOfStringToMapOfStringAndString(res.headers.map);
  if (responseHeaders.containsKey('location') &&
      responseHeaders['location'] == '$urlMyLearningBox/my/') {
    configuration.sharedPreferences.setString(tokenMyLearningBoxKey, token);
    configuration.sharedPreferences
        .setString(sessionIdMyLearningBoxKey, sessionId);
    print("Connection successful!");
    return true;
  } else {
    print("An error as occurred");
    return false;
  }
}

String getSessionIdFromResponseHeaders(Map<String, String> responseHeaders) {
  String rawCookie = responseHeaders['set-cookie'];
  int index = rawCookie.indexOf(';');
  return (index == -1) ? rawCookie : rawCookie.substring(0, index);
}

Map<String, String> addSessionIdToHeaders(
    Map<String, String> headers, String sessionId) {
  headers['Cookie'] = sessionId;
  return headers;
}

Map<String, String> convertMapOfStringAndListOfStringToMapOfStringAndString(
    Map<String, List<String>> mapOfStringAndListOfString) {
  Map<String, String> mapOfStringAndString = {};
  mapOfStringAndListOfString.forEach((key, value) {
    mapOfStringAndString.addAll({key: value[0]});
  });
  return mapOfStringAndString;
}
