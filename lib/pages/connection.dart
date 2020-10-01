import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vge/pages/home.dart';

class Connection extends StatefulWidget {
  Connection({Key key}) : super(key: key);

  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  final _formKey = new GlobalKey<FormState>();

  String firstName;
  String lastName;
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  void initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          showInput('firstName', Icons.drive_file_rename_outline),
          showInput('lastName', Icons.drive_file_rename_outline),
          showSaveButton(),
        ],
      ),
    );
  }

  Widget showInput(String inputType, IconData icon) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
      child: new TextFormField(
        style: TextStyle(color: Theme.of(context).primaryColorLight),
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            fillColor: Theme.of(context).primaryColor,
            hintText: inputType == 'firstName' ? "Prénom" : "Nom",
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
        onSaved: (value) {
          switch (inputType) {
            case "firstName":
              firstName = value.trim().toLowerCase();
              break;
            case "lastName":
              lastName = value.replaceAll(" ", "").toLowerCase();
              break;
          }
        },
      ),
    );
  }

  Widget showSaveButton() {
    return RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        color: Theme.of(context).primaryColor,
        child: Text(
          "Sauvegarder",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            String logIn = "$firstName.$lastName";
            sharedPreferences.setString('logIn', logIn);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Home(
                          logIn: logIn,
                        )));
          }
        });
  }
}
