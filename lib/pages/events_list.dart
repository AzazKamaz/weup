import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:weup/data/types.dart';
import 'package:weup/model.dart';
import 'package:weup/pages/slider_page.dart';
import 'package:weup/widgets/event_list_entry.dart';

class _EventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffeff6ee),
      child: !WeupInherited.of(context, 'all').participated
          ? StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('events').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return new ListView(
                      padding: EdgeInsets.zero,
                      children: snapshot.data.documents.map(
                        (DocumentSnapshot document) {
                          return EventListEntry(data: EventData.from(document));
                        },
                      ).toList(),
                    );
                }
              },
            )
          : null,
    );
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
  }

  @override
  Widget build(BuildContext context) {
    var header = TabBar(
      controller: _controller,
      tabs: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 8),
          alignment: Alignment.bottomCenter,
          child: Text("Events"),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 8),
          alignment: Alignment.bottomCenter,
          child: Text("Participated"),
        ),
      ],
      indicatorColor: Color(0xffeff6ee),
    );

    var body = TabBarView(
      children: [_EventsList(), Container()],
      controller: _controller,
    );

    return combine(context, header: header, body: body);
  }
}
