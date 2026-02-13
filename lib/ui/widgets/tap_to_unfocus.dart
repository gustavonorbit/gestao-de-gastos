import 'package:flutter/material.dart';

/// Shared TapToUnfocus widget used across screens to unfocus inputs when
/// tapping on the screen body. Kept intentionally small and local to
/// UI widgets so it can be safely rolled back if needed.
class TapToUnfocus extends StatelessWidget {
  final Widget child;

  const TapToUnfocus({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final scope = FocusScope.of(context);
        if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
          scope.unfocus();
        }
      },
      child: child,
    );
  }
}
