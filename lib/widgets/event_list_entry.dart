import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:weup/utils/model.dart';
import 'package:weup/utils/tools.dart';
import 'package:weup/utils/types.dart';

import '../main.dart';

class EventListEntry extends StatelessWidget {
  EventListEntry({this.data});

  final EventData data;

  @override
  Widget build(BuildContext context) {
    var date = DateFormat("MMM d").format(data.time.toDate());
    var time = DateFormat("HH:mm").format(data.time.toDate());
    var dist = fmtdist(distance(
        LatLng(data.point.latitude, data.point.longitude),
        WeupInherited.of(context).myLocation));
    return InkWell(
      onTap: () => router.navigateTo(context, '/event/${data.id}'),
      child: Opacity(
        opacity: data.time.toDate().isAfter(DateTime.now()) ? 1 : 0.5,
        child: SizedBox(
          height: 75,
          child: Row(
            children: [
              Image.asset(data.listIcon()),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xff278f82),
                          fontFamily: 'PT Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 25),
                    ),
                    Text(
                      "$date at $time, ${dist} away\n${data.participants.length} will come",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xff969696),
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w300,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewEventListEntry extends StatelessWidget {
  NewEventListEntry();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => router.navigateTo(context, '/event'),
      child: SizedBox(
        height: 75,
        child: Row(
          children: [
            Image.asset('assets/colors_icons/menu_icons/add.png'),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create new event',
                    style: TextStyle(
                        color: Color(0xff278f82),
                        fontFamily: 'PT Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
