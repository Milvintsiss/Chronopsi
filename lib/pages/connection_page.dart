import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:vge/library/configuration.dart';
import 'package:vge/pages/home_page.dart';

class LogInPage extends StatefulWidget {
  LogInPage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = new GlobalKey<FormState>();

  String firstName;
  String lastName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: body(),
    );
  }

  Widget body() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          showInput('firstName', Icons.drive_file_rename_outline, "Prénom",
              TextInputAction.next,
              onSaved: (value) =>
                  firstName = value.replaceAll(" ", "").toLowerCase()),
          showInput('lastName', Icons.drive_file_rename_outline, "Nom",
              TextInputAction.done,
              onSaved: (value) =>
                  lastName = value.replaceAll(" ", "").toLowerCase()),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          showSaveButton(),
        ],
      ),
    );
  }

  Widget showInput(String inputType, IconData icon, String label,
      TextInputAction textInputAction,
      {@required Function onSaved}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
      child: new TextFormField(
        style: TextStyle(color: Theme.of(context).primaryColorLight),
        maxLines: 1,
        keyboardType: TextInputType.name,
        textInputAction: textInputAction,
        autofocus: false,
        decoration: new InputDecoration(
            fillColor: Theme.of(context).primaryColor,
            hintText: label,
            hintStyle: TextStyle(color: Theme.of(context).primaryColorDark),
            filled: true,
            contentPadding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(12.0),
            ),
            icon: new Icon(
              icon,
              color: Theme.of(context).primaryColorLight,
            )),
        validator: (value) {
          return value.isEmpty ? "Vous n'avez pas renseigné ce champ!" : null;
        },
        onSaved: onSaved,
        onFieldSubmitted: textInputAction == TextInputAction.done ? (value) => save() : null,
      ),
    );
  }

  Widget showSaveButton() {
    return RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        color: Theme.of(context).primaryColor,
        padding: Platform.isWindows
            ? EdgeInsets.symmetric(vertical: 17, horizontal: 30)
            : EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        child: Text(
          "Sauvegarder",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
        onPressed: save,
    );
  }

  void save(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      widget.configuration.logIn =
          removeDiacritics("$firstName.$lastName");
      widget.configuration.sharedPreferences
          .setString('logIn', widget.configuration.logIn);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                configuration: widget.configuration,
              )));
    }
  }
}
