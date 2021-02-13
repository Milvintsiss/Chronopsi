import 'package:flutter/foundation.dart';

class MailLauncher{
  String emailAddress;
  String subject;
  String body;

  MailLauncher({@required this.emailAddress, this.subject, this.body});

  @override
  String toString() {
    String emailUrl = 'mailto:$emailAddress?';
    if(subject != null)
      emailUrl += 'subject=${_encodeMore(Uri.encodeComponent(subject))}&';
    if(body != null)
      emailUrl += 'body=${_encodeMore(Uri.encodeComponent(body))}&';
    return emailUrl;
  }
}

String _encodeMore(String string){
  return string.replaceAll('\'', '%27').replaceAll('(', '%28').replaceAll(')', '%29').replaceAll('.', '%2E');
}