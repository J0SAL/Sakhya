import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/day_summary.dart';
import '../models/learning_lesson.dart';

enum GamePhase {
  userSelect,
  newUserFlow,
  startDay,
  allocation,
  store1,
  scamDojo, // modal overlay — not a full phase, handled separately
  endOfDay,
  daySummary,
}

class StoreItem {
  final String name;
  final String nameHindi;
  final int price;
  final String emoji;
  final bool isRecommended;
  int quantity;

  StoreItem({
    required this.name,
    required this.nameHindi,
    required this.price,
    required this.emoji,
    this.isRecommended = false,
    this.quantity = 0,
  });
}

class GameController extends ChangeNotifier {
  // ── User State ──────────────────────────────────────────
  List<UserProfile> allUsers = [];
  UserProfile? currentUser;
  bool get isUserSelected => currentUser != null;

  // ── Game Phase ───────────────────────────────────────────
  GamePhase currentPhase = GamePhase.userSelect;

  // ── Day State ────────────────────────────────────────────
  int dailyIncome = 0;
  int gharBalance = 0;
  int dhandaBalance = 0;
  int unallocated = 0;

  // Suggested allocation amounts (shown as hints)
  int get suggestedGhar => dailyIncome > 0 ? ((dailyIncome * 0.6).round() ~/ 100) * 100 : 0;
  int get suggestedDhanda => dailyIncome > 0 ? dailyIncome - suggestedGhar : 0;

  // Allocation hint usage
  bool usedHintThisAllocation = false;

  // ── Store-1 Items ─────────────────────────────────────────
  List<StoreItem> storeItems = [
    StoreItem(name: 'Cloth (1m)', nameHindi: 'Kapda', price: 150, emoji: '🧵', isRecommended: true),
    StoreItem(name: 'Thread Spool', nameHindi: 'Dhaga', price: 50, emoji: '🪡', isRecommended: true),
    StoreItem(name: 'Needles Pack', nameHindi: 'Sui Pack', price: 20, emoji: '🔩', isRecommended: true),
    StoreItem(name: 'Machine Oil', nameHindi: 'Machine Tel', price: 30, emoji: '🛢️', isRecommended: false),
    StoreItem(name: 'Machine Repair', nameHindi: 'Machine Repair', price: 400, emoji: '🔧', isRecommended: false),
    StoreItem(name: 'Buttons Pack', nameHindi: 'Button Pack', price: 25, emoji: '🔘', isRecommended: false),
  ];

  int get cartTotal => storeItems.fold(0, (sum, item) => sum + item.price * item.quantity);
  bool get hasItemsInCart => storeItems.any((item) => item.quantity > 0);

  // ── Scam Event ────────────────────────────────────────────
  bool pendingScamEvent = false;
  bool scamResolvedToday = false;

  // ── Rewards & Streaks ─────────────────────────────────────
  int rewardPoints = 0;

  // ── Summary ───────────────────────────────────────────────
  DaySummary? todaySummary;

  // ── Lessons ───────────────────────────────────────────────
  List<LearningLesson> lessons = LearningLesson.defaults();

  // ──────────────────────────────────────────────────────────
  // Init
  // ──────────────────────────────────────────────────────────
  GameController() {
    _loadUsers();
  }

  // ──────────────────────────────────────────────────────────
  // Persistence
  // ──────────────────────────────────────────────────────────
  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('sakhya_users') ?? [];
    allUsers = raw.map((s) => UserProfile.fromJson(jsonDecode(s))).toList();

    // Check today's date for summary refresh
    final today = _todayStr();
    final savedDate = prefs.getString('sakhya_last_summary_date') ?? '';
    if (savedDate != today) {
      todaySummary = DaySummary.forToday();
    }

    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sakhya_users',
      allUsers.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }

  Future<void> _saveCurrentUser() async {
    if (currentUser == null) return;
    final idx = allUsers.indexWhere((u) => u.id == currentUser!.id);
    if (idx >= 0) allUsers[idx] = currentUser!;
    await _saveUsers();
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  // ──────────────────────────────────────────────────────────
  // User Management
  // ──────────────────────────────────────────────────────────
  void selectUser(UserProfile user) {
    currentUser = user;
    rewardPoints = user.lifetimeRewardPoints;
    _refreshLessonsFromUser();
    _checkAndResetDayIfNeeded();
    currentPhase = GamePhase.startDay;
    notifyListeners();
  }

  void _refreshLessonsFromUser() {
    // Unlock lessons progressively based on completed count
    final completed = currentUser?.lessonsCompleted ?? 0;
    for (int i = 0; i < lessons.length; i++) {
      lessons[i].isCompleted = i < completed;
      lessons[i].isUnlocked = i <= completed;
    }
  }

  void _checkAndResetDayIfNeeded() {
    todaySummary ??= DaySummary.forToday();
    if (todaySummary!.date != _todayStr()) {
      todaySummary = DaySummary.forToday();
    }
  }

  Future<void> createUser(UserProfile profile) async {
    allUsers.add(profile);
    await _saveUsers();
    currentUser = profile;
    rewardPoints = 0;
    _refreshLessonsFromUser();
    todaySummary = DaySummary.forToday();
    currentPhase = GamePhase.startDay;
    notifyListeners();
  }

  void goToNewUserFlow() {
    currentPhase = GamePhase.newUserFlow;
    notifyListeners();
  }

  void goToUserSelect() {
    currentUser = null;
    currentPhase = GamePhase.userSelect;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────
  // Daily Game Loop
  // ──────────────────────────────────────────────────────────
  void startDay() {
    if (currentUser == null) return;
    final rng = Random();
    // Generate income rounded to nearest 100 within user's range
    final rawMin = currentUser!.dailyIncomeMin;
    final rawMax = currentUser!.dailyIncomeMax;
    final steps = ((rawMax - rawMin) ~/ 100).clamp(1, 100);
    dailyIncome = rawMin + rng.nextInt(steps + 1) * 100;
    // Snap to 100
    dailyIncome = ((dailyIncome / 100).round()) * 100;

    gharBalance = 0;
    dhandaBalance = 0;
    unallocated = dailyIncome;
    usedHintThisAllocation = false;
    pendingScamEvent = false;
    scamResolvedToday = false;

    // Reset cart
    for (var item in storeItems) {
      item.quantity = 0;
    }

    todaySummary ??= DaySummary.forToday();
    todaySummary!.incomeEarned = dailyIncome;

    currentPhase = GamePhase.allocation;
    notifyListeners();
  }

  // Allocation
  void setGharAmount(int amount) {
    gharBalance = amount.clamp(0, dailyIncome);
    dhandaBalance = (dailyIncome - gharBalance).clamp(0, dailyIncome);
    unallocated = 0;
    notifyListeners();
  }

  void setDhandaAmount(int amount) {
    dhandaBalance = amount.clamp(0, dailyIncome);
    gharBalance = (dailyIncome - dhandaBalance).clamp(0, dailyIncome);
    unallocated = 0;
    notifyListeners();
  }

  void useAllocationHint() {
    usedHintThisAllocation = true;
    notifyListeners();
  }

  /// Returns true if allocation is within acceptable range (±10% of suggested)
  bool validateAllocation() {
    final tolerance = (dailyIncome * 0.10).round();
    final gharOk = (gharBalance - suggestedGhar).abs() <= tolerance;
    return gharOk;
  }

  void submitAllocation() {
    final correct = validateAllocation();
    todaySummary!.gharAllocation = gharBalance;
    todaySummary!.dhandaAllocation = dhandaBalance;
    todaySummary!.allocationCorrect = correct;
    todaySummary!.usedLaxmiDidiHelp = usedHintThisAllocation;

    if (correct) {
      _addReward(2, category: 'game');
      if (!usedHintThisAllocation) _addReward(1, category: 'game'); // bonus
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '✅ Allocation'];
    } else {
      _addReward(-1, category: 'game');
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '❌ Allocation'];
    }

    currentPhase = GamePhase.store1;
    notifyListeners();
  }

  // Store-1
  void addToCart(StoreItem item) {
    item.quantity++;
    notifyListeners();
  }

  void removeFromCart(StoreItem item) {
    if (item.quantity > 0) item.quantity--;
    notifyListeners();
  }

  /// Returns true if purchase succeeded
  bool checkout() {
    final total = cartTotal;
    if (total <= dhandaBalance) {
      dhandaBalance -= total;
      _addReward(1, category: 'game');
      for (var item in storeItems) {
        item.quantity = 0;
      }
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '✅ Supplies Bought'];
      notifyListeners();
      return true;
    } else {
      _addReward(-1, category: 'game');
      notifyListeners();
      return false;
    }
  }

  void doneShoppingGoEndOfDay() {
    // Trigger scam event randomly (70% chance for demo)
    pendingScamEvent = !scamResolvedToday && Random().nextInt(10) < 7;
    currentPhase = GamePhase.endOfDay;
    notifyListeners();
  }

  // Scam Dojo
  void resolveScam({required bool rejected, bool usedHint = false}) {
    scamResolvedToday = true;
    todaySummary!.scamCompleted = true;
    if (rejected) {
      _addReward(usedHint ? 1 : 2, category: 'scam');
      todaySummary!.scamCorrect = true;
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '✅ Scam Rejected'];
    } else {
      _addReward(-1, category: 'scam');
      todaySummary!.scamCorrect = false;
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '❌ Scam OTP Entered'];
    }
    pendingScamEvent = false;
    notifyListeners();
  }

  // End of Day
  void completeEndOfDay() {
    if (currentUser == null) return;
    final rng = Random();
    // Deduct random household expense from Ghar range
    final expMin = currentUser!.dailyExpenseMin;
    final expMax = currentUser!.dailyExpenseMax;
    final expense = expMin + rng.nextInt((expMax - expMin).clamp(1, 500));
    final roundedExpense = ((expense / 50).round()) * 50;

    final actualExpense = roundedExpense.clamp(0, gharBalance);
    final savings = gharBalance - actualExpense;

    todaySummary!.householdExpense = actualExpense;
    todaySummary!.savings = savings;

    // Add savings to user profile
    currentUser!.totalSavings += savings;

    // Update streak
    final today = _todayStr();
    if (currentUser!.lastCompletedDate != today) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
      if (currentUser!.lastCompletedDate == yStr) {
        currentUser!.streakDays++;
      } else {
        currentUser!.streakDays = 1;
      }
      currentUser!.lastCompletedDate = today;
    }

    currentUser!.lifetimeRewardPoints = rewardPoints;
    _saveCurrentUser();

    currentPhase = GamePhase.daySummary;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────
  // Learning
  // ──────────────────────────────────────────────────────────
  void completeLesson(int lessonId, {required bool correct, required bool usedHint}) {
    todaySummary!.lessonsAttempted++;
    if (correct) {
      todaySummary!.lessonsCorrect++;
      _addReward(1, category: 'learning');
      if (!usedHint) _addReward(1, category: 'learning'); // bonus
    } else {
      _addReward(-1, category: 'learning');
    }

    final idx = lessons.indexWhere((l) => l.id == lessonId);
    if (idx >= 0 && correct) {
      lessons[idx].isCompleted = true;
      if (idx + 1 < lessons.length) {
        lessons[idx + 1].isUnlocked = true;
      }
      currentUser?.lessonsCompleted = idx + 1;
      _saveCurrentUser();
    }
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────
  // Rewards Store (Store-2)
  // ──────────────────────────────────────────────────────────
  bool buyItemWithPoints(int pointsCost) {
    if (rewardPoints >= pointsCost) {
      rewardPoints -= pointsCost;
      if (currentUser != null) {
        currentUser!.lifetimeRewardPoints = rewardPoints;
        _saveCurrentUser();
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────
  void _addReward(int delta, {required String category}) {
    rewardPoints = (rewardPoints + delta).clamp(0, 99999);
    switch (category) {
      case 'game': todaySummary?.rewardDelta += delta; break;
      case 'learning': todaySummary?.learningRewardDelta += delta; break;
      case 'scam': todaySummary?.scamRewardDelta += delta; break;
    }
  }

  // Direct navigation helpers
  void goToStartDay() {
    currentPhase = GamePhase.startDay;
    notifyListeners();
  }

  int get streakDays => currentUser?.streakDays ?? 0;
  int get totalSavings => currentUser?.totalSavings ?? 0;
  int get monthlyGoal => currentUser?.monthlyGoal ?? 5000;
  double get monthlyGoalProgress => monthlyGoal > 0 ? (totalSavings / monthlyGoal).clamp(0.0, 1.0) : 0;
}
