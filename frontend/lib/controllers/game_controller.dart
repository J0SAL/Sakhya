import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/day_summary.dart';
import '../models/learning_lesson.dart';
import '../services/database_helper.dart';
import '../services/tts_service.dart';

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
  int currentTabIndex = 0;

  void setTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  // ── Day State ────────────────────────────────────────────
  int dailyIncome = 0;
  int gharBalance = 0;
  int dhandaBalance = 0;
  int unallocated = 0;

  // Suggested allocation amounts (shown as hints)
  int get suggestedGhar => dailyIncome > 0 ? ((dailyIncome * 0.6).round() ~/ 100) * 100 : 0;
  int get suggestedDhanda => dailyIncome > 0 ? dailyIncome - suggestedGhar : 0;

  // Minimum required amounts
  static const int minGhar = 100;    // minimum for household
  static const int minDhanda = 150;  // minimum for business

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
  // Persistence — SQLite (offline-first) with SharedPreferences fallback
  // ──────────────────────────────────────────────────────────

  Future<void> _loadUsers() async {
    // 1. Try SQLite first
    try {
      final dbUsers = await DatabaseHelper.instance.loadUsers();
      if (dbUsers.isNotEmpty) {
        allUsers = dbUsers;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('DB load users failed, falling back to prefs: $e');
    }

    // 2. Migrate from SharedPreferences if SQLite is empty
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('sakhya_users') ?? [];
      if (raw.isNotEmpty) {
        allUsers = raw.map((s) => UserProfile.fromJson(jsonDecode(s))).toList();
        // Write migrated data to SQLite
        await DatabaseHelper.instance.saveAllUsers(allUsers);
      }
    } catch (e) {
      debugPrint('Prefs migration error: $e');
    }
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    try {
      await DatabaseHelper.instance.saveAllUsers(allUsers);
    } catch (e) {
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'sakhya_users',
        allUsers.map((u) => jsonEncode(u.toJson())).toList(),
      );
    }
  }

  Future<void> _saveCurrentUser() async {
    if (currentUser == null) return;
    final idx = allUsers.indexWhere((u) => u.id == currentUser!.id);
    if (idx >= 0) allUsers[idx] = currentUser!;
    try {
      await DatabaseHelper.instance.saveUser(currentUser!);
    } catch (e) {
      await _saveUsers();
    }
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
    _checkAndFlushStaleSummary();
    _loadSummary();
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
      _saveSummary();
    }
  }

  Future<void> createUser(UserProfile profile) async {
    allUsers.add(profile);
    await _saveUsers();
    currentUser = profile;
    rewardPoints = 0;
    _checkAndFlushStaleSummary();
    _refreshLessonsFromUser();
    _loadSummary();
    if (todaySummary == null || todaySummary!.date != _todayStr()) {
      todaySummary = DaySummary.forToday();
      _saveSummary();
    }
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
    _saveSummary();

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

  /// Returns true if both minimums are met AND within ±10% of suggested split
  bool validateAllocation() {
    if (gharBalance < minGhar) return false;
    if (dhandaBalance < minDhanda) return false;
    final tolerance = (dailyIncome * 0.10).round();
    final gharOk = (gharBalance - suggestedGhar).abs() <= tolerance;
    return gharOk;
  }

  // Whether the current allocation attempt has been submitted and failed
  bool allocationFailed = false;

  void submitAllocation() {
    final correct = validateAllocation();
    todaySummary!.gharAllocation = gharBalance;
    todaySummary!.dhandaAllocation = dhandaBalance;
    todaySummary!.allocationCorrect = correct;
    todaySummary!.usedLaxmiDidiHelp = usedHintThisAllocation;

    if (correct) {
      allocationFailed = false;
      _addReward(2, category: 'game');
      if (!usedHintThisAllocation) _addReward(1, category: 'game'); // bonus
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '✅ Allocation'];
      TtsService.instance.speak('शाबाश! आपने सही बँटवारा किया!');
      _saveSummary();
      currentPhase = GamePhase.store1; // ✅ only advance on correct
    } else {
      allocationFailed = true;
      _addReward(-1, category: 'game');
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '❌ Allocation'];
      TtsService.instance.speak('कोशिश करें। लक्ष्मी दीदी से मदद लें।');
      _saveSummary();
      // Stay on GamePhase.allocation — do NOT advance to store1
    }
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
      _saveSummary();
      notifyListeners();
      return true;
    } else {
      _addReward(-1, category: 'game');
      _saveSummary();
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
    _checkAndResetDayIfNeeded();
    scamResolvedToday = true;
    todaySummary!.scamCompleted = true;
    if (rejected) {
      _addReward(usedHint ? 1 : 2, category: 'scam');
      todaySummary!.scamCorrect = true;
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '✅ Scam Rejected'];
      TtsService.instance.speak('बहुत अच्छा! आपने scam को पहचाना!');
    } else {
      _addReward(-1, category: 'scam');
      todaySummary!.scamCorrect = false;
      todaySummary!.tasksCompleted = [...todaySummary!.tasksCompleted, '❌ Scam OTP Entered'];
      TtsService.instance.speak('अगली बार सावधान रहें। OTP कभी न दें।');
    }
    _saveSummary();
    pendingScamEvent = false;
    notifyListeners();
  }

  // End of Day
  void completeEndOfDay() {
    if (currentUser == null) return;
    if (currentPhase == GamePhase.daySummary) {
      notifyListeners();
      return; 
    }

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

    currentUser!.lifetimeRewardPoints = rewardPoints;
    _saveSummary();

    currentPhase = GamePhase.daySummary;
    currentTabIndex = 3; // Switch to Summary tab
    notifyListeners();
  }

  Future<void> finalizeDayAndSleep() async {
    if (currentUser == null || todaySummary == null) return;
    final userId = currentUser!.id;

    // Apply deferred points
    rewardPoints += todaySummary!.totalRewardDelta;
    currentUser!.lifetimeRewardPoints = rewardPoints;

    // Apply deferred savings
    currentUser!.totalSavings += todaySummary!.savings;

    // Apply streak
    final today = _todayStr();
    final user = currentUser;
    if (user != null) {
      final lastDate = user.lastCompletedDate;
      if (lastDate != today) {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
        if (lastDate == yStr) {
          user.streakDays++;
        } else {
          user.streakDays = 1;
        }
        user.lastCompletedDate = today;
      }
    }

    _saveCurrentUser();
    
    // Delete today's summary from DB
    try {
      await DatabaseHelper.instance.deleteSummary(userId, _todayStr());
    } catch (e) {
      // Fallback: clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_summary_$userId');
    }
    
    // RESET DAY FOR NEXT LOOP
    todaySummary = DaySummary.forToday();
    unallocated = 0;
    gharBalance = 0;
    dhandaBalance = 0;
    dailyIncome = 0;
    
    currentPhase = GamePhase.startDay;
    currentTabIndex = 0; // Back to Home
    notifyListeners();
  }

  void completeLesson(int lessonId, {required bool correct, required bool usedHint}) {
    _checkAndResetDayIfNeeded();
    final summary = todaySummary;
    if (summary == null) return;

    summary.lessonsAttempted++;
    if (correct) {
      summary.lessonsCorrect++;
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
      final currentMax = currentUser?.lessonsCompleted ?? 0;
      if (idx + 1 > currentMax) {
        currentUser?.lessonsCompleted = idx + 1;
      }
      _saveCurrentUser();
      _saveSummary();
    }
    notifyListeners();
  }

  Future<void> wipeAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Also wipe SQLite
    try {
      for (final u in allUsers) {
        await DatabaseHelper.instance.deleteSummary(u.id, _todayStr());
      }
      await DatabaseHelper.instance.saveAllUsers([]);
    } catch (e) {
      debugPrint('Wipe DB error: $e');
    }
    allUsers.clear();
    currentUser = null;
    todaySummary = DaySummary.forToday();
    currentPhase = GamePhase.userSelect;
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
    switch (category) {
      case 'game': todaySummary?.rewardDelta += delta; break;
      case 'learning': todaySummary?.learningRewardDelta += delta; break;
      case 'scam': todaySummary?.scamRewardDelta += delta; break;
    }
  }

  void _checkAndFlushStaleSummary() async {
    if (currentUser == null) return;
    try {
      // Try SQLite first
      final summary = await DatabaseHelper.instance.loadLatestSummary(currentUser!.id);
      if (summary != null && summary.date != _todayStr()) {
        // It's from a previous day — flush it
        rewardPoints += summary.totalRewardDelta;
        currentUser!.lifetimeRewardPoints = rewardPoints;
        currentUser!.totalSavings += summary.savings;

        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
        if (currentUser!.lastCompletedDate == yStr) {
          currentUser!.streakDays++;
        } else if (summary.date == yStr) {
          currentUser!.streakDays = 1;
        }
        currentUser!.lastCompletedDate = summary.date;
        _saveCurrentUser();
        await DatabaseHelper.instance.deleteSummary(currentUser!.id, summary.date);
        return;
      }
    } catch (e) {
      debugPrint('DB flush summary error: $e');
    }

    // Fallback: SharedPreferences migration
    try {
      final prefs = await SharedPreferences.getInstance();
      final summaryJson = prefs.getString('pending_summary_${currentUser?.id}');
      if (summaryJson != null) {
        final summary = DaySummary.fromJson(jsonDecode(summaryJson));
        if (summary.date != _todayStr()) {
          rewardPoints += summary.totalRewardDelta;
          currentUser!.lifetimeRewardPoints = rewardPoints;
          currentUser!.totalSavings += summary.savings;
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
          if (currentUser!.lastCompletedDate == yStr) {
            currentUser!.streakDays++;
          } else if (summary.date == yStr) {
            currentUser!.streakDays = 1;
          }
          currentUser!.lastCompletedDate = summary.date;
          _saveCurrentUser();
          await prefs.remove('pending_summary_${currentUser?.id}');
        }
      }
    } catch (e) {
      debugPrint('Prefs flush error: $e');
    }
  }

  void _saveSummary() async {
    if (currentUser == null || todaySummary == null) return;
    try {
      await DatabaseHelper.instance.saveSummary(currentUser!.id, todaySummary!);
    } catch (e) {
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_summary_${currentUser!.id}', jsonEncode(todaySummary!.toJson()));
    }
  }

  void _loadSummary() async {
    if (currentUser == null) return;
    try {
      final summary = await DatabaseHelper.instance.loadSummary(currentUser!.id, _todayStr());
      if (summary != null) {
        todaySummary = summary;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('DB load summary error: $e');
    }
    // Fallback: SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final summaryJson = prefs.getString('pending_summary_${currentUser!.id}');
    if (summaryJson != null) {
      try {
        final summary = DaySummary.fromJson(jsonDecode(summaryJson));
        if (summary.date == _todayStr()) {
          todaySummary = summary;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Prefs load summary error: $e');
      }
    }
  }

  // Direct navigation helpers
  void goToStore() {
    currentTabIndex = 0; // Home tab
    currentPhase = GamePhase.store1;
    notifyListeners();
  }

  void goToStartDay() {
    currentTabIndex = 0; // Home tab
    currentPhase = GamePhase.startDay;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    currentPhase = GamePhase.userSelect;
    currentTabIndex = 0;
    notifyListeners();
  }

  void developmentResetToday() {
    if (currentUser != null && todaySummary != null) {
      currentUser!.lastCompletedDate = '';
      
      if (currentPhase == GamePhase.daySummary) {
        currentUser!.totalSavings = (currentUser!.totalSavings - todaySummary!.savings).clamp(0, 999999);
        if (currentUser!.streakDays > 0) {
          currentUser!.streakDays--;
        }
      }

      final earnedToday = todaySummary!.rewardDelta + todaySummary!.learningRewardDelta + todaySummary!.scamRewardDelta;
      rewardPoints = (rewardPoints - earnedToday).clamp(0, 999999);
      currentUser!.lifetimeRewardPoints = rewardPoints;

      if (todaySummary!.lessonsCorrect > 0) {
        currentUser!.lessonsCompleted = (currentUser!.lessonsCompleted - todaySummary!.lessonsCorrect).clamp(0, lessons.length);
      }

      _saveCurrentUser();
    }
    
    _refreshLessonsFromUser();

    gharBalance = 0;
    dhandaBalance = 0;
    unallocated = 0;
    dailyIncome = 0;

    todaySummary = DaySummary.forToday();
    _saveSummary();
    scamResolvedToday = false;
    currentPhase = GamePhase.startDay;
    notifyListeners();
  }

  int get streakDays => currentUser?.streakDays ?? 0;
  int get totalSavings => currentUser?.totalSavings ?? 0;
  int get monthlyGoal => currentUser?.monthlyGoal ?? 5000;
  double get monthlyGoalProgress => monthlyGoal > 0 ? (totalSavings / monthlyGoal).clamp(0.0, 1.0) : 0;
}
