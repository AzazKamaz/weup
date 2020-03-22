import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:weup/main.dart';

void animatedMapMove(
    LatLng destLocation, double destZoom, _mapController, vsync) {
  // Create some tweens. These serve to split up the transition from one location to another.
  // In our case, we want to split the transition be<tween> our current map center and the destination.
  final _latTween = Tween<double>(
      begin: _mapController.center.latitude, end: destLocation.latitude);
  final _lngTween = Tween<double>(
      begin: _mapController.center.longitude, end: destLocation.longitude);
  final _zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

  // Create a animation controller that has a duration and a TickerProvider.
  var controller = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: vsync);
  // The animation determines what path the animation will take. You can try different Curves values, although I found
  // fastOutSlowIn to be my favorite.
  Animation<double> animation =
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

  controller.addListener(() {
    _mapController.move(
        LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
        _zoomTween.evaluate(animation));
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      controller.dispose();
    } else if (status == AnimationStatus.dismissed) {
      controller.dispose();
    }
  });

  controller.forward();
}

LatLng getOneThirdGeo() {
  const crs = const Epsg3857();
  var zoom = mapController.zoom;
  var bnd = mapController.bounds;

  var ne = crs.latLngToPoint(bnd.northEast, zoom);
  var nw = crs.latLngToPoint(bnd.northWest, zoom);
  var se = crs.latLngToPoint(bnd.southEast, zoom);
  var sw = crs.latLngToPoint(bnd.southWest, zoom);
  var p = (ne + nw) / 2 * (2 / 3) + (se + sw) / 2 * (1 / 3);
  return crs.pointToLatLng(p, zoom);
}

num round10(double a) {
  var l = (log(a) * log10e).floor() - 1;
  var ll = pow(10, l);
  return (a / ll).floor() * ll;
}

String fmtdist(num dist) {
  dist = round10(dist);
  if (dist < 1000) return '${dist}m';
  if (dist < 10000) return '${dist / 1e3}km';
  return '${dist ~/ 1e3}km';
}

double distance(LatLng a, LatLng b) {
  const R = 6371e3;
  var f1 = a.latitudeInRad;
  var f2 = b.latitudeInRad;
  var df = f2 - f1;
  var dl = b.longitudeInRad - a.longitudeInRad;
  var _a = pow(sin(df / 2), 2) + cos(f1) * cos(f2) * pow(sin(dl / 2), 2);
  var _c = 2 * atan2(sqrt(_a), sqrt(1 - _a));
  return R * _c;
}
