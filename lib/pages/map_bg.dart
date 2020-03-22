import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:weup/utils/model.dart';
import 'package:weup/utils/secrets.dart';
import 'package:weup/utils/tools.dart';
import 'package:weup/utils/types.dart';

import '../main.dart';

class MapBackground extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapBackground();
}

class _MapBackground extends State<MapBackground>
    with TickerProviderStateMixin {
  void toLocation() async {
    var position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
//    mapController.move(LatLng(position.latitude, position.longitude), 14);
    animatedMapMove(
        LatLng(position.latitude, position.longitude), 16, mapController, this);
  }

  void initState() {
    super.initState();
    toLocation();
  }

  Widget buildMap(
      BuildContext context, WeupInheritedState weup, List<Marker> markers) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LatLng(55.753, 48.744),
            zoom: 13.0,
            minZoom: 1,
            maxZoom: 19,
            onPositionChanged: (MapPosition pos, bool b) {
              mapUpdates.forEach((key, value) {
                value(pos);
              });
            },
            plugins: [MarkerClusterPlugin()],
          ),
          layers: [
            TileLayerOptions(
              urlTemplate:
                  "https://{s}.base.maps.ls.hereapi.com/maptile/2.1/maptile/newest/normal.day"
                  "/{z}/{x}/{y}/512/jpg?apiKey={apiKey}",
              subdomains: ['1', '2', '3', '4'],
              additionalOptions: {
                'apiKey': HERE_API_KEY,
              },
              backgroundColor: Colors.transparent,
            ),
//            MarkerLayerOptions(markers: markers),
            MarkerClusterLayerOptions(
              maxClusterRadius: 10,
              size: Size(40, 40),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: markers,
              polygonOptions: PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3),
              builder: (context, markers) {
                return FloatingActionButton(
                  backgroundColor: Color(0xff278f82),
                  child: Text(markers.length.toString()),
                  onPressed: null,
                );
              },
            ),
            if (weup.myLocation != null)
              MarkerLayerOptions(markers: [
                Marker(
                    point: weup.myLocation,
                    width: 20,
                    height: 20,
                    builder: (ctx) => IgnorePointer(
                            child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                              Container(
                                height: 20.0,
                                width: 20.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue[300].withOpacity(0.7)),
                              ),
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent),
                              ),
                            ])))
              ]),
          ],
        ),
        SafeArea(
          child: Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.all(10),
            child: FloatingActionButton(
              backgroundColor: const Color(0xff278f82),
              child: const Icon(Icons.my_location),
              onPressed: () => toLocation(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var weup = WeupInherited.of(context, 'deps');
    var stream = weup.participated
        ? Firestore.instance
            .collection('events')
            .where('participants', arrayContains: deviceId)
            .snapshots()
        : Firestore.instance
            .collection('events')
            .where('time', isGreaterThan: Timestamp.now())
            .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError || !snapshot.hasData)
          return buildMap(context, weup, []);

        return buildMap(
            context,
            weup,
            snapshot.data.documents
                .where((element) => element.data.containsKey('point'))
                .map(
              (DocumentSnapshot document) {
                EventData data = EventData.from(document);
//                final insp = WeupInherited.of(context, 'all').inspected;
//                bool isBig = insp == document.documentID;
                return new Marker(
                  point: LatLng(data.point.latitude, data.point.longitude),
                  width: 50,
                  height: 50,
                  anchorPos: AnchorPos.align(AnchorAlign.top),
                  builder: (context) {
                    return InkWell(
//                      onTap: () => navigatorKey.currentState
//                          .pushNamed('/event/${data.id}'),
                      onTap: () => navigatorKey.currentState
                          .pushNamedAndRemoveUntil(
                              '/event/${data.id}',
                              (route) =>
                                  !route.settings.name.startsWith('/event/')),
                      child: Opacity(
                        opacity: data.time.toDate().isAfter(DateTime.now())
                            ? 1
                            : 0.5,
                        child: Image.asset(data.mapIcon()),
                      ),
                    );
                  },
                );
              },
            ).toList());
      },
    );
  }
}
