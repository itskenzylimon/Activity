import 'package:flutter/material.dart';

class CheckBoxWidget extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  ///[checkedIconColor] this is the color of the checked icon
  final Color checkedIconColor;

  ///[checkedFillColor] this is the fill color when checkbox clicked
  final Color checkedFillColor;

  ///[checkedIcon] this the icon of the checked checkbox
  final IconData checkedIcon;

  ///[uncheckedIconColor] color of the unchecked icon
  final Color uncheckedIconColor;

  ///[uncheckedFillColor] fill color of unclicked Checkbox
  final Color uncheckedFillColor;

  ///[uncheckedIcon] this the icon of the unchecked checkbox
  final IconData uncheckedIcon;

  ///[borderWidth] the width border of the checkbox
  final double? borderWidth;

  ///[checkBoxSize]Size of the checkBox
  final double? checkBoxSize;

  ///[shouldShowBorder] sets either to show border or not show when you add true or false
  final bool shouldShowBorder;

  ///[borderColor] the bordercolor of the checkbox
  final Color? borderColor;

  ///[borderRadius] radius of the checkbox
  final double? borderRadius;

  ///[splashRadius] the radius of the splash effect around the checkbox is clicked
  final double? splashRadius;

  ///[splashColor] the color of the splash effect around the checkbox is clicked
  final Color? splashColor;

  ///[tooltip] text to show tip about the checkbox
  final String? tooltip;

  ///[mouseCursors] the effect when the mouse is on top of the  checkbox
  final MouseCursor? mouseCursors;

  const CheckBoxWidget({
    Key? key,
    required this.value,
    required this.onChanged,
    this.checkedIconColor = Colors.white,
    this.checkedFillColor = Colors.teal,
    this.checkedIcon = Icons.check,
    this.uncheckedIconColor = Colors.white,
    this.uncheckedFillColor = Colors.white,
    this.uncheckedIcon = Icons.close,
    this.borderWidth,
    this.checkBoxSize,
    this.shouldShowBorder = false,
    this.borderColor,
    this.borderRadius,
    this.splashRadius,
    this.splashColor,
    this.tooltip,
    this.mouseCursors,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CheckBoxWidgetState createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  late bool _checked;
  late CheckStatus _status;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(CheckBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  void _init() {
    _checked = widget.value;
    if (_checked) {
      _status = CheckStatus.checked;
    } else {
      _status = CheckStatus.unchecked;
    }
  }

  Widget _buildIcon() {
    late Color fillColor;
    late Color iconColor;
    late IconData iconData;

    switch (_status) {
      case CheckStatus.checked:
        fillColor = widget.checkedFillColor;
        iconColor = widget.checkedIconColor;
        iconData = widget.checkedIcon;
        break;
      case CheckStatus.unchecked:
        fillColor = widget.uncheckedFillColor;
        iconColor = widget.uncheckedIconColor;
        iconData = widget.uncheckedIcon;
        break;
    }

    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? 6)),
        border: Border.all(
          color: widget.shouldShowBorder ? (widget.borderColor ?? Colors.teal.withOpacity(0.6)) : (!widget.value ? (widget.borderColor ?? Colors.teal.withOpacity(0.6)) : Colors.transparent),
          width: widget.shouldShowBorder ? widget.borderWidth ?? 2.0 : 1.0,
        ),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: widget.checkBoxSize ?? 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _buildIcon(),
      onPressed: () => widget.onChanged(!_checked),
      splashRadius: widget.splashRadius,
      splashColor: widget.splashColor,
      tooltip: widget.tooltip,
      mouseCursor: widget.mouseCursors ?? SystemMouseCursors.click,
    );
  }
}

enum CheckStatus {
  checked,
  unchecked,
}