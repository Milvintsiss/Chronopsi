import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const contactMail = 'contact@milvintsiss.com';

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

class ClickableTextSpan extends WidgetSpan {
  ClickableTextSpan({
    @required String text,
    @required Function onTap,
    TextStyle style,
  }) : super(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text.rich(TextSpan(
            text: text,
            style: style ??
                TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()..onTap = onTap)),
      ));
}