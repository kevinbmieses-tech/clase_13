import 'package:flutter/material.dart';

import '../../../../general/utils/responsive.dart';

class CustomRedBtn extends StatelessWidget {
  final String textt;
  final Color textColor;
  final Color fillColor;
  final Color? borderClr;
  const CustomRedBtn({
    super.key,
    required this.textt,
    required this.textColor,
    required this.fillColor,
    this.borderClr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: twentyPixelHeight(context) * .85,
        bottom: twentyPixelHeight(context) * .85,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderClr ?? textColor),
      ),
      child: Center(
        child: Text(
          textt,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
            fontFamily: "Poppins",
          ),
          textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
        ),
      ),
    );
  }
}
