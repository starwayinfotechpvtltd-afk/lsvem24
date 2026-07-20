import 'dart:async';
import 'package:flutter/material.dart';

class NavigationObserver extends NavigatorObserver {
  static bool isNavigating = false;

  void _unlock() {
    Future.delayed(const Duration(milliseconds: 350), () {
      isNavigating = false;
    });
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    isNavigating = true;
    _unlock();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    isNavigating = true;
    _unlock();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    isNavigating = true;
    _unlock();
  }
}