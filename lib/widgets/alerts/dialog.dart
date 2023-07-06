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

Color infoColor = const Color(0xff0047BA);

/// The [ActiveAlertDialog] class provides a static method `activeDialog` to display an alert dialog with customizable options.
/// Overall, this class provides a flexible way to create and customize alert dialogs with ease in Flutter.
class ActiveAlertDialog {
  /// Displays an alert dialog with the specified parameters.
  ///
  /// The [context] parameter is the build context for the dialog.
  /// The [title] parameter is the title of the dialog (default is "Alert").
  /// The [message] parameter is the content message of the dialog.
  /// The [confirm] parameter is a custom widget to use as the confirm button.
  /// The [cancel] parameter is a custom widget to use as the cancel button.
  /// The [btnConfirm] parameter is a callback function for the confirm button.
  /// The [btnCancel] parameter is a callback function for the cancel button.
  /// The [btnConfirmText] parameter is the text to display on the confirm button (default is "Confirm").
  /// The [btnCancelText] parameter is the text to display on the cancel button (default is "Cancel").
  /// The [cancelTextColor] parameter is the color of the cancel button text.
  /// The [confirmTextColor] parameter is the color of the confirm button text.
  /// The [backgroundColor] parameter is the background color of the dialog.
  /// The [barrierDismissible] parameter determines if the dialog can be dismissed by tapping outside (default is `true`).
  /// The [buttonColor] parameter is the background color of the buttons.
  /// The [radius] parameter is the border radius of the dialog (default is 12).
  /// The [titleStyle] parameter is the style for the dialog title.
  /// The [messageTextStyle] parameter is the style for the dialog content message.
  /// The [titlePadding] parameter is the padding for the dialog title.
  /// The [messagePadding] parameter is the padding for the dialog content message.
  /// The [actions] parameter is a list of additional custom widgets to display as actions in the dialog.
  ///
  /// Returns a `Future` that resolves when the dialog is dismissed.
  static Future<void> activeDialog(
      BuildContext context, {
        String title = "Alert",
        String? message,
        Widget? confirm,
        Widget? cancel,
        VoidCallback? btnConfirm,
        VoidCallback? btnCancel,
        String? btnConfirmText,
        String? btnCancelText,
        Color? cancelTextColor,
        Color? confirmTextColor,
        Color? backgroundColor,
        bool barrierDismissible = true,
        Color? buttonColor,
        double radius = 12,
        TextStyle? titleStyle,
        TextStyle? messageTextStyle,
        EdgeInsetsGeometry? titlePadding,
        EdgeInsetsGeometry? messagePadding,
      }) async {

    // Determine if cancel and confirm buttons are provided
    var leanCancel = btnCancel != null || btnCancelText != null;
    var leanConfirm = btnConfirm != null || btnConfirmText != null;

    // Initialize actions list if not provided
    List<Widget> actions = [];

    // Add cancel button
    if (cancel != null) {
      actions.add(cancel);
    } else {
      if (leanCancel) {
        actions.add(
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: buttonColor ?? Colors.white, width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              btnCancel?.call();
              Navigator.pop(context);
            },
            child: Text(
              btnCancelText ?? "Cancel",
              style: TextStyle(color: cancelTextColor ?? Colors.black),
            ),
          ),
        );
      }
    }

    // Add confirm button
    if (confirm != null) {
      actions.add(confirm);
    } else {
      if (leanConfirm) {
        actions.add(
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: buttonColor ?? infoColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              btnConfirmText ?? "Confirm",
              style: TextStyle(color: confirmTextColor ?? Colors.white),
            ),
            onPressed: () {
              btnConfirm?.call();
            },
          ),
        );
      }
    }

    // Show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: titlePadding ?? const EdgeInsets.all(12),
          contentPadding: messagePadding ?? const EdgeInsets.all(12),
          backgroundColor: backgroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message ?? "",
                textAlign: TextAlign.center,
                style: messageTextStyle,
              ),
              const SizedBox(height: 16),
              ButtonTheme(
                minWidth: 70.0,
                height: 40.0,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 12,
                  runSpacing: 12,
                  children: actions,
                ),
              )
            ],
          ),
          buttonPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

/// The `ActiveProcessingDialog` class provides a static method `activeDialog` that
/// can be used to display a processing dialog in a Flutter application. This dialog
/// is typically shown to indicate that a task or process is in progress and to
/// provide feedback to the user.
class ActiveProcessingDialog {
  /// Displays a processing dialog with customizable options.
  ///
  /// [context] (required): The `BuildContext` object used to show the dialog.
  ///
  /// [processMessage] (optional): A string message to be displayed in the dialog.
  /// If provided, the message will be shown below the progress indicator.
  ///
  /// [textStyle] (optional): The text style for the `processMessage`.
  ///
  /// [progressColor] (optional): The color of the `CircularProgressIndicator`.
  ///
  /// [dialogColor] (optional): The color of the container that holds the
  /// `CircularProgressIndicator`.
  ///
  /// [strokeWidth] (optional): The stroke width of the `CircularProgressIndicator`.
  ///
  /// [progressWidth] (optional): The width of the `CircularProgressIndicator`.
  ///
  /// [progressHeight] (optional): The height of the `CircularProgressIndicator`.
  ///
  /// [alertWidth] (optional): The width of the dialog container.
  ///
  /// [alertHeight] (optional): The height of the dialog container.
  ///
  /// [alertRadius] (optional): The border radius of the dialog container.
  ///
  /// Returns a `Future<void>` which completes when the dialog is closed.
  static Future<void> activeDialog(
      BuildContext context, {
        String? processMessage,
        TextStyle? textStyle,
        Color? progressColor,
        Color? dialogColor,
        double? strokeWidth,
        double? progressWidth,
        double? progressHeight,
        double? alertWidth,
        double? alertHeight,
        double? alertRadius,
      }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            height: alertHeight ?? 200,
            width: alertWidth ?? 300,
            decoration: BoxDecoration(
              color: dialogColor ?? Colors.white,
              borderRadius: BorderRadius.circular(alertRadius ?? 12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: progressWidth ?? 70,
                  height: progressHeight ?? 70,
                  child: CircularProgressIndicator(
                    strokeWidth: strokeWidth ?? 5.0,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? infoColor),
                  ),
                ),
                const SizedBox(height: 30),
                processMessage != null
                    ? Center(
                  child: Text(
                    processMessage,
                    style: textStyle ??
                        const TextStyle(
                          color: Color(0xFF0047BA),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}