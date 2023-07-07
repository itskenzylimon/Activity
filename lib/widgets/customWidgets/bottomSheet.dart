import 'package:flutter/material.dart';

/// The [ActiveBottomSheet] class provides a static method `activeSheet` that
/// displays a modal bottom sheet in a Flutter application. This bottom sheet
/// can be customized with various parameters to control its appearance and behavior.
class ActiveBottomSheet {
  /// Displays a modal bottom sheet with customizable options.
  ///
  /// [context] (required): The `BuildContext` object used to show the bottom sheet.
  ///
  /// [bottomSheet] (required): The widget that represents the content of the bottom sheet.
  ///
  /// [backgroundColor] (optional): The background color of the bottom sheet.
  ///
  /// [elevation] (optional): The elevation of the bottom sheet.
  ///
  /// [shape] (optional): The shape of the bottom sheet. By default, it uses a rounded rectangle shape
  /// with a 15 pixels border radius for the top corners.
  ///
  /// [clipBehavior] (optional): The clipping behavior of the bottom sheet.
  ///
  /// [constraints] (optional): The constraints applied to the size of the bottom sheet.
  ///
  /// [barrierColor] (optional): The color of the barrier behind the bottom sheet.
  ///
  /// [isScrollControlled] (optional): Whether the bottom sheet can be scrolled when its content exceeds the screen height.
  ///
  /// [useRootNavigator] (optional): Whether to use the root navigator to show the bottom sheet.
  ///
  /// [isDismissible] (optional): Whether the bottom sheet can be dismissed by tapping outside.
  ///
  /// [enableDrag] (optional): Whether the bottom sheet can be dragged up and down.
  ///
  /// [showDragHandle] (optional): Whether to show a drag handle at the top of the bottom sheet.
  ///
  /// [useSafeArea] (optional): Whether to apply safe area insets to the bottom sheet.
  ///
  /// [routeSettings] (optional): The route settings for the bottom sheet.
  ///
  /// [transitionAnimationController] (optional): The animation controller used for the bottom sheet transition.
  ///
  /// [anchorPoint] (optional): The anchor point for the bottom sheet.
  ///
  /// Returns a `Future<void>` which completes when the bottom sheet is closed.
  static Future<void> activeSheet({
    required BuildContext context,
    required Widget bottomSheet,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      builder: (BuildContext context) {
        return bottomSheet;
      },
    );
  }
}