import 'package:http/http.dart' as http;

import 'day.dart';

const String url =
    "http://edtmobilite.wigorservices.net/WebPsDyn.aspx?Action=posETUD&serverid=h&tel=";

class Database {
  Future<Day> getDay(String firstNameLastName, String date,
      {String time = "8:00"}) async {
    final res = await http.get(
        url + "$firstNameLastName" + "&date=$date" + "%20$time",
        headers: <String, String>{
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, OPTIONS, PUT, PATCH, DELETE',
          'Access-Control-Allow-Headers':
              'Access-Control-Allow-Origin, Access-Control-Allow-Methods, Access-Control-Request-Method, Access-Control-Request-Headers, Access-Control-Allow-Headers,Origin, X-Requested-With, Content-Type, Accept, Authorization'
        });
    return Day(res.body);
  }


  String convertDateTimeToMMJJAAAAString(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}
