// import 'profile_screen.dart';
class StudentProfile {
  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  String name;
  int? age;

  String? education;
  String? stream;

  // ============================================================
  // ACADEMIC INFORMATION
  // ============================================================

  List<String> subjects;

  // ============================================================
  // INTERESTS
  // ============================================================

  List<String> interests;

  // ============================================================
  // SKILLS
  // skill name -> percentage
  // Example:
  // Problem Solving -> 88
  // Programming -> 75
  // ============================================================

  Map<String, double> skills;

  // ============================================================
  // CAREER PREFERENCES
  // ============================================================

  List<String> careerPriorities;

  String? workStyle;
  String? careerDirection;
  String? locationPreference;
  String? higherStudies;

  // ============================================================
  // LOCATION
  // ============================================================

  String? city;
  String? state;

  // ============================================================
  // FINANCIAL INFORMATION
  // ============================================================

  String? familyIncomeRange;
  String? educationBudgetRange;

  double? annualBudget;
  double? familyIncome;

  bool scholarshipRequired;
  bool hostelRequired;
  bool educationLoanRequired;

  // ============================================================
  // RECOMMENDATION
  // ============================================================

  String? recommendedCareer;
  String? recommendedCourse;

  double careerMatchScore;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  StudentProfile({
    this.name = '',
    this.age,

    this.education,
    this.stream,

    List<String>? subjects,
    List<String>? interests,
    Map<String, double>? skills,

    List<String>? careerPriorities,

    this.workStyle,
    this.careerDirection,
    this.locationPreference,
    this.higherStudies,

    this.city,
    this.state,

    this.familyIncomeRange,
    this.educationBudgetRange,

    this.annualBudget,
    this.familyIncome,

    this.scholarshipRequired = false,
    this.hostelRequired = false,
    this.educationLoanRequired = false,

    this.recommendedCareer,
    this.recommendedCourse,

    this.careerMatchScore = 0,
  })  : subjects = subjects ?? [],
        interests = interests ?? [],
        skills = skills ?? {},
        careerPriorities = careerPriorities ?? [];

  // ============================================================
  // CHECK PROFILE COMPLETION
  // ============================================================

  double get completionPercentage {
    int completed = 0;
    const int total = 8;

    if (name.trim().isNotEmpty) completed++;
    if (age != null) completed++;
    if (education != null) completed++;
    if (stream != null) completed++;
    if (subjects.isNotEmpty) completed++;
    if (interests.isNotEmpty) completed++;
    if (skills.isNotEmpty) completed++;
    if (city != null && city!.trim().isNotEmpty) {
      completed++;
    }

    return completed / total;
  }

  // ============================================================
  // ADD INTEREST SAFELY
  // ============================================================

  void addInterest(String interest) {
    if (!interests.contains(interest)) {
      interests.add(interest);
    }
  }

  // ============================================================
  // REMOVE INTEREST
  // ============================================================

  void removeInterest(String interest) {
    interests.remove(interest);
  }

  // ============================================================
  // ADD SUBJECT
  // ============================================================

  void addSubject(String subject) {
    if (!subjects.contains(subject)) {
      subjects.add(subject);
    }
  }

  // ============================================================
  // REMOVE SUBJECT
  // ============================================================

  void removeSubject(String subject) {
    subjects.remove(subject);
  }

  // ============================================================
  // UPDATE SKILL
  // ============================================================

  void updateSkill(
    String skill,
    double score,
  ) {
    skills[skill] = score.clamp(0, 100);
  }

  // ============================================================
  // CLEAR SKILLS
  // ============================================================

  void clearSkills() {
    skills.clear();
  }

  // ============================================================
  // CONVERT TO MAP
  // Useful later for Firebase / API
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,

      'education': education,
      'stream': stream,

      'subjects': subjects,
      'interests': interests,
      'skills': skills,

      'careerPriorities': careerPriorities,

      'workStyle': workStyle,
      'careerDirection': careerDirection,
      'locationPreference': locationPreference,
      'higherStudies': higherStudies,

      'city': city,
      'state': state,

      'familyIncomeRange': familyIncomeRange,
      'educationBudgetRange': educationBudgetRange,

      'annualBudget': annualBudget,
      'familyIncome': familyIncome,

      'scholarshipRequired': scholarshipRequired,
      'hostelRequired': hostelRequired,
      'educationLoanRequired':
          educationLoanRequired,

      'recommendedCareer': recommendedCareer,
      'recommendedCourse': recommendedCourse,
      'careerMatchScore': careerMatchScore,
    };
  }
}