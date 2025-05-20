import 'package:flutter/material.dart';
import 'package:habit_tracker/db/habit_database.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = HabitDatabase.instance;
  await db.ensureFirstStartTimeSaved();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitDatabase>.value(value: db),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
