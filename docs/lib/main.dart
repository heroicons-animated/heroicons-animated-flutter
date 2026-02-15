import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/animated_icons_demo.dart';

void main() {
  runApp(const HeroiconsAnimatedDemoApp());
}

class HeroiconsAnimatedDemoApp extends StatefulWidget {
  const HeroiconsAnimatedDemoApp({super.key});

  @override
  State<HeroiconsAnimatedDemoApp> createState() =>
      _HeroiconsAnimatedDemoAppState();
}

class _HeroiconsAnimatedDemoAppState extends State<HeroiconsAnimatedDemoApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'heroicons-animated | animated heroicons for Flutter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
      ),
      home: AnimatedIconsDemo(
        themeMode: _themeMode,
        onToggleThemeMode: _toggleThemeMode,
      ),
    );
  }
}
