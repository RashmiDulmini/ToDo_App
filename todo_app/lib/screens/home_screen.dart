import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'starred_screen.dart';
import 'new_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StarredScreen(),
    TaskListScreen(),
    NewListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tasks',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          // 👇 This is now the TOP navigation
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.star), label: 'Starred'),
              NavigationDestination(icon: Icon(Icons.list), label: 'My Tasks'),
              NavigationDestination(icon: Icon(Icons.add), label: 'New List'),
            ],
          ),
          // 👇 Expanded content area
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
    );
  }
}
