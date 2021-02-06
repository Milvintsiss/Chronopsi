import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chronopsi/library/configuration.dart';
import 'package:chronopsi/library/myLearningBox_helper.dart';
import 'package:chronopsi/myLearningBoxAPI.dart';

class GradesPage extends StatefulWidget {
  GradesPage({Key key, this.configuration}) : super(key: key);

  final Configuration configuration;

  @override
  _GradesPageState createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  List<GlobalKey<ExpansionTileCardState>> cards = [];

  bool isLoading = true;

  List<Grade> grades = [];
  List<GradesByTeacher> gradesByTeachers = [];
  String average;

  bool showOnlyLessonsThatHaveGrade = true;

  @override
  void initState() {
    getGrades();
    super.initState();
  }

  void getGrades() async {
    setState(() {
      isLoading = true;
    });
    grades = await getGradesFromMyLearningBox(widget.configuration);
    grades.forEach((grade) {
      grade.init();
    });
    initGrades();
  }

  void initGrades() {
    List<Grade> gradesThatHaveAValue = grades.toList()
      ..removeWhere((grade) => grade.value == null);

    gradesByTeachers = sortGradesByTeacher(
        showOnlyLessonsThatHaveGrade ? gradesThatHaveAValue : grades);

    gradesByTeachers.forEach((element) => cards.add(GlobalKey()));

    calculateAverage(gradesThatHaveAValue);

    isLoading = false;
    setState(() {});
  }

  void calculateAverage(List<Grade> grades) {
    if (grades.length > 0) {
      double sum = 0;
      grades.forEach((grade) {
        sum += double.parse(grade.value.replaceAll(',', '.'));
      });
      average = (sum / grades.length).toStringAsFixed(2);
    } else {
      average = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: appBar(),
      body: body(),
    );
  }

  AppBar appBar(){
    return AppBar(
      title: Text("Mes notes"),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(MdiIcons.arrowCollapseVertical),
          onPressed: () {
            cards.forEach((element) {
              element.currentState.collapse();
            });
          },
        ),
        IconButton(
          icon: Icon(MdiIcons.arrowExpandVertical),
          onPressed: () {
            cards.forEach((element) {
              element.currentState.expand();
            });
          },
        ),
        isLoading
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.5),
          child: Center(
            child: SizedBox(
              width: 15,
              height: 15,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColorLight),
                ),
              ),
            ),
          ),
        )
            : IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            getGrades();
          },
        ),
      ],
    );
  }

  Widget body() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                child: showOptionWidget(
                    "Montrer uniquement les cours comportant des notes",
                    showOnlyLessonsThatHaveGrade, (newValue) {
                  showOnlyLessonsThatHaveGrade = newValue;
                  initGrades();
                }, Theme.of(context).primaryColor),
              ),
              for (GradesByTeacher gradesByTeacher in gradesByTeachers)
                teacherListWidget(gradesByTeacher),
              showAverageWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget teacherListWidget(GradesByTeacher gradesByTeacher) {
    return ExpansionTileCard(
      key: cards[gradesByTeachers.indexOf(gradesByTeacher)],
      baseColor: Theme.of(context).primaryColor,
      expandedColor: Theme.of(context).primaryColor.withOpacity(0.85),
      borderRadius: BorderRadius.all(Radius.circular(15)),
      initialPadding: EdgeInsets.symmetric(vertical: 3),
      title: Text(
        gradesByTeacher.teacher,
        style: TextStyle(color: Theme.of(context).primaryColorLight),
      ),
      children: [gradesTableWidget(gradesByTeacher.grades)],
    );
  }

  Widget gradesTableWidget(List<Grade> grades) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 15,
              headingRowHeight: 20,
              headingTextStyle: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              dataTextStyle: TextStyle(
                  color: Theme.of(context).primaryColorLight, fontSize: 13),
              dividerThickness: 2,
              columns: [
                DataColumn(label: Text("Cat")),
                DataColumn(label: Text("Matière")),
                DataColumn(label: Text("Note")),
              ],
              rows: [
                for (Grade grade in grades)
                  DataRow(
                      cells: [
                        DataCell(Center(
                          child: Text(grade.category ?? ' - '),
                        )),
                        DataCell(Text(grade.lessonLabel)),
                        DataCell(Center(child: Text(grade.value ?? ' - '))),
                      ],
                      onSelectChanged: (selected) {
                        launch(grade.link);
                      })
              ],
            ),
          ),
        ));
  }

  Widget showAverageWidget() {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(color: Theme.of(context).primaryColorLight)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Moyenne: ",
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          Text(
            average ?? "non-définie",
            style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget showOptionWidget(
      String label, bool value, void onChanged(newValue), Color firstColor) {
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
                constraints: BoxConstraints(minHeight: 30),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  decoration: BoxDecoration(
                    color: firstColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
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
