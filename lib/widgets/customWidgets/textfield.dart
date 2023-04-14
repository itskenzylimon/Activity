import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

enum FocusColor { primary, secondary }

enum FocusErrorColor { primary, secondary }

Widget TextFieldWidget({
  String? hint,
  Color? focusColor,
  FocusErrorColor? focusErrorColor,
  bool showprefix = false,
  bool showsuffix = false,
  bool suffixWidget = false,
  bool prefixWidget = false,
  IconData? icon,
  IconData? iconprefix,
  Container? prefixContainer,
  Container? suffixContainer,
  String? title,
  String? helpertext,
  Color? textColor,
  Color? helpertextColor,
  bool showhelpertext = false,
  bool showtitle = false,
  bool isreadonly = false,
  double? radius,
  final void Function()? onTap,
  final void Function()? onChanged,
}) {
  final focus = focusColor == FocusColor.primary
      ? const Color.fromARGB(255, 68, 103, 163)
      : const Color.fromARGB(255, 108, 183, 245);
  final focusError = focusErrorColor == FocusErrorColor.primary
      ? Color.fromARGB(255, 212, 47, 18)
      : Color.fromARGB(255, 250, 87, 66);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     showtitle? Text(
        title?? '',
        style: TextStyle(
            color: textColor?? Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
      ): SizedBox(),
      SizedBox(
        height: 10,
      ),
      TextFormField(
        onTap: onTap,
        
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        keyboardType: TextInputType.name,
        readOnly: isreadonly,
        decoration: InputDecoration(
          
          contentPadding:
              const EdgeInsets.only(top: 7, bottom: 7, left: 14, right: 14),
          hintText: hint?? '',

          suffixIcon: suffixWidget ? prefixContainer : null,
          prefixIcon: prefixWidget ? suffixContainer : null,
          hintStyle: const TextStyle(
              color: Color(0xff667085),
              fontWeight: FontWeight.w400,
              fontSize: 14),
          fillColor: Colors.grey,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
            borderRadius:  BorderRadius.all(Radius.circular(radius?? 7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: focusColor?? Colors.grey),
            borderRadius:  BorderRadius.all(Radius.circular(radius?? 8)),
          ),
          errorBorder:  OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.redAccent),
            borderRadius: BorderRadius.all(Radius.circular(radius?? 8)),
          ),
          focusedErrorBorder:  OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.redAccent),
            borderRadius: BorderRadius.all(Radius.circular(radius?? 8)),
          ),
          // errorText: 'This is an error text',
          // helperText: 'this is helper text',
          errorStyle: TextStyle(
            color: Colors.redAccent
          )
        ),
      ),
      SizedBox(
        height: 5,
      ),
     showhelpertext? Text(
        helpertext?? '',
        style: TextStyle(
            color: helpertextColor?? Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
      ): SizedBox()
    ],
  );
}
