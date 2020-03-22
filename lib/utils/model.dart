import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class _WeupInherited extends InheritedModel<String> {
  _WeupInherited({
    Key key,
    @required Widget child,
    @required this.data,
    this.participated,
    this.myLocation,
  }) : super(key: key, child: child);

  final WeupInheritedState data;
  final bool participated;
  final LatLng myLocation;

  @override
  bool updateShouldNotify(_WeupInherited oldWidget) {
    return (participated != oldWidget.participated ||
        myLocation != oldWidget.myLocation);
  }

  @override
  bool updateShouldNotifyDependent(
      _WeupInherited oldWidget, Set<String> dependencies) {
    return dependencies.contains('deps') &&
        (participated != oldWidget.participated ||
            myLocation != oldWidget.myLocation);
  }
}

class WeupInherited extends StatefulWidget {
  WeupInherited({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  WeupInheritedState createState() => new WeupInheritedState();

  static WeupInheritedState of(BuildContext context, [String aspect]) {
    return InheritedModel.inheritFrom<_WeupInherited>(context, aspect: aspect)
        .data;
  }
}

class WeupInheritedState extends State<WeupInherited> {
  bool _participated = false;

  bool get participated => _participated;

  set participated(bool par) => setState(() {
        _participated = par;
      });

  Position position;
  StreamSubscription<Position> posstream;

  LatLng get myLocation =>
      position != null ? LatLng(position.latitude, position.longitude) : null;

  void initState() {
    super.initState();
    Geolocator().getLastKnownPosition().then((e) => setState(() {
          position = e;
        }));
    posstream = Geolocator().getPositionStream().listen((e) => setState(() {
          position = e;
        }));
  }

  void dispose() {
    posstream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _WeupInherited(
      data: this,
      participated: participated,
      child: widget.child,
      myLocation: myLocation,
    );
  }
}
