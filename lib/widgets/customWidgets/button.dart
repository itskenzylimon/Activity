import 'package:flutter/material.dart';


/// [BtnSizeHeight]is the Height size of the button 
/// /// "sm" is the smaller size & "lg" is the large size
enum BtnSizeHeight { sm, md, lg }


/// [BtnSizeWidth] is the Width size of the button 
/// "sm" is the smaller size & "lg" is the large size.
enum BtnSizeWidth { sm, md, lg }

/// [BtnColor]Color of the button 
enum BtnColor { primary, secondary }

/// [BtnRadius]is the Radius of the button according to the size of the button. 
/// "sm" is the smaller size & "lg" is the large size.
enum BtnRadius { sm, md, lg }


/// [buttonWidget]This is a custom widget that can be used to create a button
Widget buttonWidget(
    {
      String? text,/// [text] Button's text
      BtnSizeHeight btnSizeHeight = BtnSizeHeight.lg,
    BtnSizeWidth? btnSizeWidth,

    /// [btnColor]This is the color of the button i.e prymarycolor, secondaryColor || Any other color.
    Color? btnColor,

    ///[outlineColor]this is the color of the outside line around the button.
    Color? outlineColor,

    ///[shadowColor]This is the shadow color of the button.
    Color? shadowColor,

    ///[hoverColor]This is the color that appears when the button is hovered.
    Color? hoverColor,

    ///[textColor]this the button's text color.
    Color? textColor,

    ///t[icon]his the button's icon
    IconData? icon,

    ///[endicon] is Icon that appears at the end of the button.
    IconData? endicon,

    /// [btnhoverColor]is the color that appears when the button is hovered.
    Color? btnhoverColor,

    /// [btnRadius]This is the Radius of the button according to the size of the button .
          /// "sm" is the smaller size & "lg" is the large size'''
    BtnRadius? btnRadius,
          
    
    ///[btnDisabledColor]This is the button's color when the button is disabled.
    Color? btnDisabledColor,


    double? radius,
    
    ///[isIconOnly]this sets either a button with only an icon or a button with text
    bool isIconOnly = false,

    ///[showicon]sets the button to show icon or not by adding true of false
    bool showicon = false, 

    ///[showEndicon]sets the button to show endicon or not by adding true or false.
    bool showEndicon = false,

    ///[onTap]callback function of the button.
     final void Function()? onTap, 
    }) {

  ///[btnSizeHeight] is constant height  for small and large button.
  double height = btnSizeHeight == BtnSizeHeight.sm ? 45 : 65;
  
  ///[btnSizeWidth]is constant width  for small and large button.
  double width = btnSizeWidth == BtnSizeWidth.sm ? 160 : 250;


  /// [isHovered]checks if button is hovered,if true then changes the color .
  late bool isHovered = false;
  
  ///[isDisabled]checks if button is disabled,if true then changes the color
  late bool isDisabled = false;

  return isIconOnly
      ? InkWell(
        hoverColor: hoverColor?? Colors.white,
          onHover: (hovered) {
            isHovered = hovered;
          },
          focusColor: hoverColor?? Colors.white,
        child: Container(
            height: height,
            width: 60,
            decoration: BoxDecoration(
                color: isHovered ? hoverColor : btnColor?? Colors.white,/// If button color is not added the button will be whiteColor
                borderRadius: BorderRadius.circular(radius?? 0)),
                child: Center(
                  child: Icon(icon,size: 30,),
                ),
          ),
      )
      : InkWell(
        onTap: onTap,/// This is you place your function
          hoverColor: hoverColor?? Colors.white,
          highlightColor: hoverColor?? Colors.white,
          splashColor: hoverColor?? Colors.white,
          onHover: (value) {
            isHovered = value;
          },
          focusColor: hoverColor?? Colors.white,
          child: isDisabled
              ? Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                      color: btnColor?? Colors.white,/// If button color is not added the button will be whiteColor
                     
                      borderRadius: BorderRadius.circular(radius?? 10)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Row(
                        children: [
                     
                          Text(
                            text!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                      color: isHovered ? btnColor : btnColor?? Colors.white,
                      border: Border.all(
                        color: outlineColor?? Colors.white,
                        width: 0.9
                      ),
                       boxShadow: [
                        BoxShadow(
                          color: shadowColor?? Colors.white,
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(1, 1), /// changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(radius?? 10)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Row(
                       mainAxisAlignment: showicon? MainAxisAlignment.center :  MainAxisAlignment.center,
                        children: [
                               showicon ?  Padding(
                                 padding: const EdgeInsets.only(left: 0,right: 20),
                                 child: Icon(icon,size: 30,),
                               ): const SizedBox(),
                          Text(
                            text!,
                            style:  TextStyle(
                                fontSize: 16,
                                color: textColor?? Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          showEndicon ?Padding(
                                 padding: const EdgeInsets.only(left: 20,right: 0),
                                 child: Icon(endicon,size: 30,),
                               ): const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
        );
}
