import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final Color? backgroundColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 80.0,
    this.backgroundColor,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationAnimation,
              child: Image.asset(
                AppImages.loading,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                style: TextStyle(
                  color: AppColors.txtColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: LoadingWidget(
          message: message,
          backgroundColor: Colors.transparent,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

/// Simple loading widget for inline use
class SimpleLoading extends StatelessWidget {
  final double size;
  final String? message;

  const SimpleLoading({
    super.key,
    this.size = 50.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      size: size,
      message: message,
    );
  }
}
