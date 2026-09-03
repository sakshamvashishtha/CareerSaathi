import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CareerRoadmapScreen extends StatefulWidget {
  const CareerRoadmapScreen({super.key});

  @override
  State<CareerRoadmapScreen> createState() => _CareerRoadmapScreenState();
}

class _CareerRoadmapScreenState extends State<CareerRoadmapScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  Map<String, dynamic> profile = {};
  Map<String, double> scores = {};

  int selectedPhase = 0;

  final List<String> phaseNames = [
    'Foundation',
    'Skill Building',
    'Projects',
    'Career Ready',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadRoadmapData();
  }

  Future<void> _loadRoadmapData() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Your session expired. Please login again.';
      });
      return;
    }

    try {
      final profileFuture =
          _firestore.collection('students').doc(user.uid).get();

      final assessmentFuture = _firestore
          .collection('students')
          .doc(user.uid)
          .collection('assessment')
          .doc('latest')
          .get();

      final results = await Future.wait([
        profileFuture,
        assessmentFuture,
      ]);

      final profileDoc =
          results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final assessmentDoc =
          results[1] as DocumentSnapshot<Map<String, dynamic>>;

      final loadedScores = <String, double>{};

      if (assessmentDoc.exists && assessmentDoc.data() != null) {
        final rawScores = Map<String, dynamic>.from(
          assessmentDoc.data()!['scores'] ?? {},
        );

        rawScores.forEach((key, value) {
          if (value is num) {
            loadedScores[key] = value.toDouble();
          }
        });
      }

      if (!mounted) return;

      setState(() {
        profile = profileDoc.data() ?? {};
        scores = loadedScores;
        isLoading = false;
      });

      _animationController.forward();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to build your roadmap right now.';
      });
    }
  }

  String get goal {
    final value = (profile['careerGoal'] ?? '').toString().trim();
    return value.isEmpty ? 'Your Career Goal' : value;
  }

  List<String> get interests =>
      List<String>.from(profile['interests'] ?? []);

  List<String> get skills =>
      List<String>.from(profile['skills'] ?? []);

  List<String> get strengths =>
      List<String>.from(profile['strengths'] ?? []);

  List<String> get topSkills {
    final entries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final names = <String, String>{
      'problemSolving': 'Problem Solving',
      'analyticalThinking': 'Analytical Thinking',
      'decisionMaking': 'Decision Making',
      'leadership': 'Leadership',
      'communication': 'Communication',
      'teamwork': 'Teamwork',
      'empathy': 'Empathy',
      'creativity': 'Creativity',
      'resourcefulness': 'Resourcefulness',
      'innovation': 'Innovation',
      'research': 'Research',
      'learningAbility': 'Learning Ability',
    };

    return entries
        .take(4)
        .map((e) => names[e.key] ?? e.key)
        .toList();
  }

  List<String> get recommendedSkills {
    final result = <String>[];

    void add(String value) {
      if (!result.contains(value)) result.add(value);
    }

    for (final interest in interests) {
      switch (interest) {
        case 'Technology':
        case 'Programming':
          add('Data Structures & Algorithms');
          add('Git & GitHub');
          add('System Design Basics');
          break;

        case 'Artificial Intelligence':
        case 'AI/ML':
          add('Machine Learning');
          add('Python for AI');
          add('Model Evaluation');
          break;

        case 'Cyber Security':
          add('Networking Fundamentals');
          add('Linux');
          add('Security Fundamentals');
          break;

        case 'Data Science':
          add('Statistics');
          add('SQL');
          add('Data Visualization');
          break;

        case 'Healthcare':
        case 'Pharmacy':
        case 'Biotechnology':
          add('Research Methodology');
          add('Scientific Documentation');
          add('Data Analysis');
          break;

        case 'Business':
        case 'Entrepreneurship':
          add('Business Analysis');
          add('Financial Basics');
          add('Presentation Skills');
          break;

        case 'Design':
          add('UX Research');
          add('Design Systems');
          add('Portfolio Building');
          break;

        default:
          break;
      }
    }

    if (result.isEmpty) {
      add('Communication');
      add('Problem Solving');
      add('Digital Skills');
    }

    return result.take(5).toList();
  }

  List<Map<String, dynamic>> get phases {
    final firstSkills = recommendedSkills.take(3).toList();

    return [
      {
        'duration': 'Week 1–2',
        'title': 'Build Your Foundation',
        'icon': Icons.foundation_rounded,
        'tasks': [
          'Understand the fundamentals of your target career.',
          'Create a consistent learning routine.',
          'Strengthen your weakest important skill.',
        ],
      },
      {
        'duration': 'Week 3–6',
        'title': 'Build Job-Ready Skills',
        'icon': Icons.school_rounded,
        'tasks': [
          if (firstSkills.isNotEmpty)
            'Learn ${firstSkills.join(', ')}.',
          'Practice through small real-world exercises.',
          'Track your progress every week.',
        ],
      },
      {
        'duration': 'Week 7–10',
        'title': 'Build Proof of Work',
        'icon': Icons.code_rounded,
        'tasks': [
          'Build 1–2 practical projects related to your goal.',
          'Document your work and key decisions.',
          'Publish your strongest project in a portfolio.',
        ],
      },
      {
        'duration': 'Week 11–12',
        'title': 'Become Career Ready',
        'icon': Icons.rocket_launch_rounded,
        'tasks': [
          'Create or improve your resume.',
          'Prepare role-specific interview questions.',
          'Start applying for internships, projects or entry-level roles.',
        ],
      },
    ];
  }

  Future<void> _saveRoadmap() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      final roadmap = {
        'goal': goal,
        'generatedFromProfile': true,
        'phases': phases
            .map(
              (phase) => {
                'duration': phase['duration'],
                'title': phase['title'],
                'tasks': List<String>.from(phase['tasks']),
              },
            )
            .toList(),
        'recommendedSkills': recommendedSkills,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'version': 1,
      };

      await _firestore
          .collection('students')
          .doc(user.uid)
          .collection('roadmap')
          .doc('current')
          .set(roadmap, SetOptions(merge: true));

      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Career roadmap saved successfully 🚀'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save roadmap. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _phaseCard(Map<String, dynamic> phase, int index) {
    final selected = selectedPhase == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPhase = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0EEFF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF6C63FF)
                : const Color(0xFFE2E3EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFFEDEBFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                phase['icon'] as IconData,
                color: selected ? Colors.white : const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase['duration'].toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    phase['title'].toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF30313D),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: selected ? 24 : 15,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedPhaseDetails() {
    final phase = phases[selectedPhase];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(selectedPhase),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE2E3EA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Action plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF171923),
              ),
            ),
            const SizedBox(height: 13),
            ...List<String>.from(phase['tasks']).map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 19,
                      color: Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        task,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Color(0xFF50515C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5148C9),
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

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FC),
          elevation: 0,
          title: const Text(
            'Career Roadmap',
            style: TextStyle(
              color: Color(0xFF171923),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.route_rounded,
                  size: 60,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF50515C),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _loadRoadmapData,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Career Roadmap',
          style: TextStyle(
            color: Color(0xFF171923),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF171923),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF8B7FFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.route_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'Your personalized path 🚀',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          goal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'A practical 12-week plan built from your profile and assessment.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Your roadmap',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF171923),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Tap a phase to see what you should do.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...phases.asMap().entries.map(
                    (entry) => _phaseCard(entry.value, entry.key),
                  ),

                  _selectedPhaseDetails(),

                  const SizedBox(height: 26),

                  const Text(
                    'Priority skills',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF171923),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Skills worth focusing on next.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0xFFE2E3EA)),
                    ),
                    child: Wrap(
                      children: recommendedSkills.map(_chip).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (topSkills.isNotEmpty) ...[
                    const Text(
                      'Use your strengths',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171923),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'These assessment strengths can support your roadmap.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border:
                            Border.all(color: const Color(0xFFE2E3EA)),
                      ),
                      child: Wrap(
                        children: topSkills.map(_chip).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFF),
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: const Color(0xFFE0DCFF),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your roadmap is a starting plan. As you complete tasks and improve your profile, we can make the recommendations more personalized.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Color(0xFF565665),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _saveRoadmap,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_done_rounded),
                      label: Text(
                        isSaving ? 'Saving...' : 'Save My Roadmap',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFB9B5F4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
