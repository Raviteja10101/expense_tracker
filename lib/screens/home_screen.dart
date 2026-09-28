import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'messages_screen.dart';
import 'home_dashboard_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final screens = const [
  MessagesScreen(),
  HomeDashboardScreen(),
  DashboardScreen(),
];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
  NavigationDestination(
    icon: Icon(Icons.message_outlined),
    selectedIcon: Icon(Icons.message),
    label: 'Messages',
  ),

  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),

  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: 'Dashboard',
  ),
],
      ),
    );
  }
}