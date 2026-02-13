import 'package:flutter/material.dart';

/// A standardized bottom action area that:
/// - Respects SafeArea (bottom)
/// - Reserves a fixed ad area above the button (48px)
/// - Adds extra bottom padding: MediaQuery.padding.bottom + [extraSpace]
/// - Provides horizontal padding by default
///
/// Usage: place this widget in `Scaffold.bottomNavigationBar` passing the
/// full-width button (or row of buttons) as [child].
class BottomActionArea extends StatelessWidget {
  final Widget child;
  final double extraSpace;
  final double adHeight;
  final double horizontalPadding;

  const BottomActionArea({
    Key? key,
    required this.child,
    this.extraSpace = 16.0,
    this.adHeight = 48.0,
    this.horizontalPadding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reserved ad area (empty for now).
          SizedBox(height: adHeight, child: Container()),

          // The action button with horizontal + computed bottom padding.
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              bottomInset + extraSpace,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
