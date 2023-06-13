import 'package:flutter/material.dart';


///[RadioButtonTextPosition] the position of text of the radio button.
enum RadioButtonTextPosition {
  right,
  left,
}
class RadioButton<T> extends StatelessWidget {

  ///[description] this is the text describing the radio button.
  final String description;

  ///[value] value of radio button.
  final T value;

  ///[groupValue] group value of the radio button.
  final T groupValue;

  ///[onChanged]called when the user initiates a change to the dropdown
  final void Function(T?)? onChanged;

  ///[textPosition] position of text either right or left
  final RadioButtonTextPosition textPosition;

  ///[activeColor] color of the dropdown when its active
  final Color? activeColor;

  ///[fillColor] color of the drop
  final Color? fillColor;

  ///[textStyle] style of the dropdown's texts
  final TextStyle? textStyle;

  const RadioButton({
    required this.description,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.textPosition = RadioButtonTextPosition.right,
    this.activeColor,
    this.fillColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (this.onChanged != null) {
          this.onChanged!(value);
        }
      },
      child: Row(
        mainAxisAlignment: this.textPosition == RadioButtonTextPosition.right ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: <Widget>[
          this.textPosition == RadioButtonTextPosition.left
              ? Expanded(
                  child: Text(
                    this.description,
                    style: this.textStyle,
                    textAlign: TextAlign.right,
                  ),
                )
              : Container(),
          Radio<T>(
            groupValue: groupValue,
            onChanged: this.onChanged,
            value: this.value,
            activeColor: activeColor,
            fillColor: fillColor != null ? MaterialStateProperty.all(fillColor) : null,
          ),
          this.textPosition == RadioButtonTextPosition.right
              ? Expanded(
                  child: Text(
                    this.description,
                    style: this.textStyle,
                    textAlign: TextAlign.left,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}