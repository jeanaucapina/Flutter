import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_role.dart';
import 'screens/map_screen.dart';
import 'screens/role_selection_screen.dart';
import 'services/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          home: const _RoleGate(),
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}

class _RoleGate extends StatefulWidget {
  const _RoleGate();

  @override
  State<_RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<_RoleGate> {
  static const String _roleKey = 'selected_app_role';

  AppRole? _selectedRole;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadSavedRole();
  }

  Future<void> _loadSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_roleKey);

      if (!mounted) return;
      setState(() {
        _selectedRole = saved == 'student'
            ? AppRole.student
            : saved == 'visitor'
                ? AppRole.visitor
                : null;
        _loadingRole = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingRole = false;
      });
    }
  }

  Future<void> _setRole(AppRole role) async {
    setState(() {
      _selectedRole = role;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _roleKey,
        role == AppRole.student ? 'student' : 'visitor',
      );
    } catch (_) {
      // Ignore persistence failures and keep in-memory role.
    }
  }

  Future<void> _resetRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_roleKey);
    } catch (_) {
      // Ignore persistence failures and reset in memory.
    }

    if (!mounted) return;
    setState(() {
      _selectedRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_selectedRole == null) {
      return RoleSelectionScreen(
        onRoleSelected: _setRole,
      );
    }

    return MapScreen(
      role: _selectedRole!,
      onChangeRole: _resetRole,
    );
  }
}
