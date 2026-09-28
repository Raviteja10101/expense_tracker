import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const AppDrawer({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [

          const DrawerHeader(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Expense Tracker',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading:
                const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName:
                    'Expense Tracker',
                applicationVersion: '1.0',
              );
            },
          ),

          SwitchListTile(
            secondary:
                const Icon(Icons.dark_mode),
            title: const Text('Dark Theme'),
            value: darkMode,
            onChanged: onThemeChanged,
          ),

          ListTile(
            leading:
                const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),

          ListTile(
            leading:
                const Icon(Icons.privacy_tip),
            title:
                const Text('Privacy Policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}