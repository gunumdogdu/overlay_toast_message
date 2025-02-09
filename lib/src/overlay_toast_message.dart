import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:overlay_toast_message/src/manager.dart';

class OverlayToastMessage extends StatefulWidget {
  final Widget? widget;
  final Duration duration;
  final Duration animDuration;
  final String? textMessage;
  final Decoration? decoration;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? textStyle;

  OverlayToastMessage.show(
    {
    super.key,
    this.widget,
    this.textMessage,
    this.duration = const Duration(seconds: 3),
    this.animDuration = const Duration(milliseconds: 100),
    bool dismissAll = false,
    this.decoration,
    this.backgroundColor,
    this.borderRadius,
    this.textStyle,
  }) {
    assert(widget != null || textMessage != null);
    assert(duration > animDuration);

    final over = OverlayEntry(builder: (BuildContext overlayContext) => this);
    

    final manager = Manager(duration, over);
    if (dismissAll) OverlayToastManager().dismissAll();
    OverlayToastManager().add(manager);
  }

  @override
  State<OverlayToastMessage> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<OverlayToastMessage> {
  Offset offset = const Offset(0, 1);
  late Timer timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      offset = const Offset(0, 0);
      setState(() {});
    });

    timer = Timer(widget.duration - widget.animDuration, () {
      offset = const Offset(0, 1);
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget w = widget.widget ??
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: widget.decoration ??
                  BoxDecoration(
                    color: widget.backgroundColor ?? Colors.black38,
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                        color: Colors.black12,
                      )
                    ],
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  widget.textMessage!,
                  style: widget.textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );

    w = AnimatedSlide(
      duration: widget.animDuration,
      offset: offset,
      child: w,
    );

    final mediaQuery = MediaQueryData.fromWindow(ui.window);
    w = Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: mediaQuery.padding.top,
          bottom: mediaQuery.padding.bottom,
        ),
        child: w,
      ),
    );

    w = IgnorePointer(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.transparent,
          child: w,
        ),
      ),
    );

    return w;
  }
}
