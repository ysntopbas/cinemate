import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'package:provider/provider.dart';
import 'providers/watch_list_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await dotenv.load(fileName: ".env");
    runApp(const MyApp());
  } catch (e) {
    print("Hata: $e");
    // Hata durumunda uygulamayı yine de başlat
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WatchListProvider(),
      child: MaterialApp(
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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasData) {
              return const HomePage();
            }
            
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
