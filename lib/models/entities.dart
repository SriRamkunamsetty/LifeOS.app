import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.profilePhoto,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.gender,
    required this.activityLevel,
    required this.dietPreference,
    required this.createdAt,
    required this.onboardingCompleted,
  });

  final String userId;
  final String name;
  final String email;
  final String? profilePhoto;
  final int age;
  final double height;
  final double weight;
  final String fitnessGoal;
  final String gender;
  final String activityLevel;
  final String dietPreference;
  final Timestamp createdAt;
  final bool onboardingCompleted;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePhoto': profilePhoto,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'gender': gender,
      'activityLevel': activityLevel,
      'dietPreference': dietPreference,
      'createdAt': createdAt,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory UserProfile.fromMap(String userId, Map<String, dynamic> map) {
    return UserProfile(
      userId: userId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profilePhoto: map['profilePhoto'] as String?,
      age: map['age'] as int? ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      fitnessGoal: map['fitnessGoal'] as String? ?? 'Maintain weight',
      gender: map['gender'] as String? ?? 'Male',
      activityLevel: map['activityLevel'] as String? ?? 'Moderate',
      dietPreference: map['dietPreference'] as String? ?? 'Balanced',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
    );
  }
}

class TaskItem {
  TaskItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.deadline,
    required this.status,
    required this.createdAt,
    this.tags = const [],
    this.subtasks = const [],
    this.recurring = false,
    this.order = 0,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final String priority;
  final Timestamp? deadline;
  final String status;
  final Timestamp createdAt;
  final List<String> tags;
  final List<String> subtasks;
  final bool recurring;
  final int order;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'deadline': deadline,
      'status': status,
      'createdAt': createdAt,
      'tags': tags,
      'subtasks': subtasks,
      'recurring': recurring,
      'order': order,
    };
  }

  factory TaskItem.fromMap(String id, Map<String, dynamic> map) {
    return TaskItem(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priority: map['priority'] as String? ?? 'Medium',
      deadline: map['deadline'] as Timestamp?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      tags: List<String>.from(map['tags'] ?? const []),
      subtasks: List<String>.from(map['subtasks'] ?? const []),
      recurring: map['recurring'] as bool? ?? false,
      order: map['order'] as int? ?? 0,
    );
  }
}

class HabitItem {
  HabitItem({
    required this.id,
    required this.userId,
    required this.habitName,
    required this.frequency,
    required this.streak,
    required this.completionHistory,
  });

  final String id;
  final String userId;
  final String habitName;
  final String frequency;
  final int streak;
  final Map<String, bool> completionHistory;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'habitName': habitName,
      'frequency': frequency,
      'streak': streak,
      'completionHistory': completionHistory,
    };
  }

  factory HabitItem.fromMap(String id, Map<String, dynamic> map) {
    final raw = Map<String, dynamic>.from(map['completionHistory'] ?? {});
    return HabitItem(
      id: id,
      userId: map['userId'] as String? ?? '',
      habitName: map['habitName'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'Daily',
      streak: map['streak'] as int? ?? 0,
      completionHistory: raw.map((k, v) => MapEntry(k, v as bool? ?? false)),
    );
  }
}

class NoteItem {
  NoteItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> tags;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt,
    };
  }

  factory NoteItem.fromMap(String id, Map<String, dynamic> map) {
    return NoteItem(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      tags: List<String>.from(map['tags'] ?? const []),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class DietLog {
  DietLog({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String mealType;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp,
    };
  }

  factory DietLog.fromMap(String id, Map<String, dynamic> map) {
    return DietLog(
      id: id,
      userId: map['userId'] as String? ?? '',
      mealType: map['mealType'] as String? ?? 'Breakfast',
      foodName: map['foodName'] as String? ?? '',
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class WaterLog {
  WaterLog({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final int amount;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'amount': amount, 'timestamp': timestamp};
  }

  factory WaterLog.fromMap(String id, Map<String, dynamic> map) {
    return WaterLog(
      id: id,
      userId: map['userId'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class WeightLog {
  WeightLog({
    required this.id,
    required this.userId,
    required this.weight,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final double weight;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'weight': weight, 'timestamp': timestamp};
  }

  factory WeightLog.fromMap(String id, Map<String, dynamic> map) {
    return WeightLog(
      id: id,
      userId: map['userId'] as String? ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class FitnessLog {
  FitnessLog({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.duration,
    required this.caloriesBurned,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String activityType;
  final int duration;
  final double caloriesBurned;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'activityType': activityType,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp,
    };
  }

  factory FitnessLog.fromMap(String id, Map<String, dynamic> map) {
    return FitnessLog(
      id: id,
      userId: map['userId'] as String? ?? '',
      activityType: map['activityType'] as String? ?? 'Running',
      duration: map['duration'] as int? ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0,
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String role;
  final String text;
  final DateTime createdAt;
}
