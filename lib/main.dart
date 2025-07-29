import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/screens/quiz_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;

String hostname = html.window.location.hostname ?? 'localhost'; // e.g. 'localhost'
String port = html.window.location.port ?? '57999'; // e.g. '57999'

void main(){
  runApp(
    QuizHostApp()
  );
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state)=>HomeScreen()
    ),
    GoRoute(
      path: '/quiz/:quizId',
      builder: (context, state){
        final quizId = state.pathParameters['quizId'];
        final token = state.uri.queryParameters['token'];
        if (quizId==null || dummyQuizzes.firstWhere((quiz) => quiz.quizId == quizId)==null || token == null){
          return Scaffold(
            body: Center(child: Text('Quiz not found')),
          );
        }
        return QuizScreen(quizId: quizId!, token: token!);
      },
    )
  ],
  errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text(state.error.toString())),
      ),
);

class QuizHostApp extends StatelessWidget{
  const QuizHostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
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
        // home: const HomeScreen()
      ),
    );
  }
}
