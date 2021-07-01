import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:chronopsi/library/configuration.dart';
import 'package:chronopsi/myLearningBoxAPI.dart';
import 'package:chronopsi/pages/home_page.dart';
import 'package:vibration/vibration.dart';

import '../API.dart';

class LogInPage extends StatefulWidget {
  LogInPage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = new GlobalKey<FormState>();

  bool isLoading = false;

  String firstName;
  String lastName;
  String password;

  @override
  void initState() {
    if (widget.configuration.logIn != null) {
      firstName = widget.configuration.logIn.split('.')[0];
      lastName = widget.configuration.logIn.split('.')[1];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [showInfoButton()],
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
              ),
              appLogo(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              showInput(
                  firstName,
                  TextInputType.name,
                  Icons.drive_file_rename_outline,
                  "Prénom",
                  TextInputAction.next,
                  onSaved: (value) => firstName =
                      value.trim().replaceAll(" ", "").toLowerCase()),
              showInput(lastName, TextInputType.name,
                  Icons.drive_file_rename_outline, "Nom", TextInputAction.next,
                  onSaved: (value) => lastName =
                      value.trim().replaceAll(" ", "").toLowerCase()),
              showInput(null, TextInputType.text, MdiIcons.shieldKeyOutline,
                  "Mot de passe EPSI/WIS", TextInputAction.done,
                  isPassword: true, onSaved: (value) => password = value),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              showSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget appLogo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 + 20,
      child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          padding: EdgeInsets.all(20),
          child: Image.asset('assets/appLogo/logo.png')),
    );
  }

  Widget showInput(String initialValue, TextInputType textInputType,
      IconData icon, String label, TextInputAction textInputAction,
      {@required Function onSaved, bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
      child: Column(
        children: [
          new TextFormField(
            style: TextStyle(color: Theme.of(context).primaryColorLight),
            maxLines: 1,
            initialValue: initialValue,
            keyboardType: textInputType,
            textInputAction: textInputAction,
            autofocus: false,
            obscureText: isPassword,
            enableSuggestions: !isPassword,
            autocorrect: !isPassword,
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
              return value.isEmpty && !isPassword
                  ? "Vous n'avez pas renseigné ce champ!"
                  : null;
            },
            onSaved: onSaved,
            onFieldSubmitted: textInputAction == TextInputAction.done
                ? (value) => save()
                : null,
          ),
          if (isPassword)
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                "Le mot de passe n'est pas obligatoire pour accéder "
                "à l'emploi du temps et au calendrier.",
                style: TextStyle(fontSize: 10),
              ),
            )
        ],
      ),
    );
  }

  Widget showSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        primary: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
      ),
      child: isLoading
          ? SizedBox(height: 17, width: 17, child: CircularProgressIndicator())
          : Text(
              "Sauvegarder",
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
      onPressed: save,
    );
  }

  void save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String logIn = removeDiacritics("$firstName.$lastName");
      setState(() => isLoading = true);
      if (await isLogInValid(logIn)) {
        if (password != null &&
            password != '' &&
            !await connectToMyLearningBox(
                widget.configuration, logIn, password)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Mot de passe incorrect",
              style: TextStyle(color: Colors.red),
            ),
          ));
          if ((Platform.isAndroid || Platform.isIOS) &&
              await Vibration.hasVibrator()) Vibration.vibrate();
          _formKey.currentState.reset();
          setState(() => isLoading = false);
          return null;
        }
        widget.configuration.logIn = logIn;
        widget.configuration.password = password != '' ? password : null;
        widget.configuration.sharedPreferences
            .setString(logInKey, widget.configuration.logIn);
        widget.configuration.password != null
            ? widget.configuration.sharedPreferences
                .setString(passwordKey, widget.configuration.password)
            : widget.configuration.sharedPreferences.remove(passwordKey);

        setState(() => isLoading = false);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      configuration: widget.configuration,
                    )));
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Identifiants eronnés",
            style: TextStyle(color: Colors.red),
          ),
        ));
        if ((Platform.isAndroid || Platform.isIOS) &&
            await Vibration.hasVibrator()) Vibration.vibrate();
      }
    }
  }

  Widget showInfoButton() {
    return IconButton(
      icon: Icon(
        Icons.info_outline_rounded,
        color: Theme.of(context).primaryColorLight,
      ),
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          barrierColor: Theme.of(context).primaryColor.withOpacity(0.5),
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: Text(
                "Votre prénom et nom sont utilisés pour récupérer "
                "votre emploi du temps depuis le site de Beecome et Wigor.\n\n"
                ""
                "Le mot de passe est celui que vous utilisez pour vous "
                "connecter à Beecome ou MyLearningBox, il est utilisé pour "
                "récupérer vos notes et devoirs depuis le site MyLearningBox.\n"
                "Si vous ne souhaitez pas consulter vos notes/devoirs depuis Chronopsi "
                "il est optionnel. \n"
                "Le mot de passe est stocké sur votre "
                "${Platform.isWindows || Platform.isMacOS ? "ordinateur" : "téléphone"} "
                "et uniquement sur votre "
                "${Platform.isWindows || Platform.isMacOS ? "ordinateur" : "téléphone"}.",
                maxLines: 40,
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).primaryColorLight),
                textAlign: TextAlign.justify,
              ),
            );
          },
        );
      },
    );
  }
}
