import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'career_roadmap_screen.dart';

class AssessmentResultScreen extends StatefulWidget {
  const AssessmentResultScreen({super.key});

  @override
  State<AssessmentResultScreen> createState() =>
      _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool isLoading = true;
  String? errorMessage;

  Map<String, double> scores = {};
  Map<String, dynamic> profile = {};

  final Map<String, String> skillNames = {
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
    'adaptability': 'Adaptability',
  };

  final Map<String, IconData> skillIcons = {
    'problemSolving': Icons.psychology_rounded,
    'analyticalThinking': Icons.analytics_rounded,
    'decisionMaking': Icons.alt_route_rounded,
    'leadership': Icons.groups_rounded,
    'communication': Icons.forum_rounded,
    'teamwork': Icons.handshake_rounded,
    'empathy': Icons.favorite_outline_rounded,
    'creativity': Icons.lightbulb_rounded,
    'resourcefulness': Icons.build_rounded,
    'innovation': Icons.auto_awesome_rounded,
    'research': Icons.search_rounded,
    'learningAbility': Icons.menu_book_rounded,
    'adaptability': Icons.change_circle_rounded,
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadResult();
  }

  Future<void> _loadResult() async {
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
      final resultFuture = _firestore
          .collection('students')
          .doc(user.uid)
          .collection('assessment')
          .doc('latest')
          .get();

      final profileFuture =
          _firestore.collection('students').doc(user.uid).get();

      final results = await Future.wait([
        resultFuture,
        profileFuture,
      ]);

      final resultDoc =
          results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final profileDoc =
          results[1] as DocumentSnapshot<Map<String, dynamic>>;

      if (!resultDoc.exists || resultDoc.data() == null) {
        throw Exception('Assessment result not found.');
      }

      final data = resultDoc.data()!;
      final rawScores = Map<String, dynamic>.from(
        data['scores'] ?? {},
      );

      final loadedScores = <String, double>{};

      rawScores.forEach((key, value) {
        if (value is num) {
          loadedScores[key] = value.toDouble();
        }
      });

      if (!mounted) return;

      setState(() {
        scores = loadedScores;
        profile = profileDoc.data() ?? {};
        isLoading = false;
      });

      _controller.forward();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load your assessment. Please complete the assessment first.';
      });
    }
  }

  List<MapEntry<String, double>> get sortedSkills {
    final list = scores.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  double _maxScore(String skill) {
    // Current assessment can give a skill up to 15 in some combinations.
    // We cap the visual percentage so the UI remains stable.
    const max = 15.0;
    final value = scores[skill] ?? 0;
    return (value / max).clamp(0.0, 1.0);
  }

  String get topSkill {
    if (sortedSkills.isEmpty) return 'Your strongest skills';
    return skillNames[sortedSkills.first.key] ?? sortedSkills.first.key;
  }

  List<String> get careerMatches {
    final interests = List<String>.from(profile['interests'] ?? []);
    final goal = (profile['careerGoal'] ?? '').toString().toLowerCase();

    final candidates = <String>[];

    if (interests.any((x) =>
        ['Technology', 'Programming', 'AI/ML', 'Artificial Intelligence']
            .contains(x))) {
      candidates.addAll([
        'Software Developer',
        'AI / ML Engineer',
        'Product Technologist',
      ]);
    }

    if (interests.any((x) =>
        ['Cyber Security'].contains(x))) {
      candidates.add('Cyber Security Analyst');
    }

    if (interests.any((x) =>
        ['Healthcare', 'Pharmacy', 'Biotechnology'].contains(x))) {
      candidates.addAll([
        'Healthcare / Pharmacy Professional',
        'Clinical Research Associate',
        'Biotechnology Researcher',
      ]);
    }

    if (interests.any((x) =>
        ['Business', 'Finance', 'Entrepreneurship'].contains(x))) {
      candidates.addAll([
        'Business Analyst',
        'Entrepreneur',
        'Financial Analyst',
      ]);
    }

    if (interests.any((x) =>
        ['Design', 'Marketing', 'Media'].contains(x))) {
      candidates.addAll([
        'UX / Product Designer',
        'Digital Marketing Specialist',
        'Content Strategist',
      ]);
    }

    if (goal.isNotEmpty) {
      candidates.insert(0, profile['careerGoal'].toString());
    }

    final unique = <String>[];
    for (final item in candidates) {
      if (!unique.contains(item)) unique.add(item);
    }

    if (unique.isEmpty) {
      unique.addAll([
        'Explore technology careers',
        'Explore research careers',
        'Explore business careers',
      ]);
    }

    return unique.take(4).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSkillCard(
    BuildContext context,
    String key,
    double score,
    int index,
  ) {
    final name = skillNames[key] ?? key;
    final icon = skillIcons[key] ?? Icons.auto_awesome_rounded;
    final progress = _maxScore(key);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: Duration(milliseconds: 500 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3E4EC)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEBFF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF6C63FF),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30313D),
                      ),
                    ),
                  ),
                  Text(
                    '${score.round()} pts',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE9E9F1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCareerCard(String career, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3E4EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              career,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF30313D),
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: Colors.grey,
          ),
        ],
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
            'Assessment Results',
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
                  Icons.analytics_outlined,
                  size: 60,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 18),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF454752),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final displayName =
        (profile['name'] ?? 'Student').toString().trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Skill Analysis',
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
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Great work, $displayName! 🎯',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Your assessment shows that $topSkill is one of your strongest areas.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Your strongest skills',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF171923),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Based on the decisions you made during the assessment.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 17),

                  ...sortedSkills
                      .take(6)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildSkillCard(
                          context,
                          entry.value.key,
                          entry.value.value,
                          entry.key,
                        ),
                      ),

                  const SizedBox(height: 20),

                  const Text(
                    'Career directions',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF171923),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'These are starting points, not fixed career decisions.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 17),

                  ...careerMatches
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                            _buildCareerCard(entry.value, entry.key),
                      ),

                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(
                        color: const Color(0xFFE3E4EC),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                        SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            'CareerSaathi will combine your profile, interests, skills and assessment evidence to build a more personalized roadmap.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Color(0xFF5B5C66),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CareerRoadmapScreen(),
    ),
  );
},
                      icon: const Icon(Icons.route_rounded),
                      label: const Text(
                        'Build My Career Roadmap',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
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
