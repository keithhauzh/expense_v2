import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/dialog/add_category_dialog.dart';
import 'package:expense_v2/ui/dialog/add_existing_expense_to_category_dialog.dart';
import 'package:expense_v2/ui/dialog/add_expense_dialog.dart';
import 'package:expense_v2/ui/dialog/add_group_dialog.dart';
import 'package:expense_v2/ui/dialog/logout_confirmation_dialog.dart';
import 'package:expense_v2/ui/pages/dashboard.dart';
import 'package:expense_v2/ui/pages/expenses_screen.dart';
import 'package:expense_v2/ui/pages/groups_screen.dart';
import 'package:expense_v2/ui/pages/login_screen.dart';
import 'package:expense_v2/ui/pages/signup_screen.dart';
import 'package:expense_v2/ui/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  final userRepo = UserRepoFireImpl();

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
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) =>
              const MaterialPage(child: SplashScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) =>
              const MaterialPage(child: SignupScreen()),
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            final location = state.matchedLocation;
            if (location == '/dashboard') {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Dashboard'),
                  actions: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => LogoutConfirmation(),
                        );
                      },
                      icon: Icon(Icons.exit_to_app),
                    ),
                  ],
                ),
                body: DashboardScreen(),
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
                  floatingActionButton: Builder(
                    // Using Builder here gives us a BuildContext located at the
                    // Builder's place in the widget tree, so that it can see the inherited
                    // widgets above it, (in this case, DefaultTabController) that a previously
                    // captured context couldn't.
                    builder: (innerContext) => FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        final currentIndex = DefaultTabController.of(
                          innerContext,
                        ).index;
                        switch (currentIndex) {
                          case 0:
                            showModalBottomSheet(
                              context: innerContext,
                              builder: (bottomSheetContext) {
                                return Padding(
                                  padding: const EdgeInsetsGeometry.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(bottomSheetContext);
                                          showDialog(
                                            context: innerContext,
                                            builder: (_) => AddExpenseDialog(),
                                          );
                                        },
                                        child: Text("Add Expense"),
                                      ),
                                      SizedBox(height: 8),
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(bottomSheetContext);
                                          showDialog(
                                            context: innerContext,
                                            builder: (_) => AddCategoryDialog(),
                                          );
                                        },
                                        child: Text("Add Category"),
                                      ),
                                      SizedBox(height: 8),
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(bottomSheetContext);
                                          showDialog(
                                            context: innerContext,
                                            builder: (_) =>
                                                AddExistingExpenseToCategoryDialog(),
                                          );
                                        },
                                        child: Text(
                                          "Add an existing expense to a category",
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            break;
                          case 1:
                            showDialog(
                              context: innerContext,
                              builder: (_) => AddGroupDialog(),
                            );
                            break;
                        }
                      },
                    ),
                  ),
                  appBar: AppBar(
                    title: Text('Expenses'),
                    actions: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => LogoutConfirmation(),
                          );
                        },
                        icon: Icon(Icons.exit_to_app),
                      ),
                    ],
                    bottom: TabBar(
                      tabs: <Widget>[
                        Tab(text: 'Expenses', icon: Icon(Icons.money)),
                        Tab(text: 'Groups', icon: Icon(Icons.group)),
                      ],
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
