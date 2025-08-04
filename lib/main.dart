import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_host/firebase_options.dart';
import 'package:quiz_host/auth-login/auth_screen.dart';
import 'home/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName:'.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    QuizHostApp()
  );
}


class QuizHostApp extends StatelessWidget{
  const QuizHostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: "Quiz Host",
        theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme().copyWith(
            titleLarge: TextStyle()
          ),
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: const Color(0xFFF37022), // Orange
            onPrimary: const Color(0xFFFFFFFF), // White text/icons on orange
            secondary: const Color(0xFF051951), // Blue
            onSecondary: const Color(0xFFFFFFFF), // White text/icons on blue
            error: Colors.red,
            onError: const Color(0xFFFFFFFF), // White text/icons on error
            surface: const Color(0xFFFFFFFF), // White for cards/sheets background
            onSurface: const Color(0xFF051951), // Blue text/icons on surface
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFF37022), // Orange
            foregroundColor: const Color(0xFFFFFFFF), // White text/icons in AppBar
            iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)), // White icons
          ),
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(), 
          builder: (ctx, snap){
            if(snap.hasData){
              return HomeScreen(hostId: snap.data!.uid);
            }
            return AuthScreen();
          }
        )
      ),
    );
  }
}
