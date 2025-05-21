import 'package:etf_oglasi/core/constants/strings.dart';
import 'package:etf_oglasi/core/ui/theme/drawer_header_theme.dart';
import 'package:flutter/material.dart';

import '../screen/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawerHeaderTheme = theme.extension<DrawerHeaderTheme>();
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: drawerHeaderTheme?.drawerHeaderDecoration,
            child: Row(
              children: [
                Icon(
                  Icons.school,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(
                  width: 18,
                ),
                Text(
                  GeneralStrings.appTitle,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 26,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Podešavanja'),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.id);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.notification_add,
              size: 26,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Obavjestenja'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.schedule,
              size: 26,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Raspored'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
