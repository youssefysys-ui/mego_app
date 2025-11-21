import 'package:flutter/material.dart';

/// Shows a success message using a floating snackbar
appMessageSuccess({required String text, required BuildContext context}) {
  _showFloatingSnackBar(
    context: context,
    message: text,
    backgroundColor: Colors.green.shade600,
    icon: Icons.check_circle_outline,
  );
}

/// Shows an error message using a floating snackbar
appMessageFail({required String text, required BuildContext context}) {
  _showFloatingSnackBar(
    context: context,
    message: text,
    backgroundColor: Colors.red.shade600,
    icon: Icons.error_outline,
  );
}

/// Custom floating snackbar implementation using ScaffoldMessenger
void _showFloatingSnackBar({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
  required IconData icon,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: const Duration(seconds: 2),
    margin: const EdgeInsets.only(
      bottom: 50,
      left: 16,
      right: 16,
    ),
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


