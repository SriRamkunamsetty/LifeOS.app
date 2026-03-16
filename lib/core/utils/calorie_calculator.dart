double calculateBmr({
  required String gender,
  required int age,
  required double weightKg,
  required double heightCm,
}) {
  final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
  return gender.toLowerCase() == 'male' ? base + 5 : base - 161;
}

double calculateCalorieTarget({
  required double bmr,
  required String fitnessGoal,
}) {
  switch (fitnessGoal.toLowerCase()) {
    case 'weight loss':
      return bmr - 500;
    case 'weight gain':
    case 'muscle gain':
      return bmr + 500;
    default:
      return bmr;
  }
}
