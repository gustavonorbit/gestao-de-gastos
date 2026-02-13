import 'package:flutter/widgets.dart';

class UnfocusOnRouteChangeObserver extends NavigatorObserver {
  void _unfocusSafely() {
    // Run unfocus across multiple frames to ensure the route transition has
    // fully completed and any transient focus scopes created by the new
    // route are also cleared. We limit the attempts to avoid spinning.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusManager.instance.primaryFocus?.unfocus();
        });
      });
    });
  }

  bool _isPopup(Route<dynamic>? route) {
    return route is PopupRoute;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Só desfoca quando a navegação REALMENTE mudou
    // Ignora dialogs/bottom sheets
    if (_isPopup(route)) return;
    if (_isPopup(previousRoute)) return;

    _unfocusSafely();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (_isPopup(newRoute)) return;
    if (_isPopup(oldRoute)) return;
    _unfocusSafely();
  }

  // IMPORTANTE:
  // NÃO usar didPush aqui para evitar quebrar autofocus
  // em telas recém-abertas ou dialogs

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Only unfocus when there's a real previous route (i.e. not the very first
    // push) and the route change is not a popup/dialog. This avoids
    // interfering with dialogs which are PopupRoute.
    if (previousRoute == null) return;
    if (_isPopup(route)) return;
    if (_isPopup(previousRoute)) return;

    _unfocusSafely();
  }
}
