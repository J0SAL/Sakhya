class DaySummary {
  final String date; // 'yyyy-MM-dd'
  int incomeEarned;
  int gharAllocation;
  int dhandaAllocation;
  int householdExpense;
  int savings;
  int rewardDelta; // points gained or lost today (game portion)
  int learningRewardDelta; // points from lessons today
  int scamRewardDelta; // points from scam event today
  bool allocationCorrect;
  bool scamCompleted;
  bool scamCorrect;
  int lessonsAttempted;
  int lessonsCorrect;
  List<String> tasksCompleted;
  bool usedLaxmiDidiHelp;

  DaySummary({
    required this.date,
    this.incomeEarned = 0,
    this.gharAllocation = 0,
    this.dhandaAllocation = 0,
    this.householdExpense = 0,
    this.savings = 0,
    this.rewardDelta = 0,
    this.learningRewardDelta = 0,
    this.scamRewardDelta = 0,
    this.allocationCorrect = false,
    this.scamCompleted = false,
    this.scamCorrect = false,
    this.lessonsAttempted = 0,
    this.lessonsCorrect = 0,
    this.tasksCompleted = const [],
    this.usedLaxmiDidiHelp = false,
  });

  int get totalRewardDelta => rewardDelta + learningRewardDelta + scamRewardDelta;

  bool get hasActivity => incomeEarned > 0 || lessonsAttempted > 0;

  factory DaySummary.forToday() {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    return DaySummary(date: date, tasksCompleted: []);
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'incomeEarned': incomeEarned,
    'gharAllocation': gharAllocation,
    'dhandaAllocation': dhandaAllocation,
    'householdExpense': householdExpense,
    'savings': savings,
    'rewardDelta': rewardDelta,
    'learningRewardDelta': learningRewardDelta,
    'scamRewardDelta': scamRewardDelta,
    'allocationCorrect': allocationCorrect,
    'scamCompleted': scamCompleted,
    'scamCorrect': scamCorrect,
    'lessonsAttempted': lessonsAttempted,
    'lessonsCorrect': lessonsCorrect,
    'tasksCompleted': tasksCompleted,
    'usedLaxmiDidiHelp': usedLaxmiDidiHelp,
  };

  factory DaySummary.fromJson(Map<String, dynamic> json) => DaySummary(
    date: json['date'],
    incomeEarned: json['incomeEarned'] ?? 0,
    gharAllocation: json['gharAllocation'] ?? 0,
    dhandaAllocation: json['dhandaAllocation'] ?? 0,
    householdExpense: json['householdExpense'] ?? 0,
    savings: json['savings'] ?? 0,
    rewardDelta: json['rewardDelta'] ?? 0,
    learningRewardDelta: json['learningRewardDelta'] ?? 0,
    scamRewardDelta: json['scamRewardDelta'] ?? 0,
    allocationCorrect: json['allocationCorrect'] ?? false,
    scamCompleted: json['scamCompleted'] ?? false,
    scamCorrect: json['scamCorrect'] ?? false,
    lessonsAttempted: json['lessonsAttempted'] ?? 0,
    lessonsCorrect: json['lessonsCorrect'] ?? 0,
    tasksCompleted: List<String>.from(json['tasksCompleted'] ?? []),
    usedLaxmiDidiHelp: json['usedLaxmiDidiHelp'] ?? false,
  );
}
