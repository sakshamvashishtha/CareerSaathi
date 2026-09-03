import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final AnimationController _animationController;

  bool isLoading = true;
  bool isSaving = false;

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Learn one career skill',
      'subtitle': 'Spend 30 minutes learning something useful.',
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Practice your core skill',
      'subtitle': 'Complete one small practical exercise.',
      'icon': Icons.code_rounded,
    },
    {
      'title': 'Research one career option',
      'subtitle': 'Explore a role, company, or career path.',
      'icon': Icons.search_rounded,
    },
    {
      'title': 'Build something small',
      'subtitle': 'Create or improve one portfolio item.',
      'icon': Icons.build_rounded,
    },
  ];

  List<bool> completed = [];

  @override
  void initState() {
    super.initState();
    completed = List<bool>.filled(tasks.length, false);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _loadProgress();
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DocumentReference<Map<String, dynamic>> get _progressRef {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('students')
        .doc(uid)
        .collection('dailyTasks')
        .doc(_todayKey);
  }

  Future<void> _loadProgress() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await _progressRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final saved = List<dynamic>.from(
          snapshot.data()!['completed'] ?? [],
        );

        for (int i = 0; i < completed.length && i < saved.length; i++) {
          completed[i] = saved[i] == true;
        }
      }
    } catch (_) {
      // Keep the local state usable even if Firestore is temporarily unavailable.
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _toggleTask(int index) async {
    if (isSaving) return;

    setState(() {
      completed[index] = !completed[index];
    });

    try {
      await _progressRef.set({
        'completed': completed,
        'completedCount': completed.where((e) => e).length,
        'totalTasks': tasks.length,
        'date': _todayKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        completed[index] = !completed[index];
      });

      _message('Could not save progress. Check internet.');
    }
  }

  double get progress {
    if (tasks.isEmpty) return 0;
    return completed.where((e) => e).length / tasks.length;
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C63FF),
          ),
        ),
      );
    }

    final done = completed.where((e) => e).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Daily Tasks',
          style: TextStyle(
            color: Color(0xFF171923),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF171923),
        ),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(done),
              const SizedBox(height: 28),

              const Text(
                "Today's goals",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171923),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Small actions today build your career tomorrow.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 18),

              ...List.generate(tasks.length, (index) {
                final task = tasks[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.96, end: 1),
                  duration: Duration(milliseconds: 350 + index * 90),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: _buildTaskCard(
                    index: index,
                    title: task['title'] as String,
                    subtitle: task['subtitle'] as String,
                    icon: task['icon'] as IconData,
                  ),
                );
              }),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE1DCFF),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF6C63FF),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'CareerSaathi tip: Consistency matters more than doing everything at once.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Color(0xFF454752),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(int done) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 25,
              ),
              SizedBox(width: 8),
              Text(
                'Keep your momentum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '$done of ${tasks.length} tasks completed',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}% complete',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isDone = completed[index];

    return GestureDetector(
      onTap: () => _toggleTask(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0EDFF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDone
                ? const Color(0xFF6C63FF)
                : const Color(0xFFE1E3EA),
            width: isDone ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFFF0EDFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                color: isDone
                    ? Colors.white
                    : const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF171923),
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isDone
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFFBFC1CA),
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
