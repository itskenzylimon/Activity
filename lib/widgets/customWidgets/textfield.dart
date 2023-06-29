import 'package:flutter/material.dart';

///[FocusColor] is the outline borderline color when textfield is tapped
enum FocusColor { primary, secondary }

///[FocusErrorColor] is the outline borderline color that shows error 
enum FocusErrorColor { primary, secondary }

Widget textFieldWidget({
  Key? key,

  ///[hint]..is the hinttext of the textfield
  String? hint,

  ///[FocusColor] is the outline borderline color when textfield is tapped 
  Color? focusColor,

  ///[FocusErrorColor] is the outline borderline color that shows error 
  FocusErrorColor? focusErrorColor,

  ///[showprefix] sets either to show or not show end widget in the textfield 
  bool showprefix = false,

  ///[showsuffix] sets either to show or not show leading widget in the textfield 
  bool showsuffix = false,

  ///[suffixWidget] this is the leading widget in the textfield
  bool suffixWidget = false,

   ///[prefixWidget] this is the end widget in the textfield
  bool prefixWidget = false,

  ///[icon] this is textfield icon
  IconData? icon,

  ///[iconprefix]end icon of the textfield
  IconData? iconprefix,

  ///[prefixContainer] end container of the textfield that you can add any widget
  Container? prefixContainer,

  ///[suffixContainer] leading container of the textfield that you can add any widget
  Container? suffixContainer,

  ///[title]this is the text on top of the textfield that shows wat data is to typed in the textfield..i.e password ,email
  String? title,

  ///[helpertext] this the text on the bottom of the textfield to help you know wat is needed on the textfield
  String? helpertext,

  ///[textColor] the color of the texts in the textfield
  Color? textColor,

  ///[helpertextColor] the color of helper text
  Color? helpertextColor,

  ///[showhelpertext]sets either to show or not show helpertext
  bool showhelpertext = false,

  ///[showtitle]sets either to show or not show showtitle
  bool showtitle = false,

  ///[isreadonly]sets the textfield to be read only 
  bool isreadonly = false,

  ///[radius] is the corner radius of the textfield.
  double? radius,

  ///[onTap]call back function
  final void Function()? onTap,

  ///callback function
  final void Function(String value)? onChanged,

  ///[controller] this is the controller of the textfield
  TextEditingController? controller,
}) {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     showtitle? Text(
        title?? '',
        style: TextStyle(
            color: textColor?? Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
      ): const SizedBox(),
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        controller: controller,
        onChanged: (value) {
          onChanged!(value);
        },
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
            borderSide: const BorderSide(width: 1, color: Colors.redAccent),
            borderRadius: BorderRadius.all(Radius.circular(radius?? 8)),
          ),
          focusedErrorBorder:  OutlineInputBorder(
            borderSide: const BorderSide(width: 1, color: Colors.redAccent),
            borderRadius: BorderRadius.all(Radius.circular(radius?? 8)),
          ),
          // errorText: 'This is an error text',
          // helperText: 'this is helper text',
          errorStyle: const TextStyle(
            color: Colors.redAccent
          )
        ),
      ),
      const SizedBox(
        height: 5,
      ),
     showhelpertext? Text(
        helpertext?? '',
        style: TextStyle(
            color: helpertextColor?? Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
      ): const SizedBox()
    ],
  );
}
