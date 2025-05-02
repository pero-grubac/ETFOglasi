import 'package:etf_oglasi/core/constants/strings.dart';
import 'package:flutter/material.dart';

import 'package:etf_oglasi/core/ui/theme/drawer_header_theme.dart';

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
                  Icons.settings,
                  size: 48,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(
                  width: 18,
                ),
                const Text(GeneralStrings.settings),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.format_paint,
              size: 26,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Tema'),
            onTap: () {},
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
          ListTile(
            leading: Icon(
              Icons.language,
              size: 26,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Jezik'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
