import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class HitMaskTest extends SingleChildRenderObjectWidget {
  const HitMaskTest({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  HitMaskTestRender createRenderObject(BuildContext context) =>
      HitMaskTestRender();
}

class HitMaskTestRender extends RenderProxyBox {
  HitMaskTestRender({
    RenderBox child,
  }) : super(child);

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    BoxHitTestResult test = new BoxHitTestResult();
    super.hitTest(test, position: position);
    bool valid = test.path
        .any((HitTestEntry e) => e.target.runtimeType == HitMaskRender);
    return valid && super.hitTest(result, position: position);
  }
}

class HitMask extends SingleChildRenderObjectWidget {
  const HitMask({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  HitMaskRender createRenderObject(BuildContext context) => HitMaskRender();
}

class HitMaskRender extends RenderProxyBox {
  HitMaskRender({
    RenderBox child,
  }) : super(child);
}
