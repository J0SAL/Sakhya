class UserProfile {
  final String id;
  String name;
  String occupation;
  int monthlyGoal;
  int familySize;
  String location;
  int dailyIncomeMin;
  int dailyIncomeMax;
  int dailyExpenseMin;
  int dailyExpenseMax;
  int totalSavings;
  int lifetimeRewardPoints;
  int streakDays;
  String lastCompletedDate; // 'yyyy-MM-dd'
  int lessonsCompleted;

  UserProfile({
    required this.id,
    required this.name,
    this.occupation = 'Tailoring',
    this.monthlyGoal = 5000,
    this.familySize = 4,
    this.location = 'Rajasthan, India',
    this.dailyIncomeMin = 300,
    this.dailyIncomeMax = 700,
    this.dailyExpenseMin = 100,
    this.dailyExpenseMax = 250,
    this.totalSavings = 0,
    this.lifetimeRewardPoints = 0,
    this.streakDays = 0,
    this.lastCompletedDate = '',
    this.lessonsCompleted = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'occupation': occupation,
    'monthlyGoal': monthlyGoal,
    'familySize': familySize,
    'location': location,
    'dailyIncomeMin': dailyIncomeMin,
    'dailyIncomeMax': dailyIncomeMax,
    'dailyExpenseMin': dailyExpenseMin,
    'dailyExpenseMax': dailyExpenseMax,
    'totalSavings': totalSavings,
    'lifetimeRewardPoints': lifetimeRewardPoints,
    'streakDays': streakDays,
    'lastCompletedDate': lastCompletedDate,
    'lessonsCompleted': lessonsCompleted,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    occupation: json['occupation'] as String? ?? 'Tailoring',
    monthlyGoal: json['monthlyGoal'] as int? ?? 5000,
    familySize: json['familySize'] as int? ?? 4,
    location: json['location'] as String? ?? 'Rajasthan, India',
    dailyIncomeMin: json['dailyIncomeMin'] as int? ?? 300,
    dailyIncomeMax: json['dailyIncomeMax'] as int? ?? 700,
    dailyExpenseMin: json['dailyExpenseMin'] as int? ?? 100,
    dailyExpenseMax: json['dailyExpenseMax'] as int? ?? 250,
    totalSavings: json['totalSavings'] as int? ?? 0,
    lifetimeRewardPoints: json['lifetimeRewardPoints'] as int? ?? 0,
    streakDays: json['streakDays'] as int? ?? 0,
    lastCompletedDate: json['lastCompletedDate'] as String? ?? '',
    lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
  );

  /// Compute income/expense ranges from occupation + family size
  static UserProfile fromOnboarding({
    required String name,
    required String occupation,
    required int monthlyGoal,
    required int familySize,
    String location = 'Rajasthan, India',
  }) {
    // Rule-based ranges (placeholder until LLM integration in Phase-2)
    int incMin, incMax, expMin, expMax;
    switch (occupation.toLowerCase()) {
      case 'tailoring':
        incMin = 300; incMax = 700; expMin = 150; expMax = 300; break;
      case 'farming':
        incMin = 200; incMax = 500; expMin = 120; expMax = 250; break;
      case 'shopkeeper':
        incMin = 400; incMax = 900; expMin = 200; expMax = 400; break;
      case 'domestic worker':
        incMin = 200; incMax = 400; expMin = 100; expMax = 200; break;
      default:
        incMin = 250; incMax = 600; expMin = 120; expMax = 280;
    }
    // Adjust for family size
    final expAdjust = (familySize - 4) * 30;
    expMin = (expMin + expAdjust).clamp(80, 600);
    expMax = (expMax + expAdjust).clamp(120, 800);

    return UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      occupation: occupation,
      monthlyGoal: monthlyGoal,
      familySize: familySize,
      location: location,
      dailyIncomeMin: incMin,
      dailyIncomeMax: incMax,
      dailyExpenseMin: expMin,
      dailyExpenseMax: expMax,
    );
  }
}
