import 'package:flutter/material.dart';

/// Centralized lightweight feedback utility for the app.
///
/// Usage:
/// AppFeedback.show(context, message: 'Saved', type: FeedbackType.success);
enum FeedbackType { success, info, warning, error, loading }

class AppFeedback {
  AppFeedback._();

  /// Show a single feedback message. New messages replace any existing one.
  ///
  /// - [replace]: when true (default) the current feedback is removed before
  ///   showing the new one so messages never stack.
  /// - [blocking]: when true shows a modal blocking indicator (rare). By
  ///   default feedback is non-blocking.
  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
    bool replace = true,
    bool blocking = false,
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    if (replace) {
      messenger.hideCurrentSnackBar();
    }

    // Loading uses an effectively indefinite duration; others use short ones.
    final duration = switch (type) {
      FeedbackType.success => const Duration(milliseconds: 2100),
      FeedbackType.info => const Duration(milliseconds: 2100),
      FeedbackType.warning => const Duration(milliseconds: 2400),
      FeedbackType.error => const Duration(milliseconds: 3500),
      FeedbackType.loading => const Duration(days: 1),
    };

    // Select a gentle color/icon per type. Keep visuals subtle.
    final color = switch (type) {
      FeedbackType.success => Colors.green.shade700,
      FeedbackType.info => Colors.blueGrey.shade800,
      FeedbackType.warning => Colors.orange.shade800,
      FeedbackType.error => Colors.red.shade700,
      FeedbackType.loading => Colors.blueGrey.shade800,
    };

    final icon = switch (type) {
      FeedbackType.success => const Icon(Icons.check_circle_outline, color: Colors.white),
      FeedbackType.info => const Icon(Icons.info_outline, color: Colors.white),
      FeedbackType.warning => const Icon(Icons.warning_amber_outlined, color: Colors.white),
      FeedbackType.error => const Icon(Icons.error_outline, color: Colors.white),
      FeedbackType.loading => const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
    };

    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      backgroundColor: color,
      content: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (blocking) {
      // For blocking requests show a modal dialog with same text. This is
      // opt-in and used sparingly. We still keep a SnackBar for replacement
      // semantics; the dialog is displayed above it.
      messenger.showSnackBar(snack);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Row(children: [
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ]),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(snack);
    }
  }

  /// Convenience helper to show a success feedback.
  ///
  /// This wraps [show] with the success type and preserves replace/blocking
  /// semantics. Use this across the app to present positive feedback.
  static void success(
    BuildContext context,
    String message, {
    bool replace = true,
    bool blocking = false,
  }) {
    show(
      context,
      message: message,
      type: FeedbackType.success,
      replace: replace,
      blocking: blocking,
    );
  }

  /// Convenience to clear any current feedback immediately.
  static void clear(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
