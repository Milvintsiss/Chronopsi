import 'package:flutter/material.dart';
import 'package:vge/library/configuration.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: body(),
    );
  }

  Widget body() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      children: [
        showOptionConcatenateSimilarLessonsSwitch(),
      ],
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
    );
  }

  Widget showOptionConcatenateSimilarLessonsSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: Text(
                "Coupler les cours ayant le même label qui se suivent",
                style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          Switch(
              value: widget.configuration.concatenateSimilarLessons,
              onChanged: (newValue) {
                widget.configuration.sharedPreferences.setBool(
                    'concatenateSimilarLessons', newValue);
                setState(() {
                  widget.configuration.concatenateSimilarLessons = newValue;
                });
              },
            activeColor: Theme.of(context).primaryColor,
            inactiveThumbColor: Theme.of(context).primaryColorLight,
            inactiveTrackColor: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }
}
