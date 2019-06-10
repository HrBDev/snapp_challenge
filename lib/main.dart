import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snapp_challenge/constants.dart';
import 'package:snapp_challenge/generated/i18n.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
      ],
      title: 'Snapp Challenge',
      theme: ThemeData(primaryColor: Constants.green[400]),
      locale: Locale('fa', 'IR'),
      supportedLocales: S.delegate.supportedLocales,
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
