import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:here_maps_webservice/here_maps_webservice.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:weup/pages/slider_page.dart';
import 'package:weup/utils/secrets.dart';
import 'package:weup/utils/tools.dart';

import '../main.dart';

class NewEvent extends StatefulWidget {
  NewEvent({Key key}) : super(key: key);

  _NewEventState createState() => _NewEventState();
}

class _NewEventState extends SliderPageState<NewEvent>
    with SingleTickerProviderStateMixin {
  final List<String> categories = [
    'disk',
    'food',
    'gift',
    'sport',
    'other',
  ];
  TextEditingController titleController = new TextEditingController();
  TabController categoryController;
  TextEditingController descriptionController = new TextEditingController();
  DateTime firstDateTime = DateTime.now().add(Duration(days: -1));
  DateTime dateTime = DateTime.now().add(Duration(days: 1));
  LatLng point;
  Future<Map<String, String>> address;

  Timer reqTimer;

  void fetchAddress() {
    setState(() {
      address = HereMaps(apiKey: HERE_API_KEY)
          .reverseGeoCode(lat: point.latitude, lon: point.longitude)
          .then((value) {
        if (value['Response']['View'].length == 0)
          return {'label': point.toSexagesimal()};
        if (value['Response']['View'][0]['Result'].length == 0)
          return {'label': point.toSexagesimal()};
        Map<String, dynamic> data =
            value['Response']['View'][0]['Result'][0]['Location']['Address'];
        data['AdditionalData'].forEach((e) => data[e['key']] = e['value']);
        data.remove('AdditionalData');
        Map<String, String> ldata = Map();
        data.forEach((key, value) {
          ldata[key.toLowerCase()] = value;
        });
        return ldata;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    categoryController = new TabController(
        length: categories.length,
        vsync: this,
        initialIndex: Random.secure().nextInt(categories.length));
    mapUpdates[this] = (MapPosition pos) => this.setState(() {
          point = getOneThirdGeo();
          if (reqTimer != null) reqTimer.cancel();
          reqTimer = Timer(Duration(seconds: 1), fetchAddress);
        });
    mapUpdates[this](MapPosition(bounds: mapController.bounds));
  }

  @override
  void dispose() {
    mapUpdates.remove(this);
    reqTimer.cancel();
    super.dispose();
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            child: Image.asset('assets/icons/back_arrow.png'),
            onTap: () => router.pop(context),
          ),
          Text('Create event',
              style: TextStyle(
                color: Color(0xffeff6ee),
                fontFamily: 'PT Sans',
                fontWeight: FontWeight.w400,
                fontSize: 30,
              )),
          InkWell(
            child: Image.asset('assets/icons/checkmark.png'),
            onTap: () {
              create();
            },
          ),
        ],
      ),
    );
  }

  Future<DocumentReference> creating;

  void create() async {
    if (creating == null) {
      creating = Firestore.instance.collection('events').add({
        'title': titleController.value.text,
        'category': categories[categoryController.index],
        'description': descriptionController.value.text,
        'point': GeoPoint(point.latitude, point.longitude),
        'address': reqTimer.isActive
            ? point.toSexagesimal()
            : await address
                .then((value) => value['label'])
                .catchError((_) => point.toSexagesimal()),
        'time': Timestamp.fromDate(dateTime),
        'participants': [deviceId],
      });
      creating.then((ref) {
        snapController.snapToPosition(snapController.snapPositions.first);
        Navigator.of(context).pushReplacementNamed('/event/${ref.documentID}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var date = DateFormat("d MMM yyyy").format(dateTime);
    var time = DateFormat("HH:mm").format(dateTime);

    return combine(
      context,
      header: buildHeader(context),
      initSnapPosition: SnapPosition(positionFactor: 0.5),
      background: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 1 / 3,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset('assets/colors_icons/map_icons/neutral.png'),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            style: TextStyle(
              color: Color(0xff278f82),
              fontFamily: 'PT Sans',
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Type a short title here...',
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 20),
          TabBar(
            controller: categoryController,
            indicatorColor: Color(0xff278f82),
            tabs: categories
                .map((cat) =>
                    Image.asset('assets/colors_icons/menu_icons/$cat.png'))
                .toList(),
          ),
          SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            maxLines: null,
            minLines: 5,
            style: TextStyle(
              color: Color(0xff278f82),
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w300,
              fontSize: 17,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Type a description here...',
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              InkWell(
                child: Text(date,
                    style: TextStyle(
                      color: Color(0xff969696),
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                      decoration: TextDecoration.underline,
                    )),
                onTap: () async {
                  var date = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: firstDateTime,
                      lastDate: DateTime.now().add(Duration(days: 365)));
                  if (date != null)
                    setState(() {
                      dateTime = DateTime(date.year, date.month, date.day,
                          dateTime.hour, dateTime.minute);
                    });
                },
              ),
              Text(' at ',
                  style: TextStyle(
                    color: Color(0xff969696),
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w300,
                    fontSize: 17,
                  )),
              InkWell(
                child: Text(time,
                    style: TextStyle(
                      color: Color(0xff969696),
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                      decoration: TextDecoration.underline,
                    )),
                onTap: () async {
                  var time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(dateTime));
                  if (time != null)
                    setState(() {
                      dateTime = DateTime(dateTime.year, dateTime.month,
                          dateTime.day, time.hour, time.minute);
                    });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          if (address == null || reqTimer.isActive)
            Text(point.toSexagesimal(),
                style: TextStyle(
                  color: Color(0xff969696),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                ))
          else
            FutureBuilder(
              future: address,
              builder: (context, AsyncSnapshot<Map<String, String>> data) {
                if (data.connectionState == ConnectionState.waiting)
                  return Text('Searching...',
                      style: TextStyle(
                        color: Color(0xff969696),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                      ));
                if (data.hasData)
                  return Text(data.data['label'],
                      style: TextStyle(
                        color: Color(0xff969696),
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                      ));
                return Text(data.error.toString(),
                    style: TextStyle(
                      color: Color(0xff969696),
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                    ));
              },
            )
        ],
      ),
    );
  }
}
