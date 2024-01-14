import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:story_app_preferences/page/home_page.dart';
import 'package:story_app_preferences/provider/story_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StoryProvider(),
        )
      ],
      child: GetMaterialApp(
        home: const HomePage(),
        theme: ThemeData.light(useMaterial3: true),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
