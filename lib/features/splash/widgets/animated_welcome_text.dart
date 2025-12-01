import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/res/app_colors.dart';

class AnimatedWelcomeText extends StatefulWidget {
  final Duration duration;
  final TextStyle? textStyle;
  final double starSize;

  const AnimatedWelcomeText({
    Key? key,
    this.duration = const Duration(milliseconds: 1500),
    this.textStyle,
    this.starSize = 28,
  }) : super(key: key);

  @override
  State<AnimatedWelcomeText> createState() => _AnimatedWelcomeTextState();
}

class _AnimatedWelcomeTextState extends State<AnimatedWelcomeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.elasticOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _effectiveTextStyle(BuildContext context) {
    return widget.textStyle ??
        TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
          color: AppColors.primaryColor,
          letterSpacing: 1.1,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Welc', style: _effectiveTextStyle(context)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SvgPicture.asset(
                  AppImages.star2,
                  height: widget.starSize,
                  width: widget.starSize,
                ),
              ),
              Text('me', style: _effectiveTextStyle(context)),
            ],
          ),
        ),
      ),
    );
  }
}
