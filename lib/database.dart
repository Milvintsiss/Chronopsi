import 'dart:convert';

import 'package:http/http.dart' as http;

import 'day.dart';

const String url = "http://edtmobilite.wigorservices.net/WebPsDyn.aspx?Action=posETUD&serverid=h&tel=";
class Database {
  Future<Day> getDay(String firstNameLastName, String date, {String time = "8:00"}) async {
    final res = await http.get(
      url + "$firstNameLastName" + "&date=$date" + "%20$time",
    );
    return Day(res.body);
  }
}