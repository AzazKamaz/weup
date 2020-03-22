import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:share/share.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:weup/pages/slider_page.dart';
import 'package:weup/utils/tools.dart';
import 'package:weup/utils/types.dart';

import '../main.dart';

class Event extends StatefulWidget {
  Event(this.id, {Key key})
      : assert(id != null),
        super(key: key);
  final String id;

  _EventState createState() => _EventState();
}

class _EventState extends SliderPageState<Event> with TickerProviderStateMixin {
  String id = '';

  @override
  void initState() {
    super.initState();
    id = widget.id;
//    precacheImage(AssetImage('assets/icons/cancel.png'), context);
//    precacheImage(AssetImage('assets/icons/check.png'), context);
//    precacheImage(AssetImage('assets/icons/empty.png'), context);
  }

  Widget buildHeader(BuildContext context, String title, EventData data) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            child: Image.asset('assets/icons/cancel.png'),
            onTap: () => router.pop(context),
          ),
          Text(title,
              style: TextStyle(
                color: Color(0xffeff6ee),
                fontFamily: 'PT Sans',
                fontWeight: FontWeight.w400,
                fontSize: 30,
              )),
          if (data != null && data.participants.contains(deviceId))
            InkWell(
              child: Image.asset('assets/icons/check.png'),
              onTap: () {
                Firestore.instance
                    .collection('events')
                    .document(id)
                    .updateData({
                  'participants': FieldValue.arrayRemove([deviceId])
                });
              },
            ),
          if (data != null && !data.participants.contains(deviceId))
            InkWell(
              child: Image.asset('assets/icons/empty.png'),
              onTap: () {
                Firestore.instance
                    .collection('events')
                    .document(id)
                    .updateData({
                  'participants': FieldValue.arrayUnion([deviceId])
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, AsyncSnapshot<DocumentSnapshot> document) {
        if (!document.hasData)
          return combine(context,
              header: buildHeader(context, id, null),
              initSnapPosition: SnapPosition(positionFactor: 0.5),
              body: Container());
        var data = EventData.from(document.data);
        var date = DateFormat("d MMM yyyy").format(data.time.toDate());
        var time = DateFormat("HH:mm").format(data.time.toDate());
        return combine(
          context,
          header: buildHeader(context, data.title, data),
          headerColor: data.color(),
          body: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category: ${data.category}',
                      style: TextStyle(
                        color: Color(0xff278f82),
                        fontFamily: 'PT Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      )),
                  Text('${data.participants.length} will come',
                      style: TextStyle(
                        color: Color(0xff969696),
                        fontFamily: 'PT Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      )),
                  InkWell(
                    onTap: () {
                      final RenderBox box = context.findRenderObject();
                      Share.share(
                          'Check out ${data.title} event in "weup!", it will take place $date at $time at ${data.address}',
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                    },
                    child: Text('Share',
                        style: TextStyle(
                          color: Color(0xff969696),
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                          decoration: TextDecoration.underline,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(data.description,
                  style: TextStyle(
                    color: Color(0xff969696),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w300,
                    fontSize: 17,
                  )),
              SizedBox(height: 20),
              SizedBox(height: 1, child: Container(color: Color(0x88969696))),
              SizedBox(height: 5),
              InkWell(
                onTap: () {
                  animatedMapMove(
                      LatLng(data.point.latitude, data.point.longitude),
                      17,
                      mapController,
                      this);
//                  mapController.move(
//                      LatLng(data.point.latitude, data.point.longitude), 17);
                  snapController
                      .snapToPosition(snapController.snapPositions.first);
                },
                child: Text(data.address,
                    style: TextStyle(
                      color: Color(0xff969696),
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                      decoration: TextDecoration.underline,
                    )),
              ),
              Text('$date at $time',
                  style: TextStyle(
                    color: Color(0xff969696),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w300,
                    fontSize: 17,
                  )),
            ],
          ),
        );
      },
      stream: Firestore.instance.collection('events').document(id).snapshots(),
    );
  }
}
