import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import '../main.dart';
import '../widgets/ignore_top_pointer.dart';

class _SliderPageGrabber extends StatelessWidget {
  _SliderPageGrabber({this.child});
  Widget child;
  @override
  Widget build(BuildContext context) {
    var grabber = SizedBox.fromSize(
      size: const Size.fromHeight(24),
      child: Container(
        margin: EdgeInsets.all(8),
        alignment: Alignment.topCenter,
        child: SizedBox.fromSize(
          size: const Size(64, 8),
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
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        color: Color(0xff78aaf7),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          grabber,
          child,
        ],
      ),
    );

    return grabbing;
  }
}

abstract class SliderPageState<T extends StatefulWidget> extends State<T>
    with RouteAware {
  SnappingSheetController _controller = new SnappingSheetController();
  SnapPosition _snap;

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
    _controller.snapToPosition(_controller.snapPositions.first);
  }

  @override
  void didPushNext() {
    _snap = _controller.currentSnapPosition;
    _controller.snapToPosition(_controller.snapPositions.first);
  }

  @override
  void didPopNext() {
    if (_snap != null) _controller.snapToPosition(_snap);
  }

  Widget combine(BuildContext context, {Widget header, Widget body}) {
    return HitMask(
      child: SnappingSheet(
        snappingSheetController: _controller,
        grabbingHeight: 64,
        grabbing: _SliderPageGrabber(child: header),
        sheetBelow: body,
      ),
    );
  }
}
