import 'package:flutter/material.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  int currentChallenge = 0;

  final List<Map<String, dynamic>> challenges = [
    {
      'category': 'Problem Solving',
      'icon': Icons.extension_rounded,
      'title': 'A project suddenly stops working',
      'scenario':
          'Your team has an important project deadline tomorrow. Suddenly, a major feature stops working. What would you do first?',
      'options': [
        {
          'text': 'Start changing different parts until something works',
          'scores': {
            'problemSolving': 2,
            'analyticalThinking': 1,
            'decisionMaking': 1,
          }
        },
        {
          'text': 'Ask someone else to fix the entire problem',
          'scores': {
            'problemSolving': 1,
            'teamwork': 2,
          }
        },
        {
          'text':
              'Identify the cause and break the problem into smaller parts',
          'scores': {
            'problemSolving': 5,
            'analyticalThinking': 5,
            'decisionMaking': 4,
          }
        },
        {
          'text': 'Ignore it and continue working on other tasks',
          'scores': {
            'problemSolving': 0,
            'decisionMaking': 1,
          }
        },
      ],
    },
    {
      'category': 'Leadership',
      'icon': Icons.groups_rounded,
      'title': 'Your team is confused',
      'scenario':
          'You are working on a group project. There are only two hours left, but everyone is doing different things and the team has no clear direction.',
      'options': [
        {
          'text': 'Wait for someone else to take responsibility',
          'scores': {
            'leadership': 1,
            'decisionMaking': 1,
          }
        },
        {
          'text': 'Take control, divide the tasks and set priorities',
          'scores': {
            'leadership': 5,
            'decisionMaking': 5,
            'teamwork': 4,
          }
        },
        {
          'text': 'Tell everyone to work harder',
          'scores': {
            'leadership': 2,
            'communication': 2,
          }
        },
        {
          'text': 'Leave the team and complete your own part',
          'scores': {
            'leadership': 0,
            'teamwork': 1,
          }
        },
      ],
    },
    {
      'category': 'Communication',
      'icon': Icons.forum_rounded,
      'title': 'A teammate made a mistake',
      'scenario':
          'A teammate made a mistake that may affect the entire project. How would you handle the situation?',
      'options': [
        {
          'text': 'Point out their mistake in front of everyone',
          'scores': {
            'communication': 1,
            'teamwork': 1,
            'empathy': 0,
          }
        },
        {
          'text': 'Ignore the mistake',
          'scores': {
            'communication': 1,
            'decisionMaking': 1,
          }
        },
        {
          'text':
              'Talk privately, understand what happened and work together on a solution',
          'scores': {
            'communication': 5,
            'teamwork': 5,
            'empathy': 5,
          }
        },
        {
          'text': 'Immediately report them to the team leader',
          'scores': {
            'communication': 2,
            'decisionMaking': 2,
          }
        },
      ],
    },
    {
      'category': 'Creativity',
      'icon': Icons.lightbulb_rounded,
      'title': 'Promote an event with limited money',
      'scenario':
          'Your college gives you a small budget to promote an event. You need to reach as many students as possible.',
      'options': [
        {
          'text': 'Use the entire budget on printed posters',
          'scores': {
            'creativity': 2,
            'resourcefulness': 2,
          }
        },
        {
          'text': 'Cancel the promotion because the budget is too small',
          'scores': {
            'creativity': 0,
            'resourcefulness': 0,
          }
        },
        {
          'text':
              'Create a social media campaign using student-generated content and free platforms',
          'scores': {
            'creativity': 5,
            'resourcefulness': 5,
            'innovation': 5,
          }
        },
        {
          'text': 'Ask for a bigger budget before doing anything',
          'scores': {
            'creativity': 1,
            'resourcefulness': 1,
          }
        },
      ],
    },
    {
      'category': 'Research & Curiosity',
      'icon': Icons.search_rounded,
      'title': 'You encounter something you do not understand',
      'scenario':
          'You are given a task involving a topic you have never studied before. What is your first approach?',
      'options': [
        {
          'text': 'Avoid the task',
          'scores': {
            'research': 0,
            'learningAbility': 0,
          }
        },
        {
          'text': 'Wait until someone teaches you',
          'scores': {
            'research': 1,
            'learningAbility': 2,
          }
        },
        {
          'text':
              'Break the topic into smaller questions and research reliable sources',
          'scores': {
            'research': 5,
            'learningAbility': 5,
            'analyticalThinking': 4,
          }
        },
        {
          'text': 'Search for one quick answer and stop there',
          'scores': {
            'research': 2,
            'learningAbility': 2,
          }
        },
      ],
    },
    {
      'category': 'Decision Making',
      'icon': Icons.alt_route_rounded,
      'title': 'Two choices, limited information',
      'scenario':
          'You need to make an important decision, but you do not have complete information and time is limited.',
      'options': [
        {
          'text': 'Make a random choice quickly',
          'scores': {
            'decisionMaking': 1,
            'analyticalThinking': 0,
          }
        },
        {
          'text': 'Collect the most important available information and compare the risks',
          'scores': {
            'decisionMaking': 5,
            'analyticalThinking': 5,
            'problemSolving': 4,
          }
        },
        {
          'text': 'Never decide until you have perfect information',
          'scores': {
            'decisionMaking': 2,
            'analyticalThinking': 3,
          }
        },
        {
          'text': 'Let someone else decide every time',
          'scores': {
            'decisionMaking': 0,
            'leadership': 0,
          }
        },
      ],
    },
  ];

  final List<int?> selectedAnswers = List.filled(6, null);

  final Map<String, double> skillScores = {
    'problemSolving': 0,
    'analyticalThinking': 0,
    'decisionMaking': 0,
    'leadership': 0,
    'communication': 0,
    'teamwork': 0,
    'empathy': 0,
    'creativity': 0,
    'resourcefulness': 0,
    'innovation': 0,
    'research': 0,
    'learningAbility': 0,
  };

  void selectAnswer(int index) {
    setState(() {
      selectedAnswers[currentChallenge] = index;
    });
  }

  void continueChallenge() {
    final selected = selectedAnswers[currentChallenge];

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer'),
        ),
      );
      return;
    }

    if (currentChallenge < challenges.length - 1) {
      setState(() {
        currentChallenge++;
      });
    } else {
      calculateFinalScores();
    }
  }

  void calculateFinalScores() {
    // Reset scores before calculation.
    skillScores.updateAll((key, value) => 0);

    for (int i = 0; i < challenges.length; i++) {
      final answerIndex = selectedAnswers[i];

      if (answerIndex == null) continue;

      final option = challenges[i]['options'][answerIndex];

      final Map<String, dynamic> scores = option['scores'];

      scores.forEach((skill, score) {
        skillScores[skill] =
            (skillScores[skill] ?? 0) + (score as num).toDouble();
      });
    }

    showSkillEvidence();
  }

  void showSkillEvidence() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Skill Evidence Ready 🎯',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your responses have been analysed. Your personalized skill profile will be used for career matching.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Later:
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => const ResultScreen(),
                //   ),
                // );
              },
              child: const Text('View My Profile'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = challenges[currentChallenge];

    final String category = challenge['category'];
    final IconData icon = challenge['icon'];
    final String title = challenge['title'];
    final String scenario = challenge['scenario'];

    final List<Map<String, dynamic>> options =
        List<Map<String, dynamic>>.from(
      challenge['options'],
    );

    final double progress =
        (currentChallenge + 1) / challenges.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Skill Challenge',
          style: TextStyle(
            color: Color(0xFF171923),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF171923),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor:
                          const Color(0xFFE3E4EC),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        'Challenge ${currentChallenge + 1} of ${challenges.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  25,
                  24,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // Challenge icon
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEBFF),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF6C63FF),
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171923),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFE1E3EA),
                        ),
                      ),
                      child: Text(
                        scenario,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF454752),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'What would you do?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171923),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...List.generate(
                      options.length,
                      (index) {
                        final option =
                            options[index]['text'] as String;

                        final bool isSelected =
                            selectedAnswers[currentChallenge] ==
                                index;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () =>
                                selectAnswer(index),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              padding:
                                  const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0EEFF)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(
                                          0xFF6C63FF,
                                        )
                                      : const Color(
                                          0xFFE1E3EA,
                                        ),
                                  width:
                                      isSelected ? 1.7 : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(
                                              0xFF6C63FF,
                                            )
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(
                                                0xFF6C63FF,
                                              )
                                            : const Color(
                                                0xFFBFC1CA,
                                              ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),

                                  const SizedBox(width: 13),

                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: const Color(
                                          0xFF30313D,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: continueChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      Text(
                        currentChallenge ==
                                challenges.length - 1
                            ? 'Analyse My Skills'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Icon(
                        currentChallenge ==
                                challenges.length - 1
                            ? Icons.auto_awesome_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}