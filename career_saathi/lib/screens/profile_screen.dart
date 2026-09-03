import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/student_profile.dart';
import 'home_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;

  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  // ============================================================
  // FORM DATA
  // ============================================================

  String? selectedEducation;
  String? selectedStream;
  String? selectedGender;
  String? selectedWorkStyle;

  final Set<String> selectedInterests = {};
  final Set<String> selectedSkills = {};
  final Set<String> selectedStrengths = {};

  // ============================================================
  // UI STATE
  // ============================================================

  bool isLoading = true;
  bool isSaving = false;
  bool profileExists = false;

  double completion = 0.0;

  // ============================================================
  // OPTIONS
  // ============================================================

  final List<String> educationOptions = [
    'Class 10',
    'Class 12',
    'Diploma',
    'Undergraduate',
    'Postgraduate',
    'Other',
  ];

  final Map<String, List<String>> streamOptions = {
    'Class 10': [
      'General',
    ],
    'Class 12': [
      'Science',
      'Commerce',
      'Arts/Humanities',
      'Vocational',
    ],
    'Diploma': [
      'Engineering',
      'Computer Science',
      'Pharmacy',
      'Management',
      'Other',
    ],
    'Undergraduate': [
      'Computer Science',
      'Engineering',
      'Pharmacy',
      'Biotechnology',
      'Management',
      'Commerce',
      'Arts',
      'Science',
      'Other',
    ],
    'Postgraduate': [
      'Computer Science',
      'Engineering',
      'Pharmacy',
      'Biotechnology',
      'Management',
      'Commerce',
      'Arts',
      'Science',
      'Other',
    ],
    'Other': [
      'Other',
    ],
  };

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> workStyleOptions = [
    'Work from Office',
    'Remote',
    'Hybrid',
    'Flexible',
    'Not sure yet',
  ];

  final List<String> interestOptions = [
    'Technology',
    'Programming',
    'Cyber Security',
    'Artificial Intelligence',
    'Data Science',
    'Business',
    'Finance',
    'Healthcare',
    'Pharmacy',
    'Biotechnology',
    'Research',
    'Design',
    'Marketing',
    'Teaching',
    'Government',
    'Entrepreneurship',
    'Law',
    'Media',
    'Travel',
  ];

  final List<String> skillOptions = [
    'Python',
    'Java',
    'C++',
    'Flutter',
    'Web Development',
    'SQL',
    'Data Analysis',
    'AI/ML',
    'Cyber Security',
    'Communication',
    'Leadership',
    'Problem Solving',
    'Public Speaking',
    'Research',
    'Writing',
    'Teamwork',
  ];

  final List<String> strengthOptions = [
    'Creative',
    'Analytical',
    'Good Communicator',
    'Quick Learner',
    'Problem Solver',
    'Team Player',
    'Leader',
    'Patient',
    'Disciplined',
    'Hard Working',
    'Adaptable',
    'Detail Oriented',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startRealtimeProfileListener();

    nameController.addListener(_calculateCompletion);
    ageController.addListener(_calculateCompletion);
    cityController.addListener(_calculateCompletion);
    goalController.addListener(_calculateCompletion);
  }

  // ============================================================
  // REAL-TIME FIRESTORE LISTENER
  // ============================================================

  void _startRealtimeProfileListener() {
    final user = currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    _profileSubscription = _firestore
        .collection('students')
        .doc(user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted) return;

        if (snapshot.exists && snapshot.data() != null) {
          _loadProfile(snapshot.data()!);
        }

        setState(() {
          profileExists = snapshot.exists;
          isLoading = false;
        });

        _calculateCompletion();
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        _showMessage(
          'Unable to load profile. Please check your internet.',
          isError: true,
        );
      },
    );
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  void _loadProfile(Map<String, dynamic> data) {
    nameController.text = data['name'] ?? '';
    ageController.text = data['age']?.toString() ?? '';
    cityController.text = data['city'] ?? '';
    goalController.text = data['careerGoal'] ?? '';

    selectedEducation = data['education'];
    selectedStream = data['stream'];
    selectedGender = data['gender'];
    selectedWorkStyle = data['workStyle'];

    selectedInterests
      ..clear()
      ..addAll(
        List<String>.from(
          data['interests'] ?? [],
        ),
      );

    selectedSkills
      ..clear()
      ..addAll(
        List<String>.from(
          data['skills'] ?? [],
        ),
      );

    selectedStrengths
      ..clear()
      ..addAll(
        List<String>.from(
          data['strengths'] ?? [],
        ),
      );

    _calculateCompletion();
  }
  
  

  // ============================================================
  // CALCULATE PROFILE COMPLETION
  // ============================================================

  void _calculateCompletion() {
    int completed = 0;
    const int total = 9;

    if (nameController.text.trim().isNotEmpty) completed++;
    if (ageController.text.trim().isNotEmpty) completed++;
    if (selectedEducation != null) completed++;
    if (selectedStream != null) completed++;
    if (selectedGender != null) completed++;
    if (selectedInterests.isNotEmpty) completed++;
    if (selectedSkills.isNotEmpty) completed++;
    if (selectedStrengths.isNotEmpty) completed++;
    if (goalController.text.trim().isNotEmpty) completed++;

    if (!mounted) return;

    setState(() {
      completion = completed / total;
    });
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    final user = currentUser;

    if (user == null) {
      _showMessage(
        'Please login again.',
        isError: true,
      );
      return;
    }

    if (!_validateProfile()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final profileData = {
        'uid': user.uid,

        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()),

        'education': selectedEducation,
        'stream': selectedStream,
        'gender': selectedGender,

        'city': cityController.text.trim(),

        'interests': selectedInterests.toList(),
        'skills': selectedSkills.toList(),
        'strengths': selectedStrengths.toList(),

        'careerGoal': goalController.text.trim(),

        'workStyle': selectedWorkStyle,

        'profileCompleted': completion >= 0.85,

        'updatedAt': FieldValue.serverTimestamp(),

        // Useful for future AI recommendation engine
        'careerProfileVersion': 1,
      };

      if (!profileExists) {
        profileData['createdAt'] =
            FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('students')
          .doc(user.uid)
          .set(
        profileData,
        SetOptions(merge: true),
      );

      // Update Firebase Auth display name
      if (user.displayName != nameController.text.trim()) {
        await user.updateDisplayName(
          nameController.text.trim(),
        );
      }

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

     _showMessage('Profile saved successfully 🎉');

await Future.delayed(
  const Duration(milliseconds: 500),
);

if (!mounted) return;

Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (_) => const HomeScreen(),
  ),
  (route) => false,
);

      // ======================================================
      // NEXT SCREEN
      // ======================================================
      //
      // Later:
      //
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const HomeScreen(),
      //   ),
      // );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showMessage(
        e.message ?? 'Failed to save profile.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateProfile() {
    if (nameController.text.trim().length < 2) {
      _showMessage(
        'Please enter your full name.',
        isError: true,
      );
      return false;
    }

    final age = int.tryParse(
      ageController.text.trim(),
    );

    if (age == null || age < 13 || age > 100) {
      _showMessage(
        'Please enter a valid age.',
        isError: true,
      );
      return false;
    }

    if (selectedEducation == null) {
      _showMessage(
        'Please select your education level.',
        isError: true,
      );
      return false;
    }

    if (selectedStream == null) {
      _showMessage(
        'Please select your stream.',
        isError: true,
      );
      return false;
    }

    if (selectedInterests.length < 2) {
      _showMessage(
        'Select at least 2 interests.',
        isError: true,
      );
      return false;
    }

    if (selectedSkills.length < 2) {
      _showMessage(
        'Select at least 2 skills.',
        isError: true,
      );
      return false;
    }

    if (selectedStrengths.length < 2) {
      _showMessage(
        'Select at least 2 strengths.',
        isError: true,
      );
      return false;
    }

    if (goalController.text.trim().isEmpty) {
      _showMessage(
        'Tell us about your career goal.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // MULTI SELECT
  // ============================================================

  void _toggleSelection(
    String value,
    Set<String> target,
  ) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });

    _calculateCompletion();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? const Color(0xFFD32F2F)
              : const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // CHIP SECTION
  // ============================================================

  Widget _buildChipSection({
    required String title,
    required String subtitle,
    required List<String> options,
    required Set<String> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171923),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 9,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selected.contains(option);

            return GestureDetector(
              onTap: () {
                _toggleSelection(
                  option,
                  selected,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFE1E3EA),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6C63FF)
                                .withOpacity(.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF30313D),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData icon = Icons.school_outlined,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF30313D),
          ),
        ),

        const SizedBox(height: 8),

      DropdownButtonFormField<String>(
  value: items.contains(value) ? value : null,

  items: items
      .toSet()
      .map(
        (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        ),
      )
      .toList(),

  onChanged: onChanged,

  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFE1E3EA),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFF6C63FF),
        width: 1.5,
      ),
    ),
  ),
      ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF30313D),
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF6C63FF),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE1E3EA),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE1E3EA),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildHeader() {
    final user = currentUser;

    final photoUrl = user?.photoURL;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7C4DFF),
                    Color(0xFF5E35B1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF)
                        .withOpacity(.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: photoUrl != null &&
                        photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return const Icon(
                            Icons.person_rounded,
                            size: 52,
                            color: Colors.white,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
              ),
            ),

            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF7F8FC),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          'Build your student profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171923),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Tell us about yourself so CareerSaathi can create a personalized career roadmap.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 22),

        // Completion card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E6ED),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Profile completion',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  Text(
                    '${(completion * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: completion,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEDEDF5),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Session expired. Please login again.',
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
          'Student Profile',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 32),

              // =================================================
              // BASIC INFORMATION
              // =================================================

              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171923),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Let us know who you are.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              _buildTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: nameController,
                icon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 17),

              _buildTextField(
                label: 'Age',
                hint: 'Enter your age',
                controller: ageController,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 17),

              _buildDropdown(
                label: 'Gender',
                value: selectedGender,
                items: genderOptions,
                icon: Icons.person_2_outlined,
               onChanged: (value) {
  setState(() {
    selectedStream = value;
  });

  _calculateCompletion();
},
              ),

              const SizedBox(height: 17),

              _buildTextField(
                label: 'City',
                hint: 'Where do you currently live?',
                controller: cityController,
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 32),

              // =================================================
              // EDUCATION
              // =================================================

              const Text(
                'Education',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171923),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Your academic background helps us understand your options.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              _buildDropdown(
                label: 'Current Education',
                value: selectedEducation,
                items: educationOptions,
                icon: Icons.school_outlined,
                onChanged: (value) {
                  setState(() {
                    selectedEducation = value;

                    // Reset stream when education changes
                    selectedStream = null;
                  });

                  _calculateCompletion();
                },
              ),

              const SizedBox(height: 17),

              _buildDropdown(
                label: 'Stream / Field',
                value: selectedStream,
                items: selectedEducation == null
                    ? ['Select education first']
                    : streamOptions[
                            selectedEducation] ??
                        ['Other'],
                icon: Icons.menu_book_outlined,
               onChanged: (value) {
  setState(() {
    selectedStream = value;
  });

  _calculateCompletion();
},
              ),

              const SizedBox(height: 32),

              // =================================================
              // INTERESTS
              // =================================================

              _buildChipSection(
                title: 'Your Interests',
                subtitle:
                    'Select at least 2 things you genuinely enjoy.',
                options: interestOptions,
                selected: selectedInterests,
              ),

              const SizedBox(height: 32),

              // =================================================
              // SKILLS
              // =================================================

              _buildChipSection(
                title: 'Your Skills',
                subtitle:
                    'Select the skills you already have or are learning.',
                options: skillOptions,
                selected: selectedSkills,
              ),

              const SizedBox(height: 32),

              // =================================================
              // STRENGTHS
              // =================================================

              _buildChipSection(
                title: 'Your Strengths',
                subtitle:
                    'Choose qualities that describe you best.',
                options: strengthOptions,
                selected: selectedStrengths,
              ),

              const SizedBox(height: 32),

              // =================================================
              // CAREER GOAL
              // =================================================

              const Text(
                'Career Goal',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171923),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'This helps CareerSaathi personalize your roadmap.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              _buildTextField(
                label: 'What do you want to become?',
                hint:
                    'Example: Software Engineer, Pharmacist, Entrepreneur...',
                controller: goalController,
                icon: Icons.flag_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 17),

              _buildDropdown(
                label: 'Preferred Work Style',
                value: selectedWorkStyle,
                items: workStyleOptions,
                icon: Icons.work_outline_rounded,
                onChanged: (value) {
                  setState(() {
                    selectedWorkStyle = value;
                  });
                },
              ),

              const SizedBox(height: 35),

              // =================================================
              // AI MESSAGE
              // =================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF0EDFF),
                      Color(0xFFF8F7FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE1DCFF),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF)
                            .withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF6C63FF),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CareerSaathi AI',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Your profile will be used to generate personalized career suggestions and a step-by-step roadmap.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // SAVE BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF6C63FF),
                    disabledBackgroundColor:
                        const Color(0xFFB9B5F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 21,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Save My Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'You can update your profile anytime.',
                  style: TextStyle(
                    fontSize: 11.5,
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _profileSubscription?.cancel();

    nameController.dispose();
    ageController.dispose();
    cityController.dispose();
    goalController.dispose();

    super.dispose();
  }
}