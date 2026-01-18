import 'package:expense_v2/ui/pages/dashboard.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  static const initial = "/dashboard";
  static final routes = [
    GoRoute(path: "/dashboard",
      name: Screen.dashboard.name,
      builder: (context,state) => const DashboardScreen()
    )
  ];
}

enum Screen {dashboard}
