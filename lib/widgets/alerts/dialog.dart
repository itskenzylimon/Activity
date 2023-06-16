import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// This is a custom widget that can be used to create a dialog box
class ADialog extends ActiveView<ActiveController> {
  /// [viewContext] : is the function that returns the widget to be rendered
  final Function viewContext;
  /// [barrierDismissible] : is a flag that determines if the dialog can be dismissed
  final bool barrierDismissible;
  /// [backgroundColor] : is the background color of the dialog
  final Color? backgroundColor;
  /// [margin] : is the margin of the dialog
  final EdgeInsets margin;
  const ADialog({
    super.key,
    required super.activeController,
    required this.viewContext,
    this.barrierDismissible = true,
    this.backgroundColor = Colors.black12,
    this.margin = const EdgeInsets.all(20),
  });

  @override
  ActiveState<ActiveView<ActiveController>, ActiveController> createActivity() =>
      _ActView(
          activeController,
          viewContext,
          barrierDismissible,
          backgroundColor,
          margin);
}

class _ActView extends ActiveState<ADialog, ActiveController> {
  _ActView(
      super.activeController,
      this.viewContext,
      this.barrierDismissible,
      this.backgroundColor,
      this.margin);
  /// [viewContext] : is the function that returns the widget to be rendered and
  /// expects a [BuildContext] as a parameter
  final Function viewContext;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    Widget newChild = viewContext.call(context);
    return Stack(
      children: [
        /// This is the background of the dialog, with gesture detector for
        /// dismissing the dialog
        GestureDetector(
          onTap: () {
            if (barrierDismissible) {
              Navigator.pop(context);
            }
          },
          child: Container(
            color: backgroundColor,
          ),
        ),
        Container(
          margin: margin,
          child: Center(child: newChild),
        )
      ],
    );
  }

}