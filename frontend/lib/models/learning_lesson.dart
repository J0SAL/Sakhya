class LearningLesson {
  final int id;
  final String title;
  final String titleHindi;
  final String concept;
  final String emoji;
  final String quizQuestion;
  final List<String> options;
  final int correctIndex;
  bool isCompleted;
  bool isUnlocked;

  LearningLesson({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.concept,
    required this.emoji,
    required this.quizQuestion,
    required this.options,
    required this.correctIndex,
    this.isCompleted = false,
    this.isUnlocked = false,
  });

  static List<LearningLesson> defaults() => [
    LearningLesson(
      id: 1, emoji: '💰', isUnlocked: true,
      title: 'What is Saving?', titleHindi: 'Bachat Kya Hai?',
      concept: 'Bachat matlab hai aaj ki kamai ka kuch hissa kal ke liye rakhna. Jaise ek beej jo baad mein ped banta hai. Bachat se hum mushkil waqt mein madad le sakte hain.',
      quizQuestion: 'Agar aapki daily kamai ₹500 hai aur kharcha ₹350, toh bachat kitni hogi?',
      options: ['₹100', '₹150', '₹200', '₹500'],
      correctIndex: 1,
    ),
    LearningLesson(
      id: 2, emoji: '🏦', isUnlocked: false,
      title: 'What is a Bank?', titleHindi: 'Bank Kya Hota Hai?',
      concept: 'Bank ek surakshit jagah hai jahan aap apne paise rakh sakte hain. Bank aapke paise par byaaj (interest) bhi deta hai. Bank se kabhi bhi paise nikale ja sakte hain.',
      quizQuestion: 'Bank mein paise rakhne ka kya fayda hai?',
      options: ['Paise kho jaate hain', 'Paise surakshit rehte hain aur badhte hain', 'Paise log le lete hain', 'Koi fayda nahi'],
      correctIndex: 1,
    ),
    LearningLesson(
      id: 3, emoji: '📱', isUnlocked: false,
      title: 'What is UPI?', titleHindi: 'UPI Kya Hai?',
      concept: 'UPI (Unified Payments Interface) se aap phone se paise bhej sakte hain. Bahut safe aur aasaan tarika hai. Har transaction ka message aata hai — isko zaroor padhein.',
      quizQuestion: 'UPI payment ke baad kya karna chahiye?',
      options: ['Kuch nahi', 'SMS confirmation padhna chahiye', 'PIN kisi ko batana chahiye', 'App band kar dena chahiye'],
      correctIndex: 1,
    ),
    LearningLesson(
      id: 4, emoji: '⚠️', isUnlocked: false,
      title: 'Scam Awareness', titleHindi: 'Dhoka Pehchanein',
      concept: 'Koi bhi sarkari ya bank officer phone par OTP ya PIN kabhi nahi maangta. Agar koi maange toh yeh DHOKA hai. Phone rakh dein aur family ko batayein.',
      quizQuestion: 'Ek aadmi phone kar ke kehta hai "Bank se bol raha hoon, apna OTP dijiye." Aap kya karein?',
      options: ['OTP de dein', 'Thoda sochein phir batayein', 'Phone rakh dein — yeh scam hai', 'PIN bhi batayein'],
      correctIndex: 2,
    ),
    LearningLesson(
      id: 5, emoji: '💸', isUnlocked: false,
      title: 'Income vs Expense', titleHindi: 'Kamai aur Kharcha',
      concept: 'Kamai (income) woh paise hain jo aap kamati hain. Kharcha (expense) woh paise hain jo aap kharchti hain. Agar kharcha kamai se zyada ho toh problem hoti hai.',
      quizQuestion: 'Mahine mein kamai ₹8000 aur kharcha ₹9000 hai toh kya hoga?',
      options: ['₹1000 bachat hogi', 'Bachat zero hogi', '₹1000 kami padegi — udhaar lena padega', 'Sab theek rahega'],
      correctIndex: 2,
    ),
    LearningLesson(
      id: 6, emoji: '🎯', isUnlocked: false,
      title: 'Setting a Goal', titleHindi: 'Lakshya Banana',
      concept: 'Financial goal matlab ek fixed kharcha ya achieement ke liye paise jodna. Jaise bachon ki fees ke liye ₹3000 jodna. Chota-chota bachat bada fark karti hai.',
      quizQuestion: 'Ashi ka lakshy hai ₹6000 jodna. Woh roz ₹200 bachati hai. Kitne din mein lakshya poora hoga?',
      options: ['20 din', '30 din', '40 din', '60 din'],
      correctIndex: 1,
    ),
    LearningLesson(
      id: 7, emoji: '🌱', isUnlocked: false,
      title: 'What is Investment?', titleHindi: 'Nivesh Kya Hai?',
      concept: 'Nivesh matlab apne paise ko kisi jagah lagana jahan se woh badhte hain. Jaise beej lagaoge toh fasal milegi. Dhanda mein lagaaye paise profit dilate hain.',
      quizQuestion: 'Ranu ने ₹1000 laga ke naya kapda kharida dhande ke liye. Yeh kya hai?',
      options: ['Kharcha', 'Nivesh (Investment)', 'Nuksan', 'Bachat'],
      correctIndex: 1,
    ),
    LearningLesson(
      id: 8, emoji: '🤝', isUnlocked: false,
      title: 'Safe Borrowing', titleHindi: 'Surakshit Udhaar',
      concept: 'Kabhi bhi loan lene se pehle — kitna byaaj lagega, kab wapas karna hai, yeh zaroor poochein. Online loan apps kaafi dangerous ho sakti hain. SHG ya bank se loan zyada safe hai.',
      quizQuestion: 'Kaunsa loan zyada surakshit hai?',
      options: ['WhatsApp par aaya loan offer', 'Anjaan aadmi se phone pe loan', 'Bank ya SHG se loan', 'Kisi bhi jagah se — sab same hai'],
      correctIndex: 2,
    ),
    LearningLesson(
      id: 9, emoji: '📊', isUnlocked: false,
      title: 'Monthly Budget', titleHindi: 'Mahine Ka Budget',
      concept: 'Budget matlab pehle se yeh decide karna ki paise kahan kharchne hain. Ghar ka kharcha, bachat, dhande ka kharcha — sab plan karo. Budget se paise control mein rehte hain.',
      quizQuestion: 'Budget banana kyun zaroori hai?',
      options: ['Paisa khatam karne ke liye', 'Paisa vyarth karne ke liye', 'Paisa control mein rakhne ke liye', 'Koi zaroorat nahi'],
      correctIndex: 2,
    ),
    LearningLesson(
      id: 10, emoji: '🏆', isUnlocked: false,
      title: 'Emergency Fund', titleHindi: 'Aapatkaaleen Bachat',
      concept: 'Emergency fund matlab mushkil waqt ke liye alag rakhe hue paise. Bimari, accident, ya achanak kharcha — emergency fund kaam aati hai. Kam se kam 1 mahine ki kamai ka 30% alag rakhein.',
      quizQuestion: 'Lata ki monthly kamai ₹5000 hai. Usse kitna emergency fund rakhna chahiye?',
      options: ['₹200', '₹500', '₹750', '₹1500'],
      correctIndex: 3,
    ),
  ];
}
