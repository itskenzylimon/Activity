import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  const SwitchButton({
    Key? key,
    required this.value,
    required this.onToggle,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.activeTextColor = Colors.white70,
    this.inactiveTextColor = Colors.white70,
    this.toggleColor = Colors.white,
    this.activeToggleColor,
    this.inactiveToggleColor,
    this.width = 70.0,
    this.height = 35.0,
    this.toggleSize = 25.0,
    this.valueFontSize = 16.0,
    this.borderRadius = 20.0,
    this.padding = 4.0,
    this.showOnOff = false,
    this.activeText,
    this.inactiveText,
    this.activeTextFontWeight,
    this.inactiveTextFontWeight,
    this.switchBorder,
    this.activeSwitchBorder,
    this.inactiveSwitchBorder,
    this.toggleBorder,
    this.activeToggleBorder,
    this.inactiveToggleBorder,
    this.activeIcon,
    this.inactiveIcon,
    this.duration = const Duration(milliseconds: 200),
    this.disabled = false,
  })  : assert(
            (switchBorder == null || activeSwitchBorder == null) &&
                (switchBorder == null || inactiveSwitchBorder == null),
            'Cannot provide switchBorder when an activeSwitchBorder or inactiveSwitchBorder was given\n'
            'To give the switch a border, use "activeSwitchBorder: border" or "inactiveSwitchBorder: border".'),
        assert(
            (toggleBorder == null || activeToggleBorder == null) &&
                (toggleBorder == null || inactiveToggleBorder == null),
            'Cannot provide toggleBorder when an activeToggleBorder or inactiveToggleBorder was given\n'
            'To give the toggle a border, use "activeToggleBorder: color" or "inactiveToggleBorder: color".'),
        super(key: key);
  final bool value;
  final ValueChanged<bool> onToggle;

  ///[showOnOff]sets either to show or not show the 'on' and 'off' text 
  final bool showOnOff;

  final String? activeText;
  final String? inactiveText;

  ///[activeColor]color of the switchbutton when the button is active
  final Color activeColor;

  ///[inactiveColor]color of the switchbutton when the button is inactive
  final Color inactiveColor;

  ///[activeTextColor] text color of the switchbutton when its active
  final Color activeTextColor;

  ///[inactiveTextColor] text color of the switchbutton when its inactive
  final Color inactiveTextColor;

  ///[activeTextFontWeight] text fontweight  of the switchbutton when its active
  final FontWeight? activeTextFontWeight;

  ///[inactiveTextFontWeight] text fontweight  of the switchbutton when its inactive
  final FontWeight? inactiveTextFontWeight;

  ///[toggleColor] this is the color of the switchbutton when it is switched
  final Color toggleColor;

  ///[activeToggleColor] toggle color when the switchbutton is switched to active
  final Color? activeToggleColor;

  ///[inactiveToggleColor] toggle color when the switchbutton is switched to inactive
  final Color? inactiveToggleColor;

  ///[width]width of the switchbutton
  final double width;

  ///[height]height of the switchbutton
  final double height;

  ///[toggleSize] size of the toggle 
  final double toggleSize;
  
  ///[valueFontSize] this is the font size of the value of the switchbutton
  final double valueFontSize;

  ///[borderRadius] radius of the  switchbutton.
  final double borderRadius;

  ///[padding] inside padding of the swithcbutton
  final double padding;

  ///[switchBorder] this is the outline border.
  final BoxBorder? switchBorder;

  ///[activeSwitchBorder] this is the outline border when the switch is active.
  final BoxBorder? activeSwitchBorder;

  ///[inactiveSwitchBorder] this is the outline border when the switch is inactive.
  final BoxBorder? inactiveSwitchBorder;

  ///[toggleBorder] border of the toggle
  final BoxBorder? toggleBorder;

  ///[activeToggleBorder] border of the toggle when its active.
  final BoxBorder? activeToggleBorder;

  ///[inactiveToggleBorder] border of the toggle when its inactive.
  final BoxBorder? inactiveToggleBorder;

  ///[activeIcon] icon of the switch when its active.
  final Widget? activeIcon;

  ///[inactiveIcon] icon of the switch when its inactive.
  final Widget? inactiveIcon;

  ///[duration] the time the switch takes to turn on or off.
  final Duration duration;

  
  final bool disabled;

  @override
  SwitchButtonState createState() => SwitchButtonState();
}

class SwitchButtonState extends State<SwitchButton>
    with SingleTickerProviderStateMixin {
  late final Animation _toggleAnimation;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
      duration: widget.duration,
    );
    _toggleAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value == widget.value) return;

    if (widget.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color toggleColor = Colors.white;
    Color switchColor = Colors.white;
    Border? switchBorder;
    Border? toggleBorder;

    if (widget.value) {
      toggleColor = widget.activeToggleColor ?? widget.toggleColor;
      switchColor = widget.activeColor;
      switchBorder = widget.activeSwitchBorder as Border? ??
          widget.switchBorder as Border?;
      toggleBorder = widget.activeToggleBorder as Border? ??
          widget.toggleBorder as Border?;
    } else {
      toggleColor = widget.inactiveToggleColor ?? widget.toggleColor;
      switchColor = widget.inactiveColor;
      switchBorder = widget.inactiveSwitchBorder as Border? ??
          widget.switchBorder as Border?;
      toggleBorder = widget.inactiveToggleBorder as Border? ??
          widget.toggleBorder as Border?;
    }

    double textSpace = widget.width - widget.toggleSize;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: widget.width,
          child: Align(
            child: GestureDetector(
              onTap: () {
                if (!widget.disabled) {
                  if (widget.value) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }

                  widget.onToggle(!widget.value);
                }
              },
              child: Opacity(
                opacity: widget.disabled ? 0.6 : 1,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  padding: EdgeInsets.all(widget.padding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    color: switchColor,
                    border: switchBorder,
                  ),
                  child: Stack(
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: widget.value ? 1.0 : 0.0,
                        duration: widget.duration,
                        child: Container(
                          width: textSpace,
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          alignment: Alignment.centerLeft,
                          child: _activeText,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedOpacity(
                          opacity: !widget.value ? 1.0 : 0.0,
                          duration: widget.duration,
                          child: Container(
                            width: textSpace,
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            alignment: Alignment.centerRight,
                            child: _inactiveText,
                          ),
                        ),
                      ),
                      Align(
                        alignment: _toggleAnimation.value,
                        child: Container(
                          width: widget.toggleSize,
                          height: widget.toggleSize,
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: toggleColor,
                            border: toggleBorder,
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Stack(
                              children: [
                                Center(
                                  child: AnimatedOpacity(
                                    opacity: widget.value ? 1.0 : 0.0,
                                    duration: widget.duration,
                                    child: widget.activeIcon,
                                  ),
                                ),
                                Center(
                                  child: AnimatedOpacity(
                                    opacity: !widget.value ? 1.0 : 0.0,
                                    duration: widget.duration,
                                    child: widget.inactiveIcon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FontWeight get _activeTextFontWeight =>
      widget.activeTextFontWeight ?? FontWeight.w900;
  FontWeight get _inactiveTextFontWeight =>
      widget.inactiveTextFontWeight ?? FontWeight.w900;


  ///[_activeText] this is the text when the switch is active.
  Widget get _activeText {
    if (widget.showOnOff) {
      return Text(
        widget.activeText ?? "On",
        style: TextStyle(
          color: widget.activeTextColor,
          fontWeight: _activeTextFontWeight,
          fontSize: widget.valueFontSize,
        ),
      );
    }

    return const Text("");
  }


  ///[_inactiveText] this is the text when the switch is inactive.
  Widget get _inactiveText {
    if (widget.showOnOff) {
      return Text(
        widget.inactiveText ?? "Off",
        style: TextStyle(
          color: widget.inactiveTextColor,
          fontWeight: _inactiveTextFontWeight,
          fontSize: widget.valueFontSize,
        ),
        textAlign: TextAlign.right,
      );
    }

    return const Text("");
  }
}