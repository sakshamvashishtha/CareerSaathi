import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final Set<String> careerPriorities = {};

  String? workStyle;
  String? careerDirection;
  String? locationPreference;
  String? higherStudies;

  final List<Map<String, dynamic>> priorities = [
    {
      'title': 'High earning',
      'subtitle': 'I want strong earning potential',
      'icon': Icons.currency_rupee_rounded,
    },
    {
      'title': 'Job security',
      'subtitle': 'Stability is important to me',
      'icon': Icons.security_rounded,
    },
    {
      'title': 'Fast career growth',
      'subtitle': 'I want opportunities to grow quickly',
      'icon': Icons.trending_up_rounded,
    },
    {
      'title': 'Work-life balance',
      'subtitle': 'I value personal time and flexibility',
      'icon': Icons.balance_rounded,
    },
    {
      'title': 'Innovation',
      'subtitle': 'I want to build and explore new ideas',
      'icon': Icons.lightbulb_outline_rounded,
    },
    {
      'title': 'Helping people',
      'subtitle': 'I want my work to create social impact',
      'icon': Icons.volunteer_activism_outlined,
    },
  ];

  final List<String> workStyles = [
    'Mostly independent',
    'Small team',
    'Large team',
    'Mix of individual and team work',
    'No preference',
  ];

  final List<String> careerDirections = [
    'Private sector / Job',
    'Government career',
    'Entrepreneurship',
    'Research / Academia',
    'Freelancing',
    'Open to all',
  ];

  final List<String> locations = [
    'My hometown',
    'Anywhere in India',
    'Metro cities',
    'I prefer a specific city',
    'Open to other locations',
  ];

  final List<String> studyOptions = [
    'Yes, I am interested',
    'Maybe',
    'No, I want to start working',
    'Not sure yet',
  ];

  void togglePriority(String priority) {
    setState(() {
      if (careerPriorities.contains(priority)) {
        careerPriorities.remove(priority);
      } else {
        if (careerPriorities.length < 3) {
          careerPriorities.add(priority);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 3 priorities'),
            ),
          );
        }
      }
    });
  }

  void continueToFinancialAssessment() {
    if (careerPriorities.isEmpty ||
        workStyle == null ||
        careerDirection == null ||
        locationPreference == null ||
        higherStudies == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all preferences'),
        ),
      );
      return;
    }

    // Later this will navigate to FinancialScreen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Career Preferences',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Progress
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'What matters to you? 🎯',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF171923),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your preferences help us find careers and courses that fit your goals.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Choose your top 3 career priorities',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF171923),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Select up to three',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              ...priorities.map((item) {
                final String title = item['title'];
                final String subtitle = item['subtitle'];
                final IconData icon = item['icon'];

                final bool selected =
                    careerPriorities.contains(title);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => togglePriority(title),
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFF0EEFF)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFFE1E3EA),
                          width: selected ? 1.7 : 1,
                        ),
                      ),
                      child: Row(
                        children: [

                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF6C63FF)
                                  : const Color(0xFFF0F0F5),
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: Icon(
                              icon,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF6C63FF),
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: const Color(
                                      0xFF30313D,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: selected
                                ? const Color(0xFF6C63FF)
                                : const Color(0xFFBFC1CA),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              _sectionTitle(
                'Preferred work style',
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                value: workStyle,
                hint: 'How do you prefer to work?',
                icon: Icons.work_outline_rounded,
                items: workStyles,
                onChanged: (value) {
                  setState(() {
                    workStyle = value;
                  });
                },
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'Career direction',
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                value: careerDirection,
                hint: 'What career path interests you?',
                icon: Icons.route_outlined,
                items: careerDirections,
                onChanged: (value) {
                  setState(() {
                    careerDirection = value;
                  });
                },
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'Location preference',
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                value: locationPreference,
                hint: 'Where would you prefer to study/work?',
                icon: Icons.location_on_outlined,
                items: locations,
                onChanged: (value) {
                  setState(() {
                    locationPreference = value;
                  });
                },
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'Higher studies',
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                value: higherStudies,
                hint: 'Are you open to higher studies?',
                icon: Icons.school_outlined,
                items: studyOptions,
                onChanged: (value) {
                  setState(() {
                    higherStudies = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      continueToFinancialAssessment,
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
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Step 3 of your career assessment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF171923),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6C63FF),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EA),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 1.5,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}