import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:weup/data/types.dart';
import 'package:weup/pages/slider_page.dart';

class Event extends StatefulWidget {
  Event(this.id, {Key key})
      : assert(id != null),
        super(key: key);
  final String id;

  _EventState createState() => _EventState();
}

class _EventState extends SliderPageState<Event> {
  String id = '';

  @override
  void initState() {
    super.initState();
    id = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    var data = FutureBuilder(
      builder: (context, AsyncSnapshot<DocumentSnapshot> document) {
        var data = EventData.from(document.data);
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: Text(
                data.title,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Row(children: [Icon(Icons.location_on), Text(data.address)]),
            Row(children: [
              Icon(Icons.access_time),
              Text(data.time.toDate().toLocal().toString())
            ]),
            Row(children: [Icon(Icons.description), Text(data.description)]),
          ],
        );
      },
      future: Firestore.instance.collection('events').document(id).get(),
    );
    return combine(context,
        header: Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.all(10),
          child: Text(id, style: Theme.of(context).textTheme.headline5),
        ),
        body: data);
  }
}
