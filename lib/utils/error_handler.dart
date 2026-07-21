import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorHandler {
  static void showErrorModal(BuildContext context, {String title = 'Ops! Algo deu errado.', required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: AppTheme.textColorSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }
}
