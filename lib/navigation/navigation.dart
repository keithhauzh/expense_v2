import 'package:expense_v2/ui/pages/add_existing_expenses_to_category_screen.dart';
import 'package:expense_v2/ui/pages/categories_screen.dart';
import 'package:expense_v2/ui/pages/dashboard.dart';
import 'package:expense_v2/ui/pages/groups_screen.dart';
import 'package:expense_v2/ui/pages/personal_expenses_screen.dart';
import 'package:expense_v2/ui/pages/view_category_screen.dart';
import 'package:expense_v2/ui/pages/view_group_screen.dart';
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
            return Scaffold(
              body: child,
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
                    label: 'Personal Expenses',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group),
                    label: 'Groups',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: 'Categories',
                  ),
                ],
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: DashboardScreen()),
            ),
            GoRoute(
              path: '/personal_expenses',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: PersonalExpensesScreen()),
            ),
            GoRoute(
              path: '/groups',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: GroupsScreen()),
              routes: [
                GoRoute(
                  path: ':groupId',
                  pageBuilder: (context, state) {
                    if (state.pathParameters['groupId'] != null) {
                      final groupId = state.pathParameters['groupId']!;
                      return MaterialPage(
                        child: ViewGroupScreen(groupId: groupId),
                      );
                    } else {
                      return MaterialPage(child: GroupsScreen());
                    }
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/categories',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: CategoriesScreen()),
              routes: [
                GoRoute(
                  path: ':categoryId',
                  pageBuilder: (context, state) {
                    if (state.pathParameters['categoryId'] != null) {
                      final categoryId = state.pathParameters['categoryId']!;
                      return MaterialPage(
                        child: ViewCategoryScreen(categoryId: categoryId),
                      );
                    } else {
                      return MaterialPage(child: CategoriesScreen());
                    }
                  },
                  routes: [
                    GoRoute(
                      path: 'add_expenses',
                      pageBuilder: (context, state) {
                        if (state.pathParameters['categoryId'] != null) {
                          final categoryId =
                              state.pathParameters['categoryId']!;
                          return MaterialPage(
                            child: AddExistingExpensesToCategoryScreen(categoryId: categoryId),
                          );
                        } else {
                          return MaterialPage(child: CategoriesScreen());
                        }
                      },
                    ),
                  ],
                ),
              ],
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
      case '/personal_expenses':
        return 1;
      case '/groups':
        return 2;
      case '/categories':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/personal_expenses');
      case 2:
        context.go('/groups');
      case 3:
        context.go('/categories');
        break;
    }
  }
}
