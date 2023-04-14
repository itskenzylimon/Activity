import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

enum BtnSizeHeight { sm, lg }

enum BtnSizeWidth { sm, lg }

enum BtnColor { primary, secondary }

enum BtnRadius { sm, lg }

Widget ButtonWidget(
    {
      String? text,
      BtnSizeHeight btnSizeHeight = BtnSizeHeight.lg,
    BtnSizeWidth? btnSizeWidth,
    Color? btnColor,
    Color? OutlineColor,
    Color? shadowColor,
    Color? hoverColor,
    Color? textColor,
    IconData? icon,
    IconData? endicon,
    Color? btnhoverColor,
    BtnRadius? btnRadius,
    Color? btnDisabledColor,
    double? radius,
    bool isIconOnly = false,
    bool showicon = false,
    bool showEndicon = false,
     final void Function()? onTap,
    }) {
  double height = btnSizeHeight == BtnSizeHeight.sm ? 45 : 65;
  double width = btnSizeWidth == BtnSizeWidth.sm ? 160 : 250;
 
  double iconBtnwidth = btnSizeWidth == BtnSizeWidth.sm ? 45 : 60;
  double iconBtnheight = btnSizeHeight == BtnSizeHeight.sm ? 45 : 55;

  late bool isHovered = false;
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
                color: isHovered ? hoverColor : btnColor?? Colors.white,
                borderRadius: BorderRadius.circular(radius!)),
                child: Center(
                  child: Icon(icon,size: 30,),
                ),
          ),
      )
      : InkWell(
        onTap: onTap,
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
                      color: btnColor?? Colors.white,
                     
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
                        color: OutlineColor?? Colors.white,
                        width: 0.9
                      ),
                       boxShadow: [
                        BoxShadow(
                          color: shadowColor?? Colors.white,
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(1, 1), // changes position of shadow
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
                                 child: Container(
                                  
                                  child: Icon(icon,size: 30,)),
                               ): SizedBox(),
                          Text(
                            text!,
                            style:  TextStyle(
                                fontSize: 16,
                                color: textColor?? Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          showEndicon ?Padding(
                                 padding: const EdgeInsets.only(left: 20,right: 0),
                                 child: Container(
                                  
                                  child: Icon(endicon,size: 30,)),
                               ): SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
        );
}
