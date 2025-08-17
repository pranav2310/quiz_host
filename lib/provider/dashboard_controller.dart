import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_host/models/quiz.dart';
import 'package:quiz_host/models/session.dart';

final dashboardControllerProvider =
    StateNotifierProvider.family<DashboardController, DashboardState, String>(
      (ref, hostId) => DashboardController(ref, hostId),
    );

class DashboardState {
  final List<Quiz> quizList;
  final List<Session> sessionList;
  final bool loading;
  final String? error;

  DashboardState({
    this.quizList = const [],
    this.sessionList = const [],
    this.loading = false,
    this.error,
  });

  DashboardState copyWith({
    List<Quiz>? quizList,
    List<Session>? sessionList,
    bool? loading,
    String? error,
  }) {
    return DashboardState(
      quizList: quizList ?? this.quizList,
      sessionList: sessionList ?? this.sessionList,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final Ref ref;
  final String hostId;
  StreamSubscription? _sessionSub;
  StreamSubscription? _quizSub;
  DashboardController(this.ref, this.hostId) : super(DashboardState()) {
    _listenSessions();
    _listenQuizes();
  }

  void _listenQuizes() {
    _quizSub = FirebaseDatabase.instance
        .ref('quiz-list/$hostId')
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          final quizzes = <Quiz>[];
          if (data is Map) {
            data.forEach((k, v) {
              if(v is Map){
                quizzes.add(Quiz.fromMap(Map<String, dynamic>.from(v)));
              }
            });
          }
          quizzes.sort(
            (a, b) => (b.createdOn ?? DateTime(1970)).compareTo(
              a.createdOn ?? DateTime(1970),
            ),
          );
          state = state.copyWith(quizList: quizzes);
        });
  }

  void _listenSessions() {
    _sessionSub = FirebaseDatabase.instance
        .ref('session')
        .orderByChild('hostId')
        .equalTo(hostId)
        .onValue
        .listen((event) {
          final data = event.snapshot.value;
          final sessions = <Session>[];
          if (data is Map) {
            data.forEach(
              (k, val) {
                if(val is Map){
                  sessions.add(Session.fromJson(Map<String, dynamic>.from(val)));
                }
              },
            );
          }
          sessions.sort(
            (a, b) => (b.sessionCreatedAt ?? DateTime(1970)).compareTo(
              a.sessionCreatedAt ?? DateTime(1970),
            ),
          );
          state = state.copyWith(sessionList: sessions);
        });
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await FirebaseDatabase.instance.ref('quiz-list/$hostId/$quizId').remove();
      final sessionSnap = await FirebaseDatabase.instance
          .ref('session')
          .orderByChild('quizId')
          .equalTo(quizId)
          .get();
      if (sessionSnap.exists && sessionSnap.value is Map) {
        final sessionMap = Map<String, dynamic>.from(sessionSnap.value as Map);
        for (final entry in sessionMap.entries) {
          await FirebaseDatabase.instance.ref('session/${entry.key}').remove();
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String?> hostQuiz(Quiz quiz) async {
    try {
      final sessionRef = FirebaseDatabase.instance
          .ref('session')
          .orderByChild('hostId')
          .equalTo(hostId);
      final sessionSnap = await sessionRef.get();
      if (sessionSnap.exists) {
        final data = sessionSnap.value;
        if (data is Map) {
          final sessions = Map<String, dynamic>.from(data);
          String? existingSessionId;
          sessions.forEach((k, v) {
            if (v is Map) {
              final quizId = v['quizId']?.toString();
              final state = v['state']?.toString();
              if (quizId == quiz.quizId && state != 'ended') {
                existingSessionId = v['sessionId']?.toString();
              }
            }
          });
          if (existingSessionId != null) {
            return existingSessionId;
          }
        }
      }
      String sessionId;
      bool exists = true;
      do {
        sessionId = List.generate(
          6,
          (_) => '0123456789'[Random().nextInt(10)],
        ).join();
        final snap = await FirebaseDatabase.instance
            .ref('session/$sessionId')
            .get();
        exists = snap.exists;
      } while (exists);
      final newSessionRef = FirebaseDatabase.instance.ref('session/$sessionId');
      await newSessionRef.update({
        'sessionId': sessionId,
        'hostId': hostId,
        'quizId': quiz.quizId,
        'currentQuestion': 0,
        'state': 'waiting',
        'players': {},
        'sessionCreatedAt': ServerValue.timestamp,
      });
      return sessionId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> resetSession(String sessionId)async{
    final sessionRef = FirebaseDatabase.instance.ref(
      'session/$sessionId',
    );
    await sessionRef.update({
      'state': SessionState.waiting.name,
      'players': {},
      'currentQuestion': 0,
      'sessionCreatedAt': ServerValue.timestamp,
    });
  }

  Future<void> deleteSession(String sessionId)async{
    final sessionRef = FirebaseDatabase.instance.ref('session/$sessionId');
    await sessionRef.remove();
  }

  @override
  void dispose() {
    super.dispose();
    _sessionSub?.cancel();
    _quizSub?.cancel();
  }
}
