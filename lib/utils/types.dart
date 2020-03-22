import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventData {
  EventData(
      {this.point,
      this.id,
      this.title,
      this.address,
      this.description,
      this.category,
      this.time,
      this.participants});

  GeoPoint point;
  String id, title, address, description, category;
  List<String> participants;
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
        participants: new List<String>.from(doc['participants']));
  }

  String listIcon() {
    switch (category) {
      case 'food':
        return 'assets/colors_icons/menu_icons/food.png';
      case 'disk':
        return 'assets/colors_icons/menu_icons/disk.png';
      case 'gift':
        return 'assets/colors_icons/menu_icons/gift.png';
      case 'sport':
        return 'assets/colors_icons/menu_icons/sport.png';
    }
    return 'assets/colors_icons/menu_icons/other.png';
  }

  String mapIcon() {
    switch (category) {
      case 'food':
        return 'assets/colors_icons/map_icons/food.png';
      case 'disk':
        return 'assets/colors_icons/map_icons/disk.png';
      case 'gift':
        return 'assets/colors_icons/map_icons/gift.png';
      case 'sport':
        return 'assets/colors_icons/map_icons/sport.png';
    }
    return 'assets/colors_icons/map_icons/other.png';
  }

  Color color() {
    switch (category) {
      case 'food':
        return Color(0xffd0794a);
      case 'disk':
        return Color(0xffc8368c);
      case 'gift':
        return Color(0xff27a83f);
      case 'sport':
        return Color(0xff7f3caa);
    }
    return Color(0xff4ab5d0);
  }
}
