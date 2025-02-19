import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film ve Dizi Önerileri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 24, color: const Color.fromRGBO(251, 192, 45, 1)),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: const Color.fromRGBO(251, 192, 45, 1)),
        ),
        colorScheme: ColorScheme.light(
          primary: Color.fromRGBO(66, 66, 66, 1),
          onPrimary: Color.fromRGBO(251, 192, 45, 1),
          surface: Color.fromRGBO(33, 33, 33, 1),
          onSurface: Color.fromRGBO(251, 192, 45, 1),
          secondary: Color.fromRGBO(251, 192, 45, 1),
          outline: Color.fromRGBO(251, 192, 45, 1),
          error: Colors.deepPurpleAccent,
        )
      ),
      home: const LoginPage(),
    );
  }
}
