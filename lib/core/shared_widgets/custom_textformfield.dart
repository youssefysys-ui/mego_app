import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String hint;
  final String prefixIcon; // path to asset icon
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType type;
  final TextEditingController controller;

  const CustomTextFormField({
    Key? key,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.isPassword = false,
    this.type = TextInputType.text,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffE5E3DE),
        //Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.type,
        validator: widget.validator,
        textAlign: TextAlign.start,          // left-aligned text
        textDirection: TextDirection.ltr,    // force LTR layout (English default)
        style:  TextStyle(
          color: AppColors.txtColor,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          // Prefix icon (always on the left)
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child:SvgPicture.asset(
              widget.prefixIcon,
              width: 18,
              height: 19,
            //  color: AppColors.primaryColor,
            ),
          ),
          // Password visibility toggle (always on the right)
          suffixIcon: widget.isPassword
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}