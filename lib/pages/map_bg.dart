import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:weup/model.dart';

class MapBackground extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapBackground();
}

class _MapBackground extends State<MapBackground> {
  _MapBackground() {
//    FirebaseAnalytics().logEvent(name: "map_created");
  }

//  MapController mapController = MapController();
//  UserLocationOptions userLocationOptions;
//  List<Marker> markers = [];

  Widget buildMap(BuildContext context, List<Marker> markers) {
//    userLocationOptions = UserLocationOptions(
//      context: context,
//      mapController: mapController,
//      markers: markers,
//    );

    const bgSize = 2;
    var overlayImages = List<OverlayImage>.generate(bgSize * bgSize, (index) {
      var x = index ~/ bgSize, y = index % bgSize;
      return new OverlayImage(
          bounds: LatLngBounds(
              LatLng(90.0 - x * 180 / bgSize, -180.0 + y * 360 / bgSize),
              LatLng(90.0 - (x + 1) * 180 / bgSize,
                  -180.0 + (y + 1) * 360 / bgSize)),
          opacity: 1,
          imageProvider: NetworkImage(
              'https://${index % 4 + 1}.base.maps.ls.hereapi.com/maptile/2.1/maptile/newest/normal.night/${(log(bgSize) * log2e).floor()}/$y/$x/512/jpg?apiKey=Ki0wminMdblLSGdEnxPtx8ISfp0pEpyXxymgBai_Bno'));
    });

    return FlutterMap(
//      mapController: mapController,
      options: MapOptions(
        center: LatLng(55.753, 48.744),
        zoom: 13.0,
        minZoom: 1,
        maxZoom: 19,
        plugins: [
//          UserLocationPlugin(),
        ],
      ),
      layers: [
        OverlayImageLayerOptions(overlayImages: overlayImages),
        TileLayerOptions(
          urlTemplate:
              "https://{s}.base.maps.ls.hereapi.com/maptile/2.1/maptile/newest/normal.night"
              "/{z}/{x}/{y}/512/jpg?apiKey={apiKey}",
          subdomains: ['1', '2', '3', '4'],
          additionalOptions: {
            'apiKey': 'Ki0wminMdblLSGdEnxPtx8ISfp0pEpyXxymgBai_Bno',
          },
          backgroundColor: Colors.transparent,
          keepBuffer: 3,
        ),
//        MarkerLayerOptions(markers: markers),
//        userLocationOptions,
        MarkerLayerOptions(markers: markers),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('events').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.waiting)
          return buildMap(context, []);

        return buildMap(
            context,
            snapshot.data.documents
                .where((element) => element.data.containsKey('point'))
                .map(
              (DocumentSnapshot document) {
                GeoPoint point = document['point'];
                final insp = WeupInherited.of(context, 'all').inspected;
                bool isBig = insp == document.documentID;
                return new Marker(
                  point: LatLng(point.latitude, point.longitude),
                  width: isBig ? 50 : 30,
                  height: isBig ? 50 : 30,
                  builder: (context) {
                    return FlutterLogo();
                  },
                );
              },
            ).toList());
      },
    );
  }
}
