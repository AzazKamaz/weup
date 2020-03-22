import 'package:device_id/device_id.dart';
import 'package:first_time_screen/first_time_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:weup/pages/event.dart';
import 'package:weup/pages/events_list.dart';
import 'package:weup/pages/intro.dart';
import 'package:weup/pages/map_bg.dart';
import 'package:weup/pages/new_event.dart';
import 'package:weup/utils/model.dart';
import 'package:weup/utils/routes.dart';
import 'package:weup/widgets/ignore_top_pointer.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final router = Router();
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final MapController mapController = new MapController();
final Map<Object, Function(MapPosition)> mapUpdates = new Map();
String deviceId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  deviceId = await DeviceId.getID;
  debugPrint('deviceId $deviceId');

  router
    ..define('/', handler: Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
        return EventsList();
      },
    ), transitionType: TransitionType.inFromBottom)
    ..define('/event', handler: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        return NewEvent();
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
      key: navigatorKey,
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
//        brightness: Brightness.light,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
      ),
      home: FirstTimeScreen(
        loadingScreen: Container(color: Colors.white),
        introScreen: FadeRoute(page: IntroPage(child: app(context))),
        landingScreen: FadeRoute(page: app(context)),
      ),
    );
  }
}
