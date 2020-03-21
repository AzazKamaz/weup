import 'package:flutter/material.dart';

class _WeupInherited extends InheritedModel<String> {
  _WeupInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final _WeupInheritedState data;

  @override
  bool updateShouldNotify(_WeupInherited oldWidget) {
    return true; //data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
      _WeupInherited oldWidget, Set<String> dependencies) {
    return dependencies.contains('all') ||
        dependencies.contains('deps') &&
            data._participated != oldWidget.data._participated;
  }
}

class WeupInherited extends StatefulWidget {
  WeupInherited({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _WeupInheritedState createState() => new _WeupInheritedState();

  static _WeupInheritedState of(BuildContext context, [String aspect]) {
    return InheritedModel.inheritFrom<_WeupInherited>(context, aspect: aspect)
        .data;
  }
}

class _WeupInheritedState extends State<WeupInherited> {
  bool _participated = false;

  bool get participated => _participated;

  set participated(bool par) => setState(() {
        _participated = par;
      });

  String _inspected;

  String get inspected => _inspected;

  set inspected(String ins) => setState(() {
        _inspected = ins;
      });

  @override
  Widget build(BuildContext context) {
    return _WeupInherited(
      data: this,
      child: widget.child,
    );
  }
}
