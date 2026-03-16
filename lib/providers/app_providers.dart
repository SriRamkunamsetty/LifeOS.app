import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entities.dart';
import '../services/ai_service/ai_service.dart';
import '../services/firebase_service/auth_service.dart';
import '../services/firebase_service/firestore_service.dart';
import '../services/voice_service.dart';

final firebaseReadyProvider = Provider<bool>((ref) => true);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (ref) => FirebaseMessaging.instance,
);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.watch(firestoreProvider));
});

final aiServiceProvider = Provider<AiService>((ref) => AiService());
final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull;
});

final userIdProvider = Provider<String?>(
  (ref) => ref.watch(currentUserProvider)?.uid,
);

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref.watch(firestoreServiceProvider).watchProfile(uid);
});

final tasksProvider = StreamProvider<List<TaskItem>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchTasks(uid);
});

final habitsProvider = StreamProvider<List<HabitItem>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchHabits(uid);
});

final notesProvider = StreamProvider<List<NoteItem>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchNotes(uid);
});

final dietLogsProvider = StreamProvider<List<DietLog>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchDietLogs(uid);
});

final waterLogsProvider = StreamProvider<List<WaterLog>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchWaterLogs(uid);
});

final weightLogsProvider = StreamProvider<List<WeightLog>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchWeightLogs(uid);
});

final fitnessLogsProvider = StreamProvider<List<FitnessLog>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchFitnessLogs(uid);
});

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
