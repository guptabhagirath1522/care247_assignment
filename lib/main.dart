import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/customer_search_screen.dart';
import 'state/customer_search_state.dart';
import 'state/theme_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const Care247App());
}

class Care247App extends StatelessWidget {
  const Care247App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeState()),
        ChangeNotifierProvider(create: (_) => CustomerSearchState()),
      ],
      child: Consumer<ThemeState>(
        builder: (context, themeState, _) {
          return MaterialApp(
            title: 'Care247 Customer Search',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const CustomerSearchScreen(),
          );
        },
      ),
    );
  }
}
