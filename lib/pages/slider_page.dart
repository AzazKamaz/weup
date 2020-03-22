import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../main.dart';
import '../widgets/ignore_top_pointer.dart';

class _SliderPageGrabber extends StatelessWidget {
  _SliderPageGrabber({this.child, this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var grabber = SizedBox.fromSize(
      size: const Size.fromHeight(24),
      child: Container(
        margin: EdgeInsets.all(8),
        alignment: Alignment.topCenter,
        child: SizedBox.fromSize(
          size: const Size(64, 4),
          child: Container(
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              color: Color(0xffeff6ee),
            ),
          ),
        ),
      ),
    );

    var grabbing = Container(
      child: AnimatedContainer(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          color: color,
        ),
        duration: Duration(milliseconds: 200),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            grabber,
            child,
          ],
        ),
      ),
    );

    return grabbing;
  }
}

abstract class SliderPageState<T extends StatefulWidget> extends State<T>
    with RouteAware {
  SnappingSheetController snapController = new SnappingSheetController()
    ..snapPositions = const [
      SnapPosition(positionPixel: 0.0),
      SnapPosition(positionFactor: 0.5),
      SnapPosition(positionFactor: 0.9),
    ]
    ..currentSnapPosition = SnapPosition(positionFactor: 0.5);
  SnapPosition _snap = SnapPosition(positionFactor: 0.5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    snapController.snapToPosition(snapController.snapPositions.first);
  }

  @override
  void didPushNext() {
    _snap = snapController.currentSnapPosition;
    snapController.snapToPosition(snapController.snapPositions.first);
  }

  @override
  void didPopNext() {
    if (_snap != null) snapController.snapToPosition(_snap);
  }

  Widget combine(BuildContext context,
      {Widget header,
      Color headerColor = const Color(0xff278f82),
      SnapPosition initSnapPosition = const SnapPosition(positionFactor: 0.5),
      Widget body,
      Widget background}) {
    return HitMask(
      child: SnappingSheet(
        child: background,
        snappingSheetController: snapController,
        initSnapPosition: initSnapPosition,
        grabbingHeight: 64,
        grabbing: _SliderPageGrabber(child: header, color: headerColor),
        sheetBelow: Container(color: Color(0xffeff6ee), child: body),
      ),
    );
  }
}
