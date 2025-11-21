import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_page_transitions.dart';

class NavigationService {
  // Navigate to a new screen with animation
  static Future<T?> navigateTo<T>(
    Widget page, {
    TransitionType transitionType = TransitionType.slideRight,
    Duration duration = const Duration(milliseconds: 300),
    bool preventDuplicates = true,
    Map<String, dynamic>? arguments,
    Curve curve = Curves.easeInOut,
  }) {
    return Get.to<T>(
      () => page,
      transition: _getGetxTransition(transitionType),
      duration: duration,
      curve: curve,
      preventDuplicates: preventDuplicates,
      arguments: arguments,
    ) ?? Future<T?>.value(null);
  }

  // Navigate back with animation
  static void goBack<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    Get.back(
      result: result,
      closeOverlays: closeOverlays,
      canPop: canPop,
      id: id,
    );
  }

  // Replace current screen with animation
  static Future<T?> replaceTo<T>(
    Widget page, {
    TransitionType transitionType = TransitionType.fadeAndScale,
    Duration duration = const Duration(milliseconds: 300),
    bool preventDuplicates = true,
    Map<String, dynamic>? arguments,
    Curve curve = Curves.easeInOut,
  }) {
    return Get.off<T>(
      () => page,
      transition: _getGetxTransition(transitionType),
      duration: duration,
      curve: curve,
      preventDuplicates: preventDuplicates,
      arguments: arguments,
    ) ?? Future<T?>.value(null);
  }

  // Replace all screens with animation
  static Future<T?> replaceAllTo<T>(
    Widget page, {
    TransitionType transitionType = TransitionType.fadeAndScale,
    Duration duration = const Duration(milliseconds: 300),
    Map<String, dynamic>? arguments,
    Curve curve = Curves.easeInOut,
  }) {
    return Get.offAll<T>(
      () => page,
      transition: _getGetxTransition(transitionType),
      duration: duration,
      curve: curve,
      arguments: arguments,
    ) ?? Future<T?>.value(null);
  }

  // Convert our TransitionType to GetX's Transition
  static Transition _getGetxTransition(TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return Transition.fade;
      case TransitionType.slideRight:
        return Transition.rightToLeft;
      case TransitionType.slideLeft:
        return Transition.leftToRight;
      case TransitionType.slideUp:
        return Transition.downToUp;
      case TransitionType.slideDown:
        return Transition.upToDown;
      case TransitionType.scale:
        return Transition.zoom;
      case TransitionType.size:
        return Transition.size;
      case TransitionType.fadeAndScale:
        return Transition.fadeIn;
      case TransitionType.rotation:
        // GetX doesn't have a direct rotation transition
        return Transition.zoom;
      default:
        return Transition.rightToLeft;
    }
  }
}