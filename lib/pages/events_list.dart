import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:weup/main.dart';
import 'package:weup/pages/slider_page.dart';
import 'package:weup/utils/model.dart';
import 'package:weup/utils/tools.dart';
import 'package:weup/utils/types.dart';
import 'package:weup/widgets/event_list_entry.dart';

class _FiltersComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Center(
        child: Text(
          '[ Filters are coming soon ]',
          style: TextStyle(
              color: Color(0xaa969696),
              fontFamily: 'PT Sans',
              fontWeight: FontWeight.w400,
              fontSize: 20),
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  _EventsList({Key key, this.stream});

  final Stream<QuerySnapshot> stream;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xffeff6ee),
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (!snapshot.hasData) return Center(child: Text('Loading...'));
            var weup = WeupInherited.of(context);
            var dist = (GeoPoint ds) =>
                distance(weup.myLocation, LatLng(ds.latitude, ds.longitude))
                    .floor();
            var docs = snapshot.data.documents;
            if (weup.myLocation != null)
              docs.sort((a, b) => dist(a['point']) - dist(b['point']));
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: <Widget>[_FiltersComingSoon(), NewEventListEntry()]
                  .followedBy(docs.map(
                (DocumentSnapshot document) {
                  return Container(
                    child: EventListEntry(data: EventData.from(document)),
                    margin: EdgeInsets.only(top: 10),
                  );
                },
              )).toList(),
            );
          },
        ));
  }
}

class EventsList extends StatefulWidget {
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends SliderPageState<EventsList>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    _controller.addListener(() {
      WeupInherited.of(context, 'none').participated = _controller.index == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var header = TabBar(
      controller: _controller,
      indicatorWeight: 3,
      tabs: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 8),
          alignment: Alignment.bottomCenter,
          child: Text("Events",
              style: TextStyle(
                color: Color(0xffeff6ee),
                fontFamily: 'PT Sans',
                fontWeight: FontWeight.w400,
                fontSize: 30,
              )),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 8),
          alignment: Alignment.bottomCenter,
          child: Text("Involved",
              style: TextStyle(
                color: Color(0xffeff6ee),
                fontFamily: 'PT Sans',
                fontWeight: FontWeight.w400,
                fontSize: 30,
              )),
        ),
      ],
      indicatorColor: Color(0xffeff6ee),
    );

    var body = TabBarView(
      children: [
        _EventsList(
            stream: Firestore.instance
                .collection('events')
                .where('time', isGreaterThan: Timestamp.now())
                .snapshots()),
        _EventsList(
            stream: Firestore.instance
                .collection('events')
                .where('participants', arrayContains: deviceId)
                .snapshots())
      ],
      controller: _controller,
    );

    return combine(context, header: header, body: body);
  }
}
