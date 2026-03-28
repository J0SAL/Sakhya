/// AppStrings — centralized Hindi/English localization for Sakhya.
/// Usage: AppStrings.of(context).greeting
///
/// To add a new string:
///  1. Add it to the abstract base class.
///  2. Add the Hindi translation to _HiStrings.
///  3. Add the English translation to _EnStrings.

import 'package:flutter/material.dart';

// ── Controller ────────────────────────────────────────────────────────────────
class LanguageController extends ChangeNotifier {
  Locale _locale = const Locale('hi');
  Locale get locale => _locale;

  bool get isHindi => _locale.languageCode == 'hi';

  void setHindi() {
    _locale = const Locale('hi');
    notifyListeners();
  }

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void toggle() {
    isHindi ? setEnglish() : setHindi();
    notifyListeners();
  }
}

// ── LessonStrings helper ─────────────────────────────────────────────────────
class LessonStrings {
  final String titleNative;
  final String concept;
  final String question;
  final List<String> options;
  const LessonStrings({required this.titleNative, required this.concept, required this.question, required this.options});
}

// ── Base class ────────────────────────────────────────────────────────────────
abstract class AppStrings {
  static AppStrings of(BuildContext context) {
    final lc = _LanguageControllerScope.of(context);
    return lc?.isHindi == false ? _EnStrings() : _HiStrings();
  }

  /// Returns localized lesson strings for the given lesson id (1-10).
  LessonStrings? lessonOf(int id) {
    final allLessons = [
      LessonStrings(titleNative: l1TitleNative, concept: l1Concept, question: l1Question, options: [l1Opt0, l1Opt1, l1Opt2, l1Opt3]),
      LessonStrings(titleNative: l2TitleNative, concept: l2Concept, question: l2Question, options: [l2Opt0, l2Opt1, l2Opt2, l2Opt3]),
      LessonStrings(titleNative: l3TitleNative, concept: l3Concept, question: l3Question, options: [l3Opt0, l3Opt1, l3Opt2, l3Opt3]),
      LessonStrings(titleNative: l4TitleNative, concept: l4Concept, question: l4Question, options: [l4Opt0, l4Opt1, l4Opt2, l4Opt3]),
      LessonStrings(titleNative: l5TitleNative, concept: l5Concept, question: l5Question, options: [l5Opt0, l5Opt1, l5Opt2, l5Opt3]),
      LessonStrings(titleNative: l6TitleNative, concept: l6Concept, question: l6Question, options: [l6Opt0, l6Opt1, l6Opt2, l6Opt3]),
      LessonStrings(titleNative: l7TitleNative, concept: l7Concept, question: l7Question, options: [l7Opt0, l7Opt1, l7Opt2, l7Opt3]),
      LessonStrings(titleNative: l8TitleNative, concept: l8Concept, question: l8Question, options: [l8Opt0, l8Opt1, l8Opt2, l8Opt3]),
      LessonStrings(titleNative: l9TitleNative, concept: l9Concept, question: l9Question, options: [l9Opt0, l9Opt1, l9Opt2, l9Opt3]),
      LessonStrings(titleNative: l10TitleNative, concept: l10Concept, question: l10Question, options: [l10Opt0, l10Opt1, l10Opt2, l10Opt3]),
    ];
    if (id < 1 || id > allLessons.length) return null;
    return allLessons[id - 1];
  }

  /// correctAnswer — localized message for correct quiz answer
  String correctAnswer(int coins) => isHindi
      ? '🎉 सही जवाब! +$coins सिक्के!'
      : '🎉 Correct! +$coins coins!';

  // Helper to check which language
  bool get isHindi => this is _HiStrings;

  String get appName;
  String get namaste;
  String get loading;

  // ── Bottom nav
  String get navHome;
  String get navLearn;
  String get navLaxmiDidi;
  String get navSummary;

  // ── Home Dashboard
  String get monthlyGoal;
  String get goalProgress; // takes % param — use sprintf or format outside
  String get startDayTitle;
  String get startDaySubtitle;
  String get startDayButton;
  String get dayDoneTitle;
  String get kamai;
  String get bachat;
  String get summaryButton;  // "Aaj ka summary dekhein"
  String get gharLabel;
  String get dhandaLabel;
  String get wapasShop;

  // ── Summary Screen
  String get summaryHeader;
  String get gameStats;
  String get allocation;
  String get allocationCorrect;
  String get allocationWrong;
  String get gharAlloc;
  String get dhandaAlloc;
  String get gharKharcha;
  String get aajKiBachat;
  String get learningTitle;
  String get lessonsTriedLabel;
  String get correctAnswers;
  String get wrongAnswers;
  String get noLesson;
  String get scamDojo;
  String get noScamToday;
  String get scamRejected;
  String get scamOtpGiven;
  String get laxmiHelp;
  String get tasksTitle;
  String get totalReward;
  String get endDayButton;
  String get endDayNote;
  String get emptyStatTitle;
  String get emptyStatSub;

  // ── Allocation Screen
  String get allocationTitle;
  String get allocationSubtitle;
  String get gharPot;
  String get dhandaPot;
  String get hintButton;
  String get submitButton;

  // ── Laxmi Didi
  String get laxmiDidiTitle;
  String get laxmiDidiSubtitle;
  String get laxmiDidiHint;
  String get laxmiDidiGreeting;
  String get laxmiDidiChip1;
  String get laxmiDidiChip2;
  String get laxmiDidiChip3;
  String get laxmiDidiChip4;
  String get laxmiDidiChip5;
  String get laxmiDidiMicHint;

  // ── Quiz UI strings
  String get startQuizButton;
  String get questionLabel;
  String get hintLabel;
  String get laxmiHintButton;
  String get wrongAnswer;
  String get goBackButton;

  // ── Language picker
  String get languageLabel;
  String get languageHindi;
  String get languageEnglish;

  // ── Profile Screen
  String get profileTitle;
  String get monthlyGoalLabel;
  String get incomeRangeLabel;
  String get statsLabel;
  String get streakLabel;
  String get totalPointsLabel;
  String get lessonsCompleteLabel;
  String get totalSavingsLabel;
  String get familyMembersLabel;
  String get savingsLabel;
  String get completedLabel;
  String get profileSaved;
  String get perDay;

  // ── Allocation screen UI labels
  String get allocationBarTitle;
  String get allocationSplitBarHint;
  String get paisBaantDein;
  String get allocationSuccessNoHint;
  String get allocationSuccessHint;
  String get allocationFailGhar;
  String get allocationFailDhanda;

  // ── Lesson content (each lesson: title, titleNative, concept, question, opt0..3)
  // Lesson 1 — Saving
  String get l1Title; String get l1TitleNative;
  String get l1Concept; String get l1Question;
  String get l1Opt0; String get l1Opt1; String get l1Opt2; String get l1Opt3;
  // Lesson 2 — Bank
  String get l2Title; String get l2TitleNative;
  String get l2Concept; String get l2Question;
  String get l2Opt0; String get l2Opt1; String get l2Opt2; String get l2Opt3;
  // Lesson 3 — UPI
  String get l3Title; String get l3TitleNative;
  String get l3Concept; String get l3Question;
  String get l3Opt0; String get l3Opt1; String get l3Opt2; String get l3Opt3;
  // Lesson 4 — Scam
  String get l4Title; String get l4TitleNative;
  String get l4Concept; String get l4Question;
  String get l4Opt0; String get l4Opt1; String get l4Opt2; String get l4Opt3;
  // Lesson 5 — Income vs Expense
  String get l5Title; String get l5TitleNative;
  String get l5Concept; String get l5Question;
  String get l5Opt0; String get l5Opt1; String get l5Opt2; String get l5Opt3;
  // Lesson 6 — Goal
  String get l6Title; String get l6TitleNative;
  String get l6Concept; String get l6Question;
  String get l6Opt0; String get l6Opt1; String get l6Opt2; String get l6Opt3;
  // Lesson 7 — Investment
  String get l7Title; String get l7TitleNative;
  String get l7Concept; String get l7Question;
  String get l7Opt0; String get l7Opt1; String get l7Opt2; String get l7Opt3;
  // Lesson 8 — Borrowing
  String get l8Title; String get l8TitleNative;
  String get l8Concept; String get l8Question;
  String get l8Opt0; String get l8Opt1; String get l8Opt2; String get l8Opt3;
  // Lesson 9 — Budget
  String get l9Title; String get l9TitleNative;
  String get l9Concept; String get l9Question;
  String get l9Opt0; String get l9Opt1; String get l9Opt2; String get l9Opt3;
  // Lesson 10 — Emergency
  String get l10Title; String get l10TitleNative;
  String get l10Concept; String get l10Question;
  String get l10Opt0; String get l10Opt1; String get l10Opt2; String get l10Opt3;

  // ── User Select Screen
  String get selectUserTitle;
  String get newUserButton;
  String get noUsersTitle;
  String get noUsersSubtitle;
  String get appTagline;

  // ── New User Flow
  String get namePage;
  String get nameHint;
  String get nameSubtitle;
  String get occupationPage;
  String get occupationSubtitle;
  String get goalPage;
  String get goalSubtitle;
  String get familyPage;
  String get familySubtitle;
  String get familySizeLabel;
  String get locationLabel;
  String get nextButton;
  String get startSakhyaButton;
  String get nameRequired;

  // ── Allocation minimums
  String get minGharLabel;          // "Min ₹100 ghar ke liye zaroori"
  String get minDhandaLabel;        // "Min ₹150 dhande ke liye zaroori"
  String get allocationFailMsg;     // message when below min
  String get tryAgainMsg;
}

// ── Provider helper ───────────────────────────────────────────────────────────
class _LanguageControllerScope extends InheritedNotifier<LanguageController> {
  const _LanguageControllerScope({
    required super.notifier,
    required super.child,
  });

  static LanguageController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LanguageControllerScope>()
        ?.notifier;
  }
}

class LanguageControllerProvider extends StatelessWidget {
  final LanguageController controller;
  final Widget child;
  const LanguageControllerProvider({super.key, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) => _LanguageControllerScope(notifier: controller, child: child);
}

// ── Hindi translations ────────────────────────────────────────────────────────
class _HiStrings extends AppStrings {
  @override String get appName => 'सखी';
  @override String get namaste => 'नमस्ते';
  @override String get loading => 'लोड हो रहा है…';

  @override String get navHome => 'घर';
  @override String get navLearn => 'सीखें';
  @override String get navLaxmiDidi => 'लक्ष्मी दीदी';
  @override String get navSummary => 'आज का हाल';

  @override String get monthlyGoal => 'महीने का लक्ष्य 🎯';
  @override String get goalProgress => '% पूरा हो गया!';
  @override String get startDayTitle => 'आज का नया दिन!';
  @override String get startDaySubtitle => 'शुरू करें और आज की कमाई संभालें';
  @override String get startDayButton => 'दिन शुरू करें 🌅';
  @override String get dayDoneTitle => 'आज का दिन पूरा हुआ!';
  @override String get kamai => 'कमाई';
  @override String get bachat => 'बचत';
  @override String get summaryButton => 'आज का समरी देखें 📊';
  @override String get gharLabel => '🏠 घर';
  @override String get dhandaLabel => '🪡 धंधा';
  @override String get wapasShop => 'वापस शॉप ➔';

  @override String get summaryHeader => 'आज का हाल';
  @override String get gameStats => 'खेल के आंकड़े';
  @override String get allocation => 'आवंटन';
  @override String get allocationCorrect => '✅ सही';
  @override String get allocationWrong => '❌ गलत';
  @override String get gharAlloc => 'घर बंट';
  @override String get dhandaAlloc => 'धंधा बंट';
  @override String get gharKharcha => 'घर खर्चा';
  @override String get aajKiBachat => 'आज की बचत 🌟';
  @override String get learningTitle => 'सीखना (Learning)';
  @override String get lessonsTriedLabel => 'Lessons try किए';
  @override String get correctAnswers => 'सही जवाब';
  @override String get wrongAnswers => 'गलत जवाब';
  @override String get noLesson => 'कोई lesson नहीं';
  @override String get scamDojo => 'Scam Dojo';
  @override String get noScamToday => 'आज scam event नहीं आया';
  @override String get scamRejected => '✅ Reject किया!';
  @override String get scamOtpGiven => '❌ OTP दे दिया';
  @override String get laxmiHelp => 'लक्ष्मी दीदी मदद ली';
  @override String get tasksTitle => 'काम जो हुए';
  @override String get totalReward => 'आज के कुल Reward 🏆';
  @override String get endDayButton => '🌙 सोना जाइए (दिन खत्म)';
  @override String get endDayNote => 'आज की बचत और rewards 12 बजे update होंगे।';
  @override String get emptyStatTitle => 'आज का हाल खाली है';
  @override String get emptyStatSub => 'खेल शुरू करें या कोई lesson सीखें — सब यहाँ दिखेगा!';

  @override String get allocationTitle => 'पैसे बाँटें';
  @override String get allocationSubtitle => 'अपनी कमाई घर और धंधे में बाँटें';
  @override String get gharPot => '🏠 घर';
  @override String get dhandaPot => '🪡 धंधा';
  @override String get hintButton => 'लक्ष्मी दीदी से पूछें 💡';
  @override String get submitButton => 'जमा करें';

  @override String get laxmiDidiTitle => 'लक्ष्मी दीदी';
  @override String get laxmiDidiSubtitle => 'आपकी आर्थिक सहेली 🌿';
  @override String get laxmiDidiHint => 'सवाल पूछें…';
  @override String get laxmiDidiGreeting => 'नमस्ते! मैं लक्ष्मी दीदी हूँ। आप मुझसे कोई भी सवाल पूछ सकती हैं — बचत, UPI, या scam के बारे में! 🙏';
  @override String get laxmiDidiChip1 => 'बचत क्या है?';
  @override String get laxmiDidiChip2 => 'Scam से कैसे बचें?';
  @override String get laxmiDidiChip3 => 'UPI safe है?';
  @override String get laxmiDidiChip4 => 'Budget कैसे बनाएं?';
  @override String get laxmiDidiChip5 => 'Loan लेना ठीक है?';
  @override String get laxmiDidiMicHint => 'बोलकर पूछें';

  // Quiz UI
  @override String get startQuizButton => 'इस पाठ का quiz करें 📝';
  @override String get questionLabel => 'सवाल:';
  @override String get hintLabel => 'संकेत';
  @override String get laxmiHintButton => 'लक्ष्मी दीदी से संकेत लें';
  @override String get wrongAnswer => '❌ गलत। -1 सिक्का।';
  @override String get goBackButton => 'वापस जाएं';

  @override String get languageLabel => 'भाषा';
  @override String get languageHindi => 'हिंदी';
  @override String get languageEnglish => 'English';

  // Profile Screen
  @override String get profileTitle => 'मेरा प्रोफाइल';
  @override String get monthlyGoalLabel => 'महीने का लक्ष्य 🎯';
  @override String get incomeRangeLabel => 'रोजाना की कमाई 💰';
  @override String get statsLabel => 'आंकड़े 📊';
  @override String get streakLabel => '🔥 रोजाना सिलसिला';
  @override String get totalPointsLabel => '⭐ कुल अंक';
  @override String get lessonsCompleteLabel => '📚 सीखे गए पाठ';
  @override String get totalSavingsLabel => '💰 कुल बचत';
  @override String get familyMembersLabel => '👨‍👩‍👧 परिवार';
  @override String get savingsLabel => 'बचत';
  @override String get completedLabel => 'पूरा';
  @override String get profileSaved => 'प्रोफाइल सहेजा गया ✅';
  @override String get perDay => 'प्रतिदिन';

  // Allocation screen
  @override String get allocationBarTitle => 'पैसे कैसे बांटें?';
  @override String get allocationSplitBarHint => 'खिंचकर बाँटें';
  @override String get paisBaantDein => 'पैसे बांट दें ✓';
  @override String get allocationSuccessNoHint => 'सही बांट! +2 सिक्के और +1 बोनस! 🎉';
  @override String get allocationSuccessHint => 'सही बांट! +2 सिक्के मिले! 🎉';
  @override String get allocationFailGhar => 'घर के लिए न्यूनतम ₹100 जरूरी! लक्ष्मी दीदी से मदद लें। -1 अंक';
  @override String get allocationFailDhanda => 'धंधे के लिए न्यूनतम ₹150 जरूरी! सुझाव: घर 60%, धंधा 40%। -1 अंक';

  // Lessons (Hindi)
  @override String get l1Title => 'बचत क्या है?'; @override String get l1TitleNative => 'बचत क्या है?';
  @override String get l1Concept => 'बचत मतलब है आज की कमाई का कुछ हिस्सा कल के लिए रखना। जैसे एक बीज जो बाद में पेड़ बनता है। बचत से हम मुश्किल वक्त में मदद ले सकते हैं।';
  @override String get l1Question => 'अगर आपकी रोजाना कमाई ₹500 है और खर्चा ₹350, तो बचत कितनी होगी?';
  @override String get l1Opt0 => '₹100'; @override String get l1Opt1 => '₹150'; @override String get l1Opt2 => '₹200'; @override String get l1Opt3 => '₹500';
  @override String get l2Title => 'बैंक क्या होता है?'; @override String get l2TitleNative => 'बैंक क्या होता है?';
  @override String get l2Concept => 'बैंक एक सुरक्षित जगह है जहाँ आप अपने पैसे रख सकते हैं। बैंक आपके पैसे पर ब्याज (इंटरेस्ट) भी देता है। बैंक से कभी भी पैसे निकाले जा सकते हैं।';
  @override String get l2Question => 'बैंक में पैसे रखने का क्या फायदा है?';
  @override String get l2Opt0 => 'पैसे खो जाते हैं'; @override String get l2Opt1 => 'पैसे सुरक्षित रहते हैं और बढ़ते हैं'; @override String get l2Opt2 => 'लोग ले लेते हैं'; @override String get l2Opt3 => 'कोई फायदा नहीं';
  @override String get l3Title => 'UPI क्या है?'; @override String get l3TitleNative => 'UPI क्या है?';
  @override String get l3Concept => 'UPI (Unified Payments Interface) से आप फोन से पैसे भेज सकते हैं। बहुत सुरक्षित और आसान तरीका है। हर लेनदेन का संदेश आता है — इसे ज़रूर पढ़ें।';
  @override String get l3Question => 'UPI भुगतान के बाद क्या करना चाहिए?';
  @override String get l3Opt0 => 'कुछ नहीं'; @override String get l3Opt1 => 'SMS पंजीकरण पढ़ना चाहिए'; @override String get l3Opt2 => 'PIN किसी को बताना चाहिए'; @override String get l3Opt3 => 'एप बंद कर देना चाहिए';
  @override String get l4Title => 'धोखा पहचानें'; @override String get l4TitleNative => 'धोखा पहचानें';
  @override String get l4Concept => 'कोई भी सरकारी या बैंक अधिकारी फोन पर OTP या PIN कभी नहीं मांगता। अगर कोई मांगे तो यह धोखा है। फोन रख दें और परिवार को बताएं।';
  @override String get l4Question => 'एक आदमी फोन करके कहता है “बैंक से बोल रहा हूँ, अपना OTP दीजिए।” आप क्या करें?';
  @override String get l4Opt0 => 'OTP दे दें'; @override String get l4Opt1 => 'थोड़ा सोचें फिर बताएं'; @override String get l4Opt2 => 'फोन रख दें — यह धोखा है'; @override String get l4Opt3 => 'PIN भी बताएं';
  @override String get l5Title => 'कमाई और खर्च'; @override String get l5TitleNative => 'कमाई और खर्च';
  @override String get l5Concept => 'कमाई (income) वो पैसे हैं जो आप कमाती हैं। खर्चा (expense) वो पैसे हैं जो खर्च होते हैं। अगर खर्चा कमाई से ज़्यादा हो तो मुश्किल होती है।';
  @override String get l5Question => 'महीने में कमाई ₹8000 और खर्चा ₹9000 है तो क्या होगा?';
  @override String get l5Opt0 => '₹1000 बचत होगी'; @override String get l5Opt1 => 'बचत शून्य'; @override String get l5Opt2 => '₹1000 कमी — उधार लेना पड़ेगा'; @override String get l5Opt3 => 'सब ठीक रहेगा';
  @override String get l6Title => 'लक्ष्य बनाएं'; @override String get l6TitleNative => 'लक्ष्य बनाएं';
  @override String get l6Concept => 'आर्थिक लक्ष्य मतलब एक तय खर्चे के लिए पैसे जोड़ना। जैसे बच्चों की फीस के लिए ₹3000 जोड़ना। छोटी-छोटी बचत बड़ा फर्क करती है।';
  @override String get l6Question => 'आशा का लक्ष्य है ₹6000 जोड़ना। वो रोज ₹200 बचाती है। कितने दिन में लक्ष्य पूरा होगा?';
  @override String get l6Opt0 => '20 दिन'; @override String get l6Opt1 => '30 दिन'; @override String get l6Opt2 => '40 दिन'; @override String get l6Opt3 => '60 दिन';
  @override String get l7Title => 'निवेश क्या है?'; @override String get l7TitleNative => 'निवेश क्या है?';
  @override String get l7Concept => 'निवेश मतलब अपने पैसे को किसी जगह लगाना जहाँ से वो बढ़ते हैं। जैसे बीज लगाओगे तो फसल मिलेगी। धंधे में लगाए पैसे फायदा दिलाते हैं।';
  @override String get l7Question => 'रानु ने ₹1000 लगा के नया कपड़ा खरीदा धंधे के लिए। ये क्या है?';
  @override String get l7Opt0 => 'खर्चा'; @override String get l7Opt1 => 'निवेश'; @override String get l7Opt2 => 'नुकसान'; @override String get l7Opt3 => 'बचत';
  @override String get l8Title => 'सुरक्षित उधार'; @override String get l8TitleNative => 'सुरक्षित उधार';
  @override String get l8Concept => 'कभी भी लोन लेने से पहले — कितना ब्याज लगेगा, कब वापस करना है, यह ज़रूर पूछें। ऑनलाइन लोन अप्स बहुत खतरनाक हो सकती हैं। SHG या बैंक से लोन ज़्यादा सुरक्षित है।';
  @override String get l8Question => 'कौनसा लोन ज़्यादा सुरक्षित है?';
  @override String get l8Opt0 => 'WhatsApp पर आया लोन ऑफर'; @override String get l8Opt1 => 'अनजान आदमी से फोन पे लोन'; @override String get l8Opt2 => 'बैंक या SHG से लोन'; @override String get l8Opt3 => 'सब समान हैं';
  @override String get l9Title => 'महीने का बजट'; @override String get l9TitleNative => 'महीने का बजट';
  @override String get l9Concept => 'बजट मतलब पहले से यह तय करना कि पैसे कहाँ खर्च होंगे। घर का खर्चा, बचत, धंधे का खर्चा — सब प्लान करो। बजट से पैसे नियंत्रण में रहते हैं।';
  @override String get l9Question => 'बजट बनाना क्यों ज़रूरी है?';
  @override String get l9Opt0 => 'पैसा खतम करने के लिए'; @override String get l9Opt1 => 'पैसा व्यर्थ करने के लिए'; @override String get l9Opt2 => 'पैसा नियंत्रण में रखने के लिए'; @override String get l9Opt3 => 'कोई ज़रूरत नहीं';
  @override String get l10Title => 'आपतकालीन बचत'; @override String get l10TitleNative => 'आपतकालीन बचत';
  @override String get l10Concept => 'आपातकालीन बचत मतलब मुश्किल वक्त के लिए अलग रखे हुए पैसे। बीमारी, दुर्घटना, या अचानक खर्चा — आपातकालीन बचत काम आती है।';
  @override String get l10Question => 'लता की मासिक कमाई ₹5000 है। उसे कितनी आपातकालीन बचत रखनी चाहिए?';
  @override String get l10Opt0 => '₹200'; @override String get l10Opt1 => '₹500'; @override String get l10Opt2 => '₹750'; @override String get l10Opt3 => '₹1500';

  // User Select
  @override String get selectUserTitle => 'कौन हैं आप? 🌸';
  @override String get newUserButton => 'नया User बनाएं';
  @override String get noUsersTitle => 'कोई user नहीं मिला';
  @override String get noUsersSubtitle => 'नया user बनाने के लिए नीचे button दबाएं';
  @override String get appTagline => 'आपकी आर्थिक सहेली';


  // New User Flow
  @override String get namePage => 'आपका नाम?';
  @override String get nameHint => 'जैसे: सुनीता, मीना, रानी…';
  @override String get nameSubtitle => 'अपना नाम लिखें जिससे Sakhya आपको जाने';
  @override String get occupationPage => 'आप क्या काम करती हैं?';
  @override String get occupationSubtitle => 'अपना पेशा चुनें';
  @override String get goalPage => 'महीने का लक्ष्य?';
  @override String get goalSubtitle => 'आप इस महीने कितना बचत करना चाहती हैं?';
  @override String get familyPage => 'परिवार का साथ?';
  @override String get familySubtitle => 'परिवार में कितने लोग हैं?';
  @override String get familySizeLabel => 'परिवार का आकार';
  @override String get locationLabel => 'स्थान';
  @override String get nextButton => 'आगे चलें →';
  @override String get startSakhyaButton => '✅ Sakhya शुरू करें';
  @override String get nameRequired => 'अपना नाम लिखें';

  // Allocation minimums
  @override String get minGharLabel => 'न्यूनतम ₹100 घर के लिए जरूरी';
  @override String get minDhandaLabel => 'न्यूनतम ₹150 धंधे के लिए जरूरी';
  @override String get allocationFailMsg => 'न्यूनतम राशि नहीं दी। लक्ष्मी दीदी से मदद लें! -1 point';
  @override String get tryAgainMsg => 'फिर से कोशिश करें 🔄';
}

// ── English translations ──────────────────────────────────────────────────────
class _EnStrings extends AppStrings {
  @override String get appName => 'Sakhya';
  @override String get namaste => 'Hello';
  @override String get loading => 'Loading…';

  @override String get navHome => 'Home';
  @override String get navLearn => 'Learn';
  @override String get navLaxmiDidi => 'Laxmi Didi';
  @override String get navSummary => "Today's Report";

  @override String get monthlyGoal => 'Monthly Goal 🎯';
  @override String get goalProgress => '% completed!';
  @override String get startDayTitle => "Today's New Day!";
  @override String get startDaySubtitle => 'Start and manage your earnings for the day';
  @override String get startDayButton => 'Start the Day 🌅';
  @override String get dayDoneTitle => "Today's Day Complete!";
  @override String get kamai => 'Income';
  @override String get bachat => 'Savings';
  @override String get summaryButton => "See Today's Summary 📊";
  @override String get gharLabel => '🏠 Home';
  @override String get dhandaLabel => '🪡 Business';
  @override String get wapasShop => 'Back to Shop ➔';

  @override String get summaryHeader => "Today's Report";
  @override String get gameStats => 'Game Stats';
  @override String get allocation => 'Allocation';
  @override String get allocationCorrect => '✅ Correct';
  @override String get allocationWrong => '❌ Wrong';
  @override String get gharAlloc => 'Home Share';
  @override String get dhandaAlloc => 'Business Share';
  @override String get gharKharcha => 'Home Expense';
  @override String get aajKiBachat => "Today's Savings 🌟";
  @override String get learningTitle => 'Learning';
  @override String get lessonsTriedLabel => 'Lessons Tried';
  @override String get correctAnswers => 'Correct Answers';
  @override String get wrongAnswers => 'Wrong Answers';
  @override String get noLesson => 'No lesson today';
  @override String get scamDojo => 'Scam Dojo';
  @override String get noScamToday => 'No scam event today';
  @override String get scamRejected => '✅ Rejected!';
  @override String get scamOtpGiven => '❌ Gave OTP';
  @override String get laxmiHelp => 'Used Laxmi Didi help';
  @override String get tasksTitle => 'Tasks Done';
  @override String get totalReward => "Today's Total Reward 🏆";
  @override String get endDayButton => '🌙 End Day (Sleep)';
  @override String get endDayNote => "Today's savings and rewards will update at midnight.";
  @override String get emptyStatTitle => "Today's report is empty";
  @override String get emptyStatSub => 'Play the game or complete a lesson — everything will show here!';

  @override String get allocationTitle => 'Split Money';
  @override String get allocationSubtitle => 'Divide your income between Home and Business';
  @override String get gharPot => '🏠 Home';
  @override String get dhandaPot => '🪡 Business';
  @override String get hintButton => 'Ask Laxmi Didi 💡';
  @override String get submitButton => 'Submit';

  @override String get laxmiDidiTitle => 'Laxmi Didi';
  @override String get laxmiDidiSubtitle => 'Your Financial Friend 🌿';
  @override String get laxmiDidiHint => 'Ask a question…';
  @override String get laxmiDidiGreeting => "Hello! I'm Laxmi Didi. You can ask me anything about savings, UPI, or scams! 🙏";
  @override String get laxmiDidiChip1 => 'What is saving?';
  @override String get laxmiDidiChip2 => 'How to avoid scams?';
  @override String get laxmiDidiChip3 => 'Is UPI safe?';
  @override String get laxmiDidiChip4 => 'How to make a budget?';
  @override String get laxmiDidiChip5 => 'Is taking a loan okay?';
  @override String get laxmiDidiMicHint => 'Speak your question';

  // Quiz UI
  @override String get startQuizButton => 'Try this lesson\'s quiz 📝';
  @override String get questionLabel => 'Question:';
  @override String get hintLabel => 'Hint';
  @override String get laxmiHintButton => 'Get a hint from Laxmi Didi';
  @override String get wrongAnswer => '❌ Wrong. -1 coin.';
  @override String get goBackButton => 'Go Back';

  @override String get languageLabel => 'Language';
  @override String get languageHindi => 'हिंदी';
  @override String get languageEnglish => 'English';

  // Profile Screen
  @override String get profileTitle => 'My Profile';
  @override String get monthlyGoalLabel => 'Monthly Goal 🎯';
  @override String get incomeRangeLabel => 'Daily Income 💰';
  @override String get statsLabel => 'Stats 📊';
  @override String get streakLabel => '🔥 Daily Streak';
  @override String get totalPointsLabel => '⭐ Total Points';
  @override String get lessonsCompleteLabel => '📚 Lessons Complete';
  @override String get totalSavingsLabel => '💰 Total Savings';
  @override String get familyMembersLabel => '👨‍👩‍👧 Family';
  @override String get savingsLabel => 'Savings';
  @override String get completedLabel => 'Complete';
  @override String get profileSaved => 'Profile saved ✅';
  @override String get perDay => 'per day';

  // Allocation screen
  @override String get allocationBarTitle => 'How to split money?';
  @override String get allocationSplitBarHint => 'Drag to split';
  @override String get paisBaantDein => 'Split Money ✓';
  @override String get allocationSuccessNoHint => 'Correct split! +2 coins and +1 bonus! 🎉';
  @override String get allocationSuccessHint => 'Correct split! +2 coins! 🎉';
  @override String get allocationFailGhar => 'Minimum ₹100 needed for Home! Ask Laxmi Didi for help. -1 point';
  @override String get allocationFailDhanda => 'Minimum ₹150 needed for Business! Suggested: Home 60%, Business 40%. -1 point';

  // Lessons (English)
  @override String get l1Title => 'What is Saving?'; @override String get l1TitleNative => 'What is Saving?';
  @override String get l1Concept => 'Saving means keeping a part of today\'s earnings for tomorrow. Like a seed that grows into a tree. Savings help us in difficult times.';
  @override String get l1Question => 'If your daily income is ₹500 and expense is ₹350, what is your saving?';
  @override String get l1Opt0 => '₹100'; @override String get l1Opt1 => '₹150'; @override String get l1Opt2 => '₹200'; @override String get l1Opt3 => '₹500';
  @override String get l2Title => 'What is a Bank?'; @override String get l2TitleNative => 'What is a Bank?';
  @override String get l2Concept => 'A bank is a safe place to keep your money. The bank also gives you interest on your money. Money can be withdrawn from the bank anytime.';
  @override String get l2Question => 'What is the benefit of keeping money in a bank?';
  @override String get l2Opt0 => 'Money gets lost'; @override String get l2Opt1 => 'Money stays safe and grows'; @override String get l2Opt2 => 'People take it'; @override String get l2Opt3 => 'No benefit';
  @override String get l3Title => 'What is UPI?'; @override String get l3TitleNative => 'What is UPI?';
  @override String get l3Concept => 'UPI (Unified Payments Interface) lets you send money via phone. It is a very safe and easy method. A message arrives for every transaction — always read it.';
  @override String get l3Question => 'What should you do after a UPI payment?';
  @override String get l3Opt0 => 'Nothing'; @override String get l3Opt1 => 'Read the SMS confirmation'; @override String get l3Opt2 => 'Tell PIN to someone'; @override String get l3Opt3 => 'Close the app';
  @override String get l4Title => 'Scam Awareness'; @override String get l4TitleNative => 'Scam Awareness';
  @override String get l4Concept => 'No government or bank officer ever asks for OTP or PIN on the phone. If someone asks, it is a SCAM. Hang up the phone and inform your family.';
  @override String get l4Question => 'A person calls and says "I am from the bank, give me your OTP." What do you do?';
  @override String get l4Opt0 => 'Give OTP'; @override String get l4Opt1 => 'Think then tell'; @override String get l4Opt2 => 'Hang up — it is a scam'; @override String get l4Opt3 => 'Also give PIN';
  @override String get l5Title => 'Income vs Expense'; @override String get l5TitleNative => 'Income vs Expense';
  @override String get l5Concept => 'Income is money you earn. Expense is money you spend. If expense is more than income, there is a problem.';
  @override String get l5Question => 'Monthly income is ₹8000 and expense is ₹9000. What happens?';
  @override String get l5Opt0 => '₹1000 savings'; @override String get l5Opt1 => 'Zero savings'; @override String get l5Opt2 => '₹1000 shortfall — need to borrow'; @override String get l5Opt3 => 'Everything is fine';
  @override String get l6Title => 'Setting a Goal'; @override String get l6TitleNative => 'Setting a Goal';
  @override String get l6Concept => 'A financial goal means saving money for a fixed purpose. Like saving ₹3000 for children\'s fees. Small savings make a big difference.';
  @override String get l6Question => 'Asha\'s goal is to save ₹6000. She saves ₹200 per day. In how many days will she reach her goal?';
  @override String get l6Opt0 => '20 days'; @override String get l6Opt1 => '30 days'; @override String get l6Opt2 => '40 days'; @override String get l6Opt3 => '60 days';
  @override String get l7Title => 'What is Investment?'; @override String get l7TitleNative => 'What is Investment?';
  @override String get l7Concept => 'Investment means putting your money somewhere it grows. Like planting seeds to get crops. Money invested in business brings profit.';
  @override String get l7Question => 'Ranu invested ₹1000 to buy new cloth for her business. What is this?';
  @override String get l7Opt0 => 'Expense'; @override String get l7Opt1 => 'Investment'; @override String get l7Opt2 => 'Loss'; @override String get l7Opt3 => 'Savings';
  @override String get l8Title => 'Safe Borrowing'; @override String get l8TitleNative => 'Safe Borrowing';
  @override String get l8Concept => 'Before taking any loan — always ask how much interest, when to repay. Online loan apps can be very dangerous. A loan from SHG or bank is safer.';
  @override String get l8Question => 'Which loan is safer?';
  @override String get l8Opt0 => 'Loan offer on WhatsApp'; @override String get l8Opt1 => 'Loan from stranger on phone'; @override String get l8Opt2 => 'Loan from bank or SHG'; @override String get l8Opt3 => 'All are the same';
  @override String get l9Title => 'Monthly Budget'; @override String get l9TitleNative => 'Monthly Budget';
  @override String get l9Concept => 'A budget means deciding in advance where money will be spent. Home expense, savings, business expense — plan it all. Budget keeps money in control.';
  @override String get l9Question => 'Why is making a budget important?';
  @override String get l9Opt0 => 'To finish money'; @override String get l9Opt1 => 'To waste money'; @override String get l9Opt2 => 'To keep money in control'; @override String get l9Opt3 => 'No need';
  @override String get l10Title => 'Emergency Fund'; @override String get l10TitleNative => 'Emergency Fund';
  @override String get l10Concept => 'Emergency fund means money kept aside for difficult times. Illness, accident, or sudden expense — the emergency fund helps. Keep at least 30% of one month\'s income aside.';
  @override String get l10Question => 'Lata\'s monthly income is ₹5000. How much emergency fund should she keep?';
  @override String get l10Opt0 => '₹200'; @override String get l10Opt1 => '₹500'; @override String get l10Opt2 => '₹750'; @override String get l10Opt3 => '₹1500';

  // User Select
  @override String get selectUserTitle => 'Who are you? 🌸';
  @override String get newUserButton => 'Create New User';
  @override String get noUsersTitle => 'No user found';
  @override String get noUsersSubtitle => 'Press the button below to create a new user';
  @override String get appTagline => 'Your Financial Friend';

  // New User Flow
  @override String get namePage => 'Your name?';
  @override String get nameHint => 'e.g. Sunita, Meena, Rani…';
  @override String get nameSubtitle => 'Write your name so Sakhya knows you';
  @override String get occupationPage => 'What work do you do?';
  @override String get occupationSubtitle => 'Choose your occupation';
  @override String get goalPage => 'Monthly goal?';
  @override String get goalSubtitle => 'How much do you want to save this month?';
  @override String get familyPage => 'Your family?';
  @override String get familySubtitle => 'How many people are in your family?';
  @override String get familySizeLabel => 'Family Size';
  @override String get locationLabel => 'Location';
  @override String get nextButton => 'Continue →';
  @override String get startSakhyaButton => '✅ Start Sakhya';
  @override String get nameRequired => 'Please enter your name';

  // Allocation minimums
  @override String get minGharLabel => 'Min ₹100 required for household';
  @override String get minDhandaLabel => 'Min ₹150 required for business';
  @override String get allocationFailMsg => 'Minimum not met. Laxmi Didi suggests more! -1 point';
  @override String get tryAgainMsg => 'Try Again 🔄';
}
