import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weup/utils/routes.dart';

import 'intro_base.dart';

class IntroScreenSlide extends StatelessWidget {
  IntroScreenSlide(
      {Key key,
      this.image,
      this.title,
      this.body,
      this.titleStyle,
      this.bodyStyle})
      : assert(image != null),
        assert(title != null),
        assert(body != null),
        super(key: key);
  final Widget image;
  final String title, body;
  final TextStyle titleStyle, bodyStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(45),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(child: image, height: 128),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                        color: Color(0xff698996),
                        fontWeight: FontWeight.w400,
                        fontSize: 64,
                        fontFamily: 'PT Sans')
                    .merge(titleStyle)),
            SizedBox(
              height: 96,
              child: Text(body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                          color: Color(0xff969696),
                          fontWeight: FontWeight.w300,
                          fontSize: 32,
                          fontFamily: 'Open Sans')
                      .merge(bodyStyle)),
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  IntroPage({Key key, this.child})
      : assert(child != null),
        super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
        color: Color(0xff969696),
        fontWeight: FontWeight.w300,
        fontSize: 32,
        fontFamily: 'Open Sans');

    return IntroScreen(
      pages: [
        IntroScreenSlide(
          image: Image.asset('assets/splash_screen/fav.png'),
          title: 'weup!',
          body: 'The best way to find entertaiment',
          titleStyle: TextStyle(color: Color(0xff278f82)),
        ),
        IntroScreenSlide(
          image: Image.asset('assets/splash_screen/bulb.png'),
          title: 'create',
          body: 'Your own events and invite people',
        ),
        IntroScreenSlide(
          image: Image.asset('assets/splash_screen/map.png'),
          title: 'explore',
          body: 'Map for interesting activity',
        ),
        IntroScreenSlide(
          image: Image.asset('assets/splash_screen/heart.png'),
          title: 'enjoy',
          body: 'Events and amusement',
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'As for now, authorization is perfomed by device (anonymously)',
                textAlign: TextAlign.center,
                style: textStyle),
            InkWell(
              child: Text('continue',
                  textAlign: TextAlign.center,
                  style: textStyle
                      .merge(TextStyle(decoration: TextDecoration.underline))),
              onTap: () => Navigator.of(context).pushReplacement(
                  SlideFromRightRoute(
                      page: child,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 300))),
            ),
          ],
        ),
//        Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: [
//            Text('log in to interact with people', style: textStyle),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: [
//                Text('or ', style: textStyle),
//                InkWell(
//                  child: Text('skip',
//                      style: textStyle.merge(
//                          TextStyle(decoration: TextDecoration.underline))),
//                  onTap: () => Navigator.of(context).pushReplacement(
//                      SlideFromRightRoute(
//                          page: child,
//                          curve: Curves.easeInOut,
//                          duration: Duration(milliseconds: 300))),
//                ),
//              ],
//            ),
//          ],
//        ),
      ],
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xffc2c2c2),
        activeSize: Size(22.0, 10.0),
        activeColor: Color(0xff969696),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
