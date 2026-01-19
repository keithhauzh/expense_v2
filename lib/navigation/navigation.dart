import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  static const String initial = '/dashboard';

  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static Widget _scaffoldWithNavBar(BuildContext context, Widget child){
    return Scaffold(
      appBar: AppBar(title:const Text('Expense V2')),
      body:child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex = _calculateCurrentIndex(context),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal Expenses'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category'
          ),
        ]
      ),
    );
  }

  // static in this case means that this funciton belongs to the class itself,
  // not to any instance of the class, you are able to use this without
  // instantantiating an instance of this class
  static int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).location;
    if(location.startsWith('/dashboard')) return 0;
    if(location.startsWith('/personal')) return 1;
    if(location.startsWith('/groups')) return 2;
    if(location.startsWith('/categories')) return 3;
    return 0;
  }

  static void _onItemTapped(int index, BuildContext context){
    switch(index){
      case 0: context.go('/dashboard');
      break;
      case 1: context.go('/personal-expenses');
      break;
      case 2: context.go('/groups');
      break;
      case 3: context.go('/categories');
      break;
    }
  }

  static final routes = [

  ];
}
