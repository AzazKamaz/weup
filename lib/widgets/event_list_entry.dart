import 'package:flutter/material.dart';
import 'package:weup/data/types.dart';

import '../main.dart';

class EventListEntry extends StatelessWidget {
  EventListEntry({this.data});

  EventData data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => router.navigateTo(context, '/event/${data.id}'),
      title: Text(data.title),
      subtitle: Text(data.address),
    );
  }
}
