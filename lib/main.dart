import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:weup/model.dart';
import 'package:weup/pages/event.dart';
import 'package:weup/pages/events_list.dart';
import 'package:weup/pages/map_bg.dart';
import 'package:weup/widgets/ignore_top_pointer.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final router = Router();

void main() {
  router
    ..define('/', handler: Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
        return EventsList();
      },
    ), transitionType: TransitionType.inFromBottom)
    ..define('/event/:id', handler: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        return Event(params['id']?.first);
      },
    ), transitionType: TransitionType.inFromBottom);

  runApp(WeupInherited(child: AppScreen()));
}

class AppScreen extends StatelessWidget {
  Navigator nav(BuildContext context) {
    return Navigator(
      observers: [routeObserver],
      initialRoute: '/',
      onGenerateRoute: (rs) => router.generator(rs),
    );
  }

  Widget app(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new MapBackground(),
          HitMaskTest(child: nav(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
      ),
      home: app(context),
    );
  }
}
