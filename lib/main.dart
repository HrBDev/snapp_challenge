import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snapp_challenge/constants.dart';
import 'package:snapp_challenge/generated/i18n.dart';
import 'package:snapp_challenge/map_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const GeneratedLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
      ],
      title: 'Snapp Challenge',
      theme: ThemeData(
          primaryColor: Colors.white, accentColor: Constants.green[1]),
      locale: Locale('fa', 'IR'),
      supportedLocales: S.delegate.supportedLocales,
      home: MapScreen(),
    );
  }
}
