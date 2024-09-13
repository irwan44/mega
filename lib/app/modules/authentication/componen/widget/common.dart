import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Common {
  Color maincolor = const Color(0xFF35C2C1);
  Color white = const Color(0xFFF5F5F5);
  Color black = const Color(0xFF2B407D);

  TextStyle titelTheme =  GoogleFonts.nunito(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.orange);
  TextStyle mediumTheme = GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 72, 151, 151));
  TextStyle mediumThemeblack = GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      color: Colors.grey);
  TextStyle semiboldwhite = GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.white);
  TextStyle semiboldblue = GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.orange);
  TextStyle semiboldblack = GoogleFonts.nunito(
      fontSize: 15, color: Colors.grey);
  TextStyle hinttext = GoogleFonts.nunito(
      fontSize: 15, color: Color(0xFF8391A1));
}
