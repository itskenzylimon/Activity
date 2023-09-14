import 'package:flutter/material.dart';

/// [MessageType] MessageType is used to determine the types of toast/snackbar
/// messages that will be displayed to the user.
/// There are 5 message types i.e success message, warning message, information
/// message, error message and normal message.
/// Each MessageType has its own corresponding colors
enum MessageType { success, warning, info, error, normal }

/// [MessageTime] used to dictate the time a snackbar will be shown on the
/// screen
/// [short] Message will be displayed for 1 second
///
/// [medium] Message will be displayed for 3 seconds
///
/// [long] Message will be displayed for 4/5 seconds
enum MessageTime { short, medium, long }

Color infoColor = const Color(0xff0047BA);
Color infoShade = const Color(0xFFDDEAFE);
Color successColor = const Color(0xFF065F46);
Color successShade = const Color(0xFFD1FAE5);
Color errorColor = const Color(0xFFB32218);
Color errorShade = const Color(0xFFFEFAFA);

/// [ShowMessage] This is a class that is used to tie together MessageType and
/// message that will be shown to the user as a snack bar message
class ShowMessage {
  final String message;
  final MessageType messageType;
  final MessageTime messageTime;

  ShowMessage(this.message, this.messageType, this.messageTime);
}

/// [SnackbarMessage]A class for displaying snackbar-like messages as overlays.
abstract class SnackbarMessage {
  /// The [showSnackMessage] showSnackMessage method takes in a BuildContext context, a ShowMessages
  /// object showMessage, and a callback function removeOverlay. It uses the
  /// Overlay.of(context) method to get the OverlayState associated with the
  /// given context. If the overlayState is null, it returns early.
  ///
  /// The [context] is the BuildContext of the widget where the overlay is being shown.
  /// The [showMessage] represents the message to be displayed.
  /// The [removeOverlay] function is called to remove the overlay when needed.
  static void showSnackMessage(BuildContext context, ShowMessage showMessage) {
    OverlayState? overlayState = Overlay.of(context);

    /// This is a null check for overlayState created above. If the state is
    /// null the methods ends at this point
    if (overlayState == null) return;

    /// The overlayEntry is created using the overlay builder and inserted into
    /// the overlayState.
    OverlayEntry overlayEntry;

    /// Inside the overlay builder, a Positioned widget is used to position the
    /// overlay at the top of the screen. It creates a snackbar-like container
    /// using Material and Container widgets, with a specified shape,
    /// decoration, and content.
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).size.height * 0.07,
        child: Material(
          shape: ShapeBorder.lerp(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            0.5, // Interpolation value between 0.0 and 1.0
          ),
          child: Container(
            height: 70,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: showMessage.messageType == MessageType.success
                  ? successShade
                  : showMessage.messageType == MessageType.error
                      ? errorShade
                      : showMessage.messageType == MessageType.info
                          ? infoShade
                          : showMessage.messageType == MessageType.normal
                              ? Colors.grey[300]
                              : Colors.grey[300],
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  color: showMessage.messageType == MessageType.success
                      ? successColor
                      : showMessage.messageType == MessageType.error
                          ? errorColor
                          : showMessage.messageType == MessageType.info
                              ? infoColor
                              : showMessage.messageType == MessageType.normal
                                  ? Colors.black
                                  : Colors.black,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showMessage.message,
                  style: TextStyle(
                    color: showMessage.messageType == MessageType.success
                        ? successColor
                        : showMessage.messageType == MessageType.error
                            ? errorColor
                            : showMessage.messageType == MessageType.info
                                ? infoColor
                                : showMessage.messageType == MessageType.normal
                                    ? Colors.black
                                    : Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    overlayState.insert(overlayEntry);

    Duration shortTime = const Duration(seconds: 1);
    Duration mediumTime = const Duration(seconds: 3);
    Duration longTime = const Duration(seconds: 5);

    /// After a delay of 4 seconds, the overlayEntry is removed using the remove method.
    Future.delayed(
      Duration(
        seconds: showMessage.messageTime == MessageTime.short
            ? 1
            : showMessage.messageTime == MessageTime.medium
                ? 3
                : showMessage.messageTime == MessageTime.long
                    ? 5
                    : 3,
      ),
    ).then((_) {
      overlayEntry.remove();
    });
  }
}
