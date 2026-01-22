import 'package:dailycalc/ui/spreadsheet/sheet_screen.dart';
import 'package:flutter/material.dart';

import 'settings/settings_screen.dart';
import 'cards/card_screen.dart';
import 'calculator/calculator_screen.dart';
import 'home/home_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    CalculatorScreen(),
    HomeScreen(),
    SheetScreen(),
    CardScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate), label: "Calculator", backgroundColor: Theme.of(context).primaryColorDark),
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home", backgroundColor: Theme.of(context).primaryColorDark),
          BottomNavigationBarItem(
              icon: Icon(Icons.book), label: "Sheets", backgroundColor: Theme.of(context).primaryColorDark),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: "Cards", backgroundColor: Theme.of(context).primaryColorDark),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings", backgroundColor: Theme.of(context).primaryColorDark),
        ],
        backgroundColor: Theme.of(context).primaryColorDark,
        selectedItemColor: Theme.of(context).primaryColorLight,
      ),
    );
  }
}
