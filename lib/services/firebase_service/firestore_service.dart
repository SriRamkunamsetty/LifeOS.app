import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../models/entities.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String path) =>
      _firestore.collection(path);

  Stream<UserProfile?> watchProfile(String userId) {
    return _col(AppConstants.usersCollection).doc(userId).snapshots().map((
      doc,
    ) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(userId, doc.data()!);
    });
  }

  Future<void> upsertProfile(UserProfile profile) {
    return _col(
      AppConstants.usersCollection,
    ).doc(profile.userId).set(profile.toMap(), SetOptions(merge: true));
  }

  Stream<List<TaskItem>> watchTasks(String userId) {
    return _col(AppConstants.tasksCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TaskItem.fromMap(d.id, d.data()))
              .toList(growable: false),
        );
  }

  Future<void> saveTask(TaskItem task) {
    final ref = _col(AppConstants.tasksCollection).doc(task.id);
    return ref.set(task.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteTask(String id) {
    return _col(AppConstants.tasksCollection).doc(id).delete();
  }

  Future<void> updateTaskOrder(List<TaskItem> tasks) async {
    final batch = _firestore.batch();
    for (var i = 0; i < tasks.length; i++) {
      batch.update(_col(AppConstants.tasksCollection).doc(tasks[i].id), {
        'order': i,
      });
    }
    await batch.commit();
  }

  Stream<List<HabitItem>> watchHabits(String userId) {
    return _col(AppConstants.habitsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => HabitItem.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveHabit(HabitItem habit) {
    return _col(AppConstants.habitsCollection).doc(habit.id).set(habit.toMap());
  }

  Future<void> deleteHabit(String id) {
    return _col(AppConstants.habitsCollection).doc(id).delete();
  }

  Stream<List<NoteItem>> watchNotes(String userId) {
    return _col(AppConstants.notesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => NoteItem.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveNote(NoteItem note) {
    return _col(AppConstants.notesCollection).doc(note.id).set(note.toMap());
  }

  Future<void> deleteNote(String id) {
    return _col(AppConstants.notesCollection).doc(id).delete();
  }

  Stream<List<DietLog>> watchDietLogs(String userId) {
    return _col(AppConstants.dietLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => DietLog.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveDietLog(DietLog log) {
    return _col(AppConstants.dietLogsCollection).doc(log.id).set(log.toMap());
  }

  Stream<List<WaterLog>> watchWaterLogs(String userId) {
    return _col(AppConstants.waterLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WaterLog.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveWaterLog(WaterLog log) {
    return _col(AppConstants.waterLogsCollection).doc(log.id).set(log.toMap());
  }

  Stream<List<WeightLog>> watchWeightLogs(String userId) {
    return _col(AppConstants.weightLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WeightLog.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveWeightLog(WeightLog log) {
    return _col(AppConstants.weightLogsCollection).doc(log.id).set(log.toMap());
  }

  Stream<List<FitnessLog>> watchFitnessLogs(String userId) {
    return _col(AppConstants.fitnessLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => FitnessLog.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveFitnessLog(FitnessLog log) {
    return _col(
      AppConstants.fitnessLogsCollection,
    ).doc(log.id).set(log.toMap());
  }
}
