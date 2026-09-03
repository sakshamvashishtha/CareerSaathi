import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'assessment_result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> questions = [
    {
      'category': 'Problem Solving',
      'icon': Icons.psychology_rounded,
      'question': 'A project suddenly stops working. What do you do?',
      'options': [
        'Try random changes until it works',
        'Ask someone else to fix everything',
        'Find the root cause and break the problem into smaller parts',
        'Ignore it and continue another task',
      ],
      'scores': [
        {'problemSolving': 2},
        {'teamwork': 2},
        {'problemSolving': 5, 'analyticalThinking': 5, 'decisionMaking': 4},
        {'problemSolving': 0},
      ],
    },
    {
      'category': 'Leadership',
      'icon': Icons.groups_rounded,
      'question': 'Your team has no clear direction before a deadline.',
      'options': [
        'Wait for someone else to lead',
        'Divide tasks and set clear priorities',
        'Tell everyone to work harder',
        'Complete only your own work',
      ],
      'scores': [
        {'leadership': 1},
        {'leadership': 5, 'decisionMaking': 5, 'teamwork': 4},
        {'leadership': 2, 'communication': 2},
        {'teamwork': 1},
      ],
    },
    {
      'category': 'Communication',
      'icon': Icons.forum_rounded,
      'question': 'A teammate makes a mistake affecting the project.',
      'options': [
        'Point it out publicly',
        'Ignore it',
        'Talk privately and work together on a solution',
        'Immediately blame them to the leader',
      ],
      'scores': [
        {'communication': 1},
        {'decisionMaking': 1},
        {'communication': 5, 'teamwork': 5, 'empathy': 5},
        {'communication': 1},
      ],
    },
    {
      'category': 'Creativity',
      'icon': Icons.lightbulb_rounded,
      'question': 'You have very little money to promote a college event.',
      'options': [
        'Spend everything on posters',
        'Cancel the promotion',
        'Use free platforms and student-generated content',
        'Wait for a larger budget',
      ],
      'scores': [
        {'creativity': 2},
        {'creativity': 0},
        {'creativity': 5, 'resourcefulness': 5, 'innovation': 5},
        {'resourcefulness': 1},
      ],
    },
    {
      'category': 'Learning',
      'icon': Icons.menu_book_rounded,
      'question': 'You receive a task about a topic you have never studied.',
      'options': [
        'Avoid the task',
        'Wait for someone to teach you',
        'Break it into questions and research reliable sources',
        'Find one quick answer and stop',
      ],
      'scores': [
        {'learningAbility': 0},
        {'learningAbility': 2},
        {'research': 5, 'learningAbility': 5, 'analyticalThinking': 4},
        {'research': 2},
      ],
    },
    {
      'category': 'Decision Making',
      'icon': Icons.alt_route_rounded,
      'question': 'You must make an important decision with limited information.',
      'options': [
        'Choose randomly',
        'Collect important information and compare risks',
        'Wait until you know everything',
        'Let someone else decide',
      ],
      'scores': [
        {'decisionMaking': 1},
        {'decisionMaking': 5, 'analyticalThinking': 5, 'problemSolving': 4},
        {'decisionMaking': 2},
        {'decisionMaking': 0},
      ],
    },
    {
      'category': 'Teamwork',
      'icon': Icons.handshake_rounded,
      'question': 'A team member is struggling with their task.',
      'options': [
        'Ignore them',
        'Do their entire task yourself',
        'Understand the issue and help them move forward',
        'Tell the leader they are slow',
      ],
      'scores': [
        {'teamwork': 0},
        {'teamwork': 2},
        {'teamwork': 5, 'communication': 4, 'empathy': 5},
        {'communication': 1},
      ],
    },
    {
      'category': 'Adaptability',
      'icon': Icons.change_circle_rounded,
      'question': 'Your original project plan suddenly becomes impossible.',
      'options': [
        'Give up',
        'Keep following the old plan',
        'Understand the change and create a new practical plan',
        'Wait for someone else',
      ],
      'scores': [
        {'adaptability': 0},
        {'adaptability': 1},
        {'adaptability': 5, 'problemSolving': 4, 'decisionMaking': 4},
        {'adaptability': 1},
      ],
    },
  ];

  late final List<int?> answers;
  late final AnimationController animationController;
  late final Animation<double> fadeAnimation;

  int currentQuestion = 0;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    answers = List<int?>.filled(questions.length, null);

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void selectAnswer(int index) {
    if (isSubmitting) return;
    setState(() => answers[currentQuestion] = index);
  }

  Future<void> nextQuestion() async {
    if (answers[currentQuestion] == null) {
      _message('Please select an answer first.', error: true);
      return;
    }

    if (currentQuestion == questions.length - 1) {
      await submitAssessment();
      return;
    }

    await animationController.reverse();
    if (!mounted) return;

    setState(() => currentQuestion++);
    animationController.forward();
  }

  Future<void> previousQuestion() async {
    if (currentQuestion == 0 || isSubmitting) return;

    await animationController.reverse();
    if (!mounted) return;

    setState(() => currentQuestion--);
    animationController.forward();
  }

  Map<String, int> calculateScores() {
    final scores = <String, int>{};

    for (int i = 0; i < questions.length; i++) {
      final answer = answers[i];
      if (answer == null) continue;

      final scoreMap =
          questions[i]['scores'][answer] as Map<String, dynamic>;

      scoreMap.forEach((skill, value) {
        scores[skill] = (scores[skill] ?? 0) + (value as num).toInt();
      });
    }

    return scores;
  }

  Future<void> submitAssessment() async {
    if (isSubmitting) return;

    final user = _auth.currentUser;
    if (user == null) {
      _message('Your session expired. Please login again.', error: true);
      return;
    }

    if (answers.any((answer) => answer == null)) {
      _message('Please answer all questions.', error: true);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final scores = calculateScores();
      final answerData = <String, dynamic>{};

      for (int i = 0; i < answers.length; i++) {
        answerData['q${i + 1}'] = answers[i];
      }

      await _firestore
          .collection('students')
          .doc(user.uid)
          .collection('assessment')
          .doc('latest')
          .set({
        'answers': answerData,
        'scores': scores,
        'totalQuestions': questions.length,
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
        'version': 1,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => isSubmitting = false);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFF6C63FF)),
              SizedBox(width: 10),
              Expanded(child: Text('Assessment Complete')),
            ],
          ),
          content: const Text(
            'Great job! Your responses have been analysed successfully. Your career profile is ready.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('View Results'),
            ),
          ],
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      _message(e.message ?? 'Unable to save assessment.', error: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      _message('Something went wrong. Please try again.', error: true);
    }
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              error ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Widget _buildQuestionCard() {
    final question = questions[currentQuestion];
    final options = List<String>.from(question['options']);
    final selected = answers[currentQuestion];

    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              question['icon'] as IconData,
              size: 31,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            question['category'],
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171923),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Choose the response that best describes you.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          ...List.generate(options.length, (index) {
            final isSelected = selected == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => selectAnswer(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF0EEFF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFFE1E3EA),
                      width: isSelected ? 1.7 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : const Color(0xFFBFC1CA),
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                size: 17, color: Colors.white)
                            : Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF777985),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: const Color(0xFF30313D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentQuestion + 1) / questions.length;
    final isLast = currentQuestion == questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Career Assessment',
          style: TextStyle(
            color: Color(0xFF171923),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF171923)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 8,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestion + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${questions.length} total',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE3E4EC),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: _buildQuestionCard(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentQuestion > 0) ...[
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: OutlinedButton(
                        onPressed:
                            isSubmitting ? null : previousQuestion,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE1E3EA),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF30313D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting ? null : nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFFB9B5F4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLast
                                        ? 'Analyse My Career'
                                        : 'Continue',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Icon(
                                    isLast
                                        ? Icons.auto_awesome_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
