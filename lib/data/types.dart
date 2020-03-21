import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:weup/model.dart';

import '../main.dart';

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
                      children: snapshot.data.documents.map(
                        (DocumentSnapshot document) {
                          return new ListTile(
                            onTap: () {
                              WeupInherited.of(context, 'all').inspected =
                                  document.documentID;
                              router.navigateTo(
                                  context, '/event/${document.documentID}');
                            },
                            title: new Text(document['title']),
                            subtitle: new Text(document['title']),
                          );
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

class EventData {
  EventData(
      {this.point,
      this.id,
      this.title,
      this.address,
      this.description,
      this.category,
      this.time});

  GeoPoint point;
  String id, title, address, description, category;
  Timestamp time;

  static EventData from(DocumentSnapshot doc) {
    return EventData(
      point: doc['point'],
      id: doc.documentID,
      title: doc['title'],
      address: doc['address'],
      description: doc['description'],
      category: doc['category'],
      time: doc['time'],
    );
  }
}
