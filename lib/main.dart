// UI api
import 'package:expense_v2/ui/pages/categories_screen.dart';
import 'package:expense_v2/ui/pages/dashboard.dart';
import 'package:expense_v2/ui/pages/groups_screen.dart';
import 'package:expense_v2/ui/pages/personal_expenses_screen.dart';
import 'package:flutter/material.dart';

// Foundation package that connects flutter app to firebase service
import 'package:firebase_core/firebase_core.dart';

// This imports the file that was auto generated
// after running flutterfire configure.
import 'package:expense_v2/firebase_options.dart';

// Navigation packages
import 'package:expense_v2/navigation/navigation.dart';
import 'package:go_router/go_router.dart';

// TODO: Splash Screen, Login screen, Sign up Screen

void main() async {
  // From my understanding, this line of code allows communication between
  // dart code and the different platforms of flutter engine to perform async operations.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExpenseV2());
}

class ExpenseV2 extends StatelessWidget {
  const ExpenseV2({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NavBar());
  }
}

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavbarState();
}

class _NavbarState extends State<NavBar> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    PersonalExpensesScreen(),
    GroupsScreen(),
    CateogoriesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      // changes the current selected index, this is to switch pages from the nav bar
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense V2')),

      // each of the pages are an index, from 0 to 3
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal Expenses',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Groups',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
            backgroundColor: Colors.green,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp.router(
    title: 'Expense V2',
    theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
    routerConfig: GoRouter(
      initialLocation: Navigation.initial,
      routes: Navigation.routes,
    ),
  );
}
