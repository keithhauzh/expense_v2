import 'package:expense_v2/ui/pages/dashboard.dart';
import 'package:expense_v2/ui/pages/expenses_screen.dart';
import 'package:expense_v2/ui/pages/groups_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  final GlobalKey<NavigatorState> rootNavigatorKey;
  final GlobalKey<NavigatorState> shellNavigatorKey;
  late final GoRouter router;

  Navigation()
    : rootNavigatorKey = GlobalKey<NavigatorState>(),
      shellNavigatorKey = GlobalKey<NavigatorState>() {
    router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            final location = state.matchedLocation;
            if (location == '/dashboard') {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    location == '/dashboard' ? 'Dashboard' : 'Expenses',
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.grey,
                  currentIndex: _calculateIndex(location),
                  onTap: (index) => _onItemTapped(index, context),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Expenses',
                    ),
                  ],
                ),
              );
            } else {
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  body: TabBarView(
                    children: <Widget>[ExpensesScreen(), GroupsScreen()],
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: FloatingActionButton.extended(
                    label: Text("Add Expense"),
                    icon: Icon(Icons.add),
                    onPressed: () => {
                      // TODO: check which tab it is on and
                      // show appropriate dialog
                      debugPrint("floating action button navigation"),
                    },
                  ),
                  appBar: AppBar(
                    title: Text(
                      location == '/dashboard' ? 'Dashboard' : 'Expenses',
                    ),
                    bottom: TabBar(
                      tabs: <Widget>[
                        Tab(text: 'Expenses', icon: Icon(Icons.money)),
                        Tab(text: 'Groups', icon: Icon(Icons.group)),
                      ],
                    ),
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    backgroundColor: Colors.blue,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.blueGrey,
                    currentIndex: _calculateIndex(location),
                    onTap: (index) => _onItemTapped(index, context),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Expenses',
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: DashboardScreen()),
            ),
            GoRoute(
              path: '/expenses',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: ExpensesScreen()),
            ),
          ],
        ),
      ],
    );
  }

  int _calculateIndex(String location) {
    switch (location) {
      case '/dashboard':
        return 0;
      case '/expenses':
        return 1;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/expenses');
        break;
    }
  }
}
