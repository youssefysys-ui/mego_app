import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';


/// Small text widget with customizable color
class CustomTextSmall extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomTextSmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color ?? AppColors.txtColor,
        fontFamily: 'fs_albert',
      ),
    );
  }
}

/// Medium text widget with customizable color
class CustomTextMedium extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const CustomTextMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: color ??AppColors. txtColor,
        fontFamily: 'fs_albert',
        fontWeight: fontWeight,
      ),
    );
  }
}

/// Large text widget with customizable color
class CustomTextLarge extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const CustomTextLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
      //Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: color ?? AppColors.txtColor,
        fontSize: 21,
        fontFamily: 'fs_albert',
        fontWeight: fontWeight,
      ),
    );
  }
}

/*
// Basic usage with default txtColor
CustomTextSmall('Small text')
CustomTextMedium('Medium text')  
CustomTextLarge('Large text')

// With custom colors
CustomTextSmall('Error message', color: Colors.red)
CustomTextMedium('Success message', color: Colors.green)
CustomTextLarge('Title', color: primaryColor, fontWeight: FontWeight.bold)

// With additional properties
CustomTextMedium(
  'Long text that might overflow...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  textAlign: TextAlign.center,
)
*/