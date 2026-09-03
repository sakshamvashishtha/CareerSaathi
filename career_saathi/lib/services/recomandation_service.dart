// import '../models/career_model.dart';
// import '../models/student_profile.dart';

// class RecommendationService {
//   // ============================================================
//   // CAREER DATABASE
//   // ============================================================

//   static final List<CareerModel> careers = [
//     CareerModel(
//       name: 'Software Developer',
//       description:
//           'Designs, develops and maintains software applications and digital products.',
//       requiredSkills: [
//         'Programming',
//         'Problem Solving',
//         'Analytical Thinking',
//       ],
//       relatedInterests: [
//         'Technology',
//         'Computer Science',
//         'Problem Solving',
//       ],
//       recommendedCourses: [
//         'B.Tech Computer Science',
//         'BCA',
//         'B.Sc Computer Science',
//       ],
//       averageSalary: 600000,
//       workStyles: [
//         'Mostly independent',
//         'Small team',
//         'Mix of individual and team work',
//       ],
//     ),

//     CareerModel(
//       name: 'Data Analyst',
//       description:
//           'Analyses data to discover insights and support business decisions.',
//       requiredSkills: [
//         'Analytical Thinking',
//         'Problem Solving',
//         'Research',
//         'Mathematics',
//       ],
//       relatedInterests: [
//         'Mathematics',
//         'Data',
//         'Technology',
//         'Research',
//       ],
//       recommendedCourses: [
//         'B.Sc Data Science',
//         'B.Tech Data Science',
//         'B.Sc Statistics',
//       ],
//       averageSalary: 550000,
//       workStyles: [
//         'Mostly independent',
//         'Small team',
//       ],
//     ),

//     CareerModel(
//       name: 'Cyber Security Analyst',
//       description:
//           'Protects systems, networks and data from cyber threats.',
//       requiredSkills: [
//         'Problem Solving',
//         'Analytical Thinking',
//         'Research',
//         'Decision Making',
//       ],
//       relatedInterests: [
//         'Technology',
//         'Cyber Security',
//         'Problem Solving',
//         'Research',
//       ],
//       recommendedCourses: [
//         'B.Tech Cyber Security',
//         'B.Tech Computer Science',
//         'B.Sc Cyber Security',
//       ],
//       averageSalary: 650000,
//       workStyles: [
//         'Mostly independent',
//         'Small team',
//       ],
//     ),

//     CareerModel(
//       name: 'Product Manager',
//       description:
//           'Coordinates technology, business and user needs to build products.',
//       requiredSkills: [
//         'Leadership',
//         'Communication',
//         'Decision Making',
//         'Problem Solving',
//       ],
//       relatedInterests: [
//         'Technology',
//         'Business',
//         'Communication',
//         'Leadership',
//       ],
//       recommendedCourses: [
//         'BBA',
//         'B.Tech',
//         'B.Com',
//       ],
//       averageSalary: 800000,
//       workStyles: [
//         'Small team',
//         'Large team',
//       ],
//     ),

//     CareerModel(
//       name: 'UX/UI Designer',
//       description:
//           'Designs digital experiences that are useful, accessible and visually engaging.',
//       requiredSkills: [
//         'Creativity',
//         'Communication',
//         'Problem Solving',
//         'Empathy',
//       ],
//       relatedInterests: [
//         'Creativity',
//         'Design',
//         'Technology',
//         'People',
//       ],
//       recommendedCourses: [
//         'B.Des',
//         'B.Sc Design',
//         'BCA',
//       ],
//       averageSalary: 500000,
//       workStyles: [
//         'Small team',
//         'Creative Studio',
//       ],
//     ),

//     CareerModel(
//       name: 'Business / Management Professional',
//       description:
//           'Works on business strategy, operations, growth and management.',
//       requiredSkills: [
//         'Leadership',
//         'Communication',
//         'Decision Making',
//         'Teamwork',
//       ],
//       relatedInterests: [
//         'Business',
//         'Entrepreneurship',
//         'Leadership',
//         'Communication',
//       ],
//       recommendedCourses: [
//         'BBA',
//         'B.Com',
//         'BBM',
//       ],
//       averageSalary: 500000,
//       workStyles: [
//         'Large team',
//         'Small team',
//       ],
//     ),
//   ];

//   // ============================================================
//   // MAIN RECOMMENDATION FUNCTION
//   // ============================================================

//   static List<CareerMatch> getRecommendations(
//     StudentProfile student,
//   ) {
//     final List<CareerMatch> matches = [];

//     for (final career in careers) {
//       double score = 0;

//       // ========================================================
//       // 1. INTEREST MATCH
//       // ========================================================

//       for (final studentInterest in student.interests) {
//         final normalizedStudentInterest =
//             _normalize(studentInterest);

//         final hasMatch = career.relatedInterests.any(
//           (careerInterest) =>
//               _normalize(careerInterest)
//                   .contains(normalizedStudentInterest) ||
//               normalizedStudentInterest
//                   .contains(_normalize(careerInterest)),
//         );

//         if (hasMatch) {
//           score += 15;
//         }
//       }

//       // ========================================================
//       // 2. SKILL MATCH
//       // ========================================================

//       for (final requiredSkill in career.requiredSkills) {
//         final requiredSkillNormalized =
//             _normalize(requiredSkill);

//         for (final entry in student.skills.entries) {
//           final studentSkillNormalized =
//               _normalize(entry.key);

//           if (studentSkillNormalized ==
//                   requiredSkillNormalized ||
//               studentSkillNormalized
//                   .contains(requiredSkillNormalized) ||
//               requiredSkillNormalized
//                   .contains(studentSkillNormalized)) {
//             // Skill score is weighted according to
//             // the student's actual demonstrated ability.
//             score += entry.value * 0.45;
//           }
//         }
//       }

//       // ========================================================
//       // 3. WORK STYLE MATCH
//       // ========================================================

//       if (student.workStyle != null) {
//         if (career.workStyles.any(
//           (style) =>
//               _normalize(style) ==
//               _normalize(student.workStyle!),
//         )) {
//           score += 10;
//         }
//       }

//       // ========================================================
//       // 4. CAREER PRIORITY MATCH
//       // ========================================================

//       for (final priority in student.careerPriorities) {
//         final normalizedPriority =
//             _normalize(priority);

//         // High earning
//         if (normalizedPriority.contains('high earning') &&
//             career.averageSalary >= 600000) {
//           score += 5;
//         }

//         // Career growth
//         if (normalizedPriority
//             .contains('fast career growth')) {
//           score += 4;
//         }

//         // Innovation
//         if (normalizedPriority.contains('innovation') &&
//             career.relatedInterests.any(
//               (interest) =>
//                   _normalize(interest)
//                       .contains('technology'),
//             )) {
//           score += 4;
//         }

//         // Helping people
//         if (normalizedPriority.contains('helping people') &&
//             career.relatedInterests.any(
//               (interest) =>
//                   _normalize(interest)
//                       .contains('people'),
//             )) {
//           score += 4;
//         }

//         // Work-life balance
//         if (normalizedPriority
//             .contains('work life balance')) {
//           score += 3;
//         }
//       }

//       // ========================================================
//       // 5. CAREER DIRECTION
//       // ========================================================

//       if (student.careerDirection != null) {
//         final direction =
//             _normalize(student.careerDirection!);

//         // Private sector generally aligns strongly
//         // with technology/business careers.
//         if (direction.contains('private sector') &&
//             (career.name.contains('Developer') ||
//                 career.name.contains('Analyst') ||
//                 career.name.contains('Manager') ||
//                 career.name.contains('Designer'))) {
//           score += 4;
//         }

//         // Research / Academia
//         if (direction.contains('research') &&
//             career.relatedInterests.any(
//               (interest) =>
//                   _normalize(interest)
//                       .contains('research'),
//             )) {
//           score += 5;
//         }

//         // Entrepreneurship
//         if (direction.contains('entrepreneurship') &&
//             career.relatedInterests.any(
//               (interest) =>
//                   _normalize(interest)
//                       .contains('business') ||
//                   _normalize(interest)
//                       .contains('entrepreneurship'),
//             )) {
//           score += 5;
//         }
//       }

//       // ========================================================
//       // 6. FINAL SCORE LIMIT
//       // ========================================================

//       if (score > 100) {
//         score = 100;
//       }

//       if (score < 0) {
//         score = 0;
//       }

//       matches.add(
//         CareerMatch(
//           career: career,
//           score: double.parse(score.toStringAsFixed(1)),
//         ),
//       );
//     }

//     // ==========================================================
//     // SORT: HIGHEST MATCH FIRST
//     // ==========================================================

//     matches.sort(
//       (a, b) => b.score.compareTo(a.score),
//     );

//     return matches;
//   }

//   // ============================================================
//   // NORMALIZE TEXT
//   // ============================================================

//   static String _normalize(String text) {
//     return text
//         .toLowerCase()
//         .trim()
//         .replaceAll(' ', '')
//         .replaceAll('/', '')
//         .replaceAll('-', '');
//   }

//   // ============================================================
//   // GET TOP CAREER
//   // ============================================================

//   static CareerMatch? getTopRecommendation(
//     StudentProfile student,
//   ) {
//     final results = getRecommendations(student);

//     if (results.isEmpty) {
//       return null;
//     }

//     return results.first;
//   }
// }

// // ================================================================
// // CAREER MATCH MODEL
// // ================================================================

// class CareerMatch {
//   final CareerModel career;
//   final double score;

//   CareerMatch({
//     required this.career,
//     required this.score,
//   });

//   String get percentage {
//     return '${score.toStringAsFixed(0)}%';
//   }
// }