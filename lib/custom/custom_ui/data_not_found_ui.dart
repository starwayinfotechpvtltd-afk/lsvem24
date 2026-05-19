import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/string/app_string.dart';

class DataNotFoundUi extends StatelessWidget {
  const DataNotFoundUi({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppIcons.isEmpty, width: 250),
          const SizedBox(height: 30),
          Text(
            title ?? AppStrings.dataNotFound.tr,
            style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}
