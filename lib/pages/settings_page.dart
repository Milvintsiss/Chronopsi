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
        showOptionWidget(
          "Coupler les cours ayant le même label qui se suivent",
          widget.configuration.concatenateSimilarLessons,
          (newValue) {
            widget.configuration.sharedPreferences
                .setBool('concatenateSimilarLessons', newValue);
            setState(() {
              widget.configuration.concatenateSimilarLessons = newValue;
            });
          },
        ),
        showOptionWidget("Design épuré", widget.configuration.cleanDisplay,
            (newValue) {
          widget.configuration.sharedPreferences
              .setBool('cleanDesign', newValue);
          setState(() {
            widget.configuration.cleanDisplay = newValue;
          });
        })
      ],
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
    );
  }

  Widget showOptionWidget(String label, bool value, void onChanged(newValue)) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 60),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
              inactiveThumbColor: Theme.of(context).primaryColorLight,
              inactiveTrackColor: Theme.of(context).primaryColor,
            )
          ],
        ),
      ),
    );
  }
}
