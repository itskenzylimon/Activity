import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {

  ///[items] list of the dropdown menu
  List<DropdownMenuItem<String>> items;

   /// [color] dropdown widget color.
  Color? color;

  ///[border] this is the borderline around the dropdown.
  Border? border;

  ///[borderRadius] this is the radius of th dropdown widget.
  BorderRadius? borderRadius;

  ///[gradient] color gradient of the dropdown widget.
  Gradient? gradient;

  ///[shape] this is the shape of the  dropdown widget.
  BoxShape shape;

  ///[icon] the dropdown icon.
  Icon icon;

  ///[leadIcon] the leading icon of the dropdown.
  IconData leadIcon;


  String value;

  ///[iconPadding] padding around the icon.
  EdgeInsets iconPadding;
  
  ///[padding] padding around the dropdown widget.
  EdgeInsets padding;

  ///[style] style of the dropdown text i.e fontsize ,fontweight
  TextStyle? style;

  ///[underline] this is the focused line of the dropdown
  Widget? underline;

  ///[isExpanded] sets either the dropdown to be expanded
  bool isExpanded;

  ///[addLeadicon] adds icon at the beggining of the dropdown
  bool addLeadicon;

  bool autoFocus;

  ///[iconEnableColor] color of the icon when its enabled
  Color? iconEnableColor;

  ///[iconDisableColor] color of the icon when its disabled
  Color? iconDisableColor;

  ///[dropdownColor] color of the dropdown
  Color? dropdownColor;

  ///[focusColor] color of the dropdown when its focused
  Color? focusColor;

  
  void Function(Object? value) onChanged;
  AlignmentGeometry alignment;
  FocusNode? node;
  Widget? hint;
  Widget? disabledHint;

  DropdownWidget({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.borderRadius,
    this.border,
    this.color,
    this.gradient,
    required this.leadIcon,
    this.icon = const Icon(Icons.arrow_drop_down),
    this.iconPadding = const EdgeInsets.only(left: 20),
    this.shape = BoxShape.rectangle,
    this.padding = const EdgeInsets.only(left: 20, right: 20),
    this.style,
    this.underline,
    this.addLeadicon = false,
    this.isExpanded = true,
    this.iconEnableColor,
    this.iconDisableColor,
    this.dropdownColor,
    this.focusColor,
    this.autoFocus = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.node,
    this.hint,
    this.disabledHint,
  }) : super(key: key);

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  List<BoxShadow>? boxShadow;

  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            color: widget.color,
            border: widget.border ?? Border.all(color: Colors.black45),
            borderRadius: widget.borderRadius,
            boxShadow: boxShadow,
            gradient: widget.gradient,
            shape: widget.shape),
        child: Padding(
            padding: widget.padding,
            child: Center(
              child: Row(
                children: [
                  widget.addLeadicon ? Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(widget.leadIcon,size: 18,),
                  ) : const SizedBox(),
                 
                  Expanded(
                    
                    child: DropdownButton(
                      value: widget.value,
                      items: widget.items.map((e) {
                        return e;
                      }).toList(),
                      onChanged: (value) {
                        widget.onChanged(value);
                      },
                      onTap: onTap,
                      icon: Padding(padding: widget.iconPadding, child: widget.icon),
                      iconEnabledColor: widget.iconEnableColor,
                      iconDisabledColor: widget.iconDisableColor,
                      style: widget.style,
                      dropdownColor: widget.dropdownColor,
                      underline: widget.underline ?? Container(),
                      isExpanded: widget.isExpanded,
                      autofocus: widget.autoFocus,
                      alignment: widget.alignment,
                      focusNode: widget.node,
                      hint: widget.hint,
                      disabledHint: widget.disabledHint,
                    ),
                  ),
                ],
              ),
            )));
  }
}
