import 'package:flutter/material.dart';
import 'color_utils.dart';

Container roundButton({
  required VoidCallback onClick,
  String? text,
  Color? textColor,
  double textFontSize = 20,
  Color? color,
  Color? splashColor,
  // double minWidth = 150,
  double height = 100,
  double leadingIconMargin = 0,
  Widget? leadingIcon,
}) {
  return Container(
    height: height,
    child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((_) {
            return Colors.white;
          }),
          shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20));
          }),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // This is must when you are using Row widget inside Raised Button
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildLeadingIcon(leadingIcon, leadingIconMargin),
            Text(
              text ?? '',
              style: TextStyle(
                color: Colors.black,
                fontSize: textFontSize,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        onPressed: () {
          return onClick();
        }),
  );
}

Widget _buildLeadingIcon(Widget? leadingIcon, double leadingIconMargin) {
  if (leadingIcon != null) {
    return Row(
      children: <Widget>[leadingIcon, SizedBox(width: leadingIconMargin)],
    );
  }
  return Container();
}
