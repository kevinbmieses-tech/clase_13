import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/responsive.dart';

class FindDonorDatePicker extends StatefulWidget {
  const FindDonorDatePicker({super.key});

  @override
  State<FindDonorDatePicker> createState() => _FindDonorDatePickerState();
}

class _FindDonorDatePickerState extends State<FindDonorDatePicker> {
  String? date;

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate == null || !mounted) return;
    date = '${pickedDate.day}-${pickedDate.month}-${pickedDate.year}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            height: twentyPixelHeight(context) * 2,
            decoration: BoxDecoration(
              color: AppColor.textLight,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                horizontalSpace(twentyPixelWidth(context) * .5),
                Text(
                  date ?? "Choose Date",
                  style: const TextStyle(
                    color: AppColor.textAss,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                  textScaler: TextScaler.linear(
                    ScaleSize.textScaleFactor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        horizontalSpace(twentyPixelWidth(context)),
        InkWell(
          onTap: () {
            _pickDate(context);
          },
          child: Container(
            height: twentyPixelHeight(context) * 2,
            width: twentyPixelWidth(context) * 3,
            decoration: BoxDecoration(
              color: AppColor.redColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.calendar_month, color: AppColor.textLight),
          ),
        ),
      ],
    );
  }
}
