import 'package:flutter/material.dart';

class AppTheme {
  final ThemeData darkTheme = ThemeData(
    backgroundColor: Color(0xff212529),
    primaryColor: Color(0xff212529),
    primaryColorDark: Color(0xff495057),
    primaryColorLight: Color(0xffced4da),
    appBarTheme: AppBarTheme(
        backgroundColor: Color(0xff212529),
        iconTheme: IconThemeData(
          color: Color(0xffced4da),
        ),
        actionsIconTheme: IconThemeData(
          color: Color(0xffced4da),
        ),
        toolbarTextStyle: TextTheme(
                headline6: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    color: Color(0xffced4da)))
            .bodyText2,
        titleTextStyle: TextTheme(
                headline6: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    color: Color(0xffced4da)))
            .headline6),
    visualDensity: VisualDensity(),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    colorScheme:
        ColorScheme.fromSwatch().copyWith(primary: Color(0xff495057), secondary: Color(0xff495057)),
  );

  final ThemeData lightTheme = ThemeData(
    backgroundColor: Color(0xfff8f9fa),
    primaryColor: Color(0xfff8f9fa),
    primaryColorDark: Color(0xffadb5bd),
    primaryColorLight: Color(0xff343a40),
    appBarTheme: AppBarTheme(
        backgroundColor: Color(0xfff8f9fa),
        iconTheme: IconThemeData(
          color: Color(0xff343a40),
        ),
        actionsIconTheme: IconThemeData(
          color: Color(0xff343a40),
        ),
        toolbarTextStyle: TextTheme(
                headline6: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    color: Color(0xff343a40)))
            .bodyText2,
        titleTextStyle: TextTheme(
                headline6: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    color: Color(0xff343a40)))
            .headline6),
    visualDensity: VisualDensity(),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    colorScheme:
        ColorScheme.fromSwatch().copyWith(primary: Color(0xffadb5bd), secondary: Color(0xffadb5bd)),
  );
}

//old lightTheme
// final ThemeData lightTheme = ThemeData(
//   accentColor: Color(0xffc9cba3),
//   backgroundColor: Color(0xffffe1a8),
//   primaryColor: Color(0xffffe1a8),
//   primaryColorDark: Color(0xffc9cba3),
//   primaryColorLight: Color(0xffe26d5c),
//   appBarTheme: AppBarTheme(
//       iconTheme: IconThemeData(
//         color: Color(0xffe26d5c),
//       ),
//       actionsIconTheme: IconThemeData(
//         color: Color(0xffe26d5c),
//       ),
//       textTheme: TextTheme(
//           headline6: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0.15,
//               color: Color(0xffe26d5c))),
//       toolbarTextStyle: TextStyle(color: Color(0xffe26d5c))),
//   visualDensity: VisualDensity(),
//   materialTapTargetSize: MaterialTapTargetSize.padded,
// );
