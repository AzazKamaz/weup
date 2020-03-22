import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  final List<Widget> pages;
  final DotsDecorator dotsDecorator;
  final int initialPage;

  const IntroScreen({
    Key key,
    @required this.pages,
    this.initialPage,
    this.dotsDecorator = const DotsDecorator(),
  })  : assert(pages != null),
        assert(pages.length > 0),
        super(key: key);

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  PageController _controller;
  double _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage?.toDouble() ?? 0.0;
    _controller =
        PageController(initialPage: widget.initialPage ?? 0, keepPage: true);
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics is PageMetrics) {
      setState(() => _currentPage = metrics.page);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: PageView(
                  controller: _controller,
                  children: widget.pages,
                  physics: const BouncingScrollPhysics())),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: SafeArea(
              child: Center(
                child: DotsIndicator(
                  dotsCount: widget.pages.length,
                  position: _currentPage,
                  decorator: widget.dotsDecorator,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
