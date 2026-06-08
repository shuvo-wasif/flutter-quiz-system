import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const QuizApp());
}

// ==========================================
// 1. IN-MEMORY MOCK DATABASE
// ==========================================
class Database {
  // Stores user credentials (email: password)
  static Map<String, String> users = {'admin123@gmail.com': 'admin123'};
  // Stores quiz results {name, subject, score, status}
  static List<Map<String, dynamic>> results = [];
  
  // Stores questions categorized by subject
  static Map<String, List<Map<String, dynamic>>> questions = {
    'Physics': [
      {'q': 'What is the speed of light?', 'options': ['3x10^8 m/s', '3x10^5 m/s', '3x10^2 m/s', '3x10^9 m/s'], 'ans': 0},
      {'q': 'Unit of Force?', 'options': ['Joule', 'Newton', 'Pascal', 'Watt'], 'ans': 1},
      {'q': 'Formula for Ohm Law?', 'options': ['V=IR', 'P=VI', 'F=ma', 'E=mc2'], 'ans': 0},
      {'q': 'What is the charge of an electron?', 'options': ['Positive', 'Neutral', 'Negative', 'Variable'], 'ans': 2},
      {'q': 'Gravity on Earth?', 'options': ['9.8 m/s2', '10.5 m/s2', '8.9 m/s2', '11.2 m/s2'], 'ans': 0},
    ],
    'Chemistry': [
      {'q': 'Chemical symbol for Gold?', 'options': ['Ag', 'Au', 'Pb', 'Fe'], 'ans': 1},
      {'q': 'pH of pure water?', 'options': ['5', '6', '7', '8'], 'ans': 2},
      {'q': 'What gas do plants absorb?', 'options': ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'], 'ans': 2},
      {'q': 'Atomic number of Carbon?', 'options': ['5', '6', '7', '8'], 'ans': 1},
      {'q': 'Most abundant gas in Earth\'s atmosphere?', 'options': ['Oxygen', 'Nitrogen', 'Argon', 'CO2'], 'ans': 1},
    ],
    'Biology': [
      {'q': 'Powerhouse of the cell?', 'options': ['Nucleus', 'Ribosome', 'Mitochondria', 'Golgi'], 'ans': 2},
      {'q': 'How many bones in human body?', 'options': ['206', '208', '210', '212'], 'ans': 0},
      {'q': 'What pumps blood?', 'options': ['Lungs', 'Brain', 'Liver', 'Heart'], 'ans': 3},
      {'q': 'Green pigment in plants?', 'options': ['Hemoglobin', 'Chlorophyll', 'Melanin', 'Carotene'], 'ans': 1},
      {'q': 'Largest organ of human body?', 'options': ['Heart', 'Skin', 'Liver', 'Brain'], 'ans': 1},
    ],
    'Math': [
      {'q': 'Square root of 144?', 'options': ['10', '11', '12', '14'], 'ans': 2},
      {'q': 'Value of Pi (approx)?', 'options': ['3.12', '3.14', '3.16', '3.18'], 'ans': 1},
      {'q': '5 + 5 * 5 = ?', 'options': ['50', '30', '25', '15'], 'ans': 1},
      {'q': 'Angles in a triangle add up to?', 'options': ['90', '180', '270', '360'], 'ans': 1},
      {'q': '10% of 200?', 'options': ['10', '20', '30', '40'], 'ans': 1},
    ],
  };
}

// ==========================================
// 2. MAIN APP SETUP
// ==========================================
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz System',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// 3. AUTHENTICATION SCREEN (Login & Signup)
// ==========================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void authenticate() {
    String email = emailCtrl.text.trim();
    String pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) return;

    if (isLogin) {
      if (email == 'admin123@gmail.com' && pass == 'admin123') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
      } else if (Database.users.containsKey(email) && Database.users[email] == pass) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentSetupScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Credentials')));
      }
    } else {
      // Signup Logic
      if (Database.users.containsKey(email)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User already exists!')));
      } else {
        Database.users[email] = pass;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup Success! Please Login.')));
        setState(() => isLogin = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authenticate,
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Create an account' : 'Already have an account? Login'),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. STUDENT SETUP (Name & Subject Selection)
// ==========================================
class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final nameCtrl = TextEditingController();
  String selectedSubject = 'Physics';

  void startQuiz() {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => QuizScreen(name: nameCtrl.text.trim(), subject: selectedSubject)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Enter your Name')),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              items: Database.questions.keys.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
              onChanged: (val) => setState(() => selectedSubject = val!),
              decoration: const InputDecoration(labelText: 'Select Subject'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: startQuiz, child: const Text('Start Quiz'))
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. THE QUIZ ENGINE (Timer & Logic)
// ==========================================
class QuizScreen extends StatefulWidget {
  final String name;
  final String subject;
  const QuizScreen({super.key, required this.name, required this.subject});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    // Load exactly 5 questions if available
    questions = Database.questions[widget.subject]!.take(5).toList();
    startTimer();
  }

  void startTimer() {
    timeLeft = 30;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          nextQuestion(isTimeout: true);
        }
      });
    });
  }

  void nextQuestion({bool isTimeout = false, int? selectedOption}) {
    if (!isTimeout && selectedOption == questions[currentQuestionIndex]['ans']) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        startTimer();
      });
    } else {
      timer?.cancel();
      finishQuiz();
    }
  }

  void finishQuiz() {
    String status = score >= 3 ? 'PASS' : 'FAIL';
    Database.results.add({
      'name': widget.name,
      'subject': widget.subject,
      'score': score,
      'status': status
    });

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ResultScreen(score: score, status: status, total: questions.length)
    ));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const Scaffold(body: Center(child: Text('No questions available.')));
    
    var q = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject} Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Time Left: $timeLeft s', style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Question ${currentQuestionIndex + 1}/${questions.length}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(q['q'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ...List.generate(4, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: () => nextQuestion(selectedOption: index),
                child: Text(q['options'][index]),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. RESULT SCREEN
// ==========================================
class ResultScreen extends StatelessWidget {
  final int score;
  final String status;
  final int total;
  const ResultScreen({super.key, required this.score, required this.status, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: status == 'PASS' ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            Text('Score: $score / $total', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
              child: const Text('Logout / Go Home'),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. ADMIN DASHBOARD
// ==========================================
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  // Form Controllers for Adding Question
  String selectedSub = 'Physics';
  final qCtrl = TextEditingController();
  final opt1Ctrl = TextEditingController();
  final opt2Ctrl = TextEditingController();
  final opt3Ctrl = TextEditingController();
  final opt4Ctrl = TextEditingController();
  int correctIdx = 0;

  void addQuestion() {
    if (qCtrl.text.isEmpty || opt1Ctrl.text.isEmpty || opt2Ctrl.text.isEmpty) return;
    
    Database.questions[selectedSub]?.add({
      'q': qCtrl.text,
      'options': [opt1Ctrl.text, opt2Ctrl.text, opt3Ctrl.text, opt4Ctrl.text],
      'ans': correctIdx
    });
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question Added!')));
    qCtrl.clear(); opt1Ctrl.clear(); opt2Ctrl.clear(); opt3Ctrl.clear(); opt4Ctrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
          )
        ],
      ),
      body: _currentIndex == 0 ? _buildResultsTab() : _buildAddQuestionTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Student Results'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Questions'),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (Database.results.isEmpty) return const Center(child: Text('No student results yet.'));
    return ListView.builder(
      itemCount: Database.results.length,
      itemBuilder: (context, index) {
        var r = Database.results[index];
        return Card(
          child: ListTile(
            title: Text('${r['name']} - ${r['subject']}'),
            subtitle: Text('Score: ${r['score']}'),
            trailing: Text(r['status'], style: TextStyle(color: r['status'] == 'PASS' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildAddQuestionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedSub,
            items: Database.questions.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => selectedSub = v!),
          ),
          TextField(controller: qCtrl, decoration: const InputDecoration(labelText: 'Question Text')),
          TextField(controller: opt1Ctrl, decoration: const InputDecoration(labelText: 'Option 1')),
          TextField(controller: opt2Ctrl, decoration: const InputDecoration(labelText: 'Option 2')),
          TextField(controller: opt3Ctrl, decoration: const InputDecoration(labelText: 'Option 3')),
          TextField(controller: opt4Ctrl, decoration: const InputDecoration(labelText: 'Option 4')),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: correctIdx,
            items: const [
              DropdownMenuItem(value: 0, child: Text('Option 1 is Correct')),
              DropdownMenuItem(value: 1, child: Text('Option 2 is Correct')),
              DropdownMenuItem(value: 2, child: Text('Option 3 is Correct')),
              DropdownMenuItem(value: 3, child: Text('Option 4 is Correct')),
            ],
            onChanged: (v) => setState(() => correctIdx = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: addQuestion, child: const Text('Add Question to Database'))
        ],
      ),
    );
  }
}