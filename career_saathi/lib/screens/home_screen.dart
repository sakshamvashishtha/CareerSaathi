
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'assessment_screen.dart';
import 'assessment_result_screen.dart';
import 'career_roadmap_screen.dart';
import 'daily_tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const primary = Color(0xFF6C63FF);
  static const bg = Color(0xFFF7F8FC);
  static const dark = Color(0xFF171923);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login again.')));

    final ref = FirebaseFirestore.instance.collection('students').doc(user.uid);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, automaticallyImplyLeading: false,
        title: const Text('CareerSaathi', style: TextStyle(color: dark, fontSize: 24, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentResultScreen())), icon: const Icon(Icons.auto_awesome_rounded, color: primary)),
          const SizedBox(width: 6),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
        stream: ref.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primary));
          final d = snap.data?.data() ?? {};
          final name = (d['name'] ?? 'Student').toString();
          final goal = (d['careerGoal'] ?? '').toString();
          final interests = List<String>.from(d['interests'] ?? const []);
          final skills = List<String>.from(d['skills'] ?? const []);
          final completion = _completion(d);

          return RefreshIndicator(
            color: primary,
            onRefresh: () async { await ref.get(); },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _hero(name, goal, completion),
                const SizedBox(height: 18),
                _action(context, Icons.psychology_alt_rounded, 'Career Assessment', 'Find evidence-based career directions from your answers.', 'Take Assessment',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentScreen()))),
                const SizedBox(height: 12),
                _action(context, Icons.route_rounded, 'Personalized Roadmap', 'Your next skills, projects, internship and job steps.', 'Open Roadmap',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerRoadmapScreen()))),
                const SizedBox(height: 12),
                _action(context, Icons.task_alt_rounded, 'Today’s Action Plan', 'Complete small measurable actions and save progress to Firebase.', 'Open Tasks',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTasksScreen()))),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _stat('Skills', '${skills.length}', Icons.code_rounded)),
                  const SizedBox(width: 10),
                  Expanded(child: _stat('Interests', '${interests.length}', Icons.favorite_rounded)),
                  const SizedBox(width: 10),
                  Expanded(child: _stat('Profile', '${(completion*100).round()}%', Icons.person_rounded)),
                ]),
                const SizedBox(height: 22),
                const Text('Your current profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: dark)),
                const SizedBox(height: 10),
                _info('Goal', goal.isEmpty ? 'Complete your profile' : goal),
                _info('Education', '${d['education'] ?? '—'} • ${d['stream'] ?? '—'}'),
                _info('Work style', '${d['workStyle'] ?? '—'}'),
              ],
            ),
          );
        },
      ),
    );
  }

  double _completion(Map<String,dynamic> d) {
    const keys = ['name','age','education','stream','gender','interests','skills','strengths','careerGoal'];
    var n = 0;
    for (final k in keys) {
      final v = d[k];
      if (v is List ? v.isNotEmpty : v != null && v.toString().trim().isNotEmpty) n++;
    }
    return n / keys.length;
  }

  Widget _hero(String name, String goal, double p) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)]),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [BoxShadow(color: primary.withOpacity(.22), blurRadius: 24, offset: const Offset(0,10))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Welcome, $name 👋', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text(goal.isEmpty ? 'Let’s build your career path.' : goal, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Profile readiness', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        Text('${(p*100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 9),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value:p, minHeight:8, backgroundColor:Colors.white24, valueColor:const AlwaysStoppedAnimation(Colors.white))),
    ]),
  );

  Widget _action(BuildContext c, IconData icon, String title, String sub, String button, VoidCallback tap) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFE4E3EC))),
    child: Row(children: [
      Container(width:50,height:50,decoration:BoxDecoration(color:primary.withOpacity(.1),borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:primary)),
      const SizedBox(width:13),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900,color:dark)),
        const SizedBox(height:4), Text(sub,style:TextStyle(fontSize:12.5,height:1.35,color:Colors.grey.shade600)),
        const SizedBox(height:9),
        SizedBox(height:36,child:ElevatedButton(onPressed:tap,style:ElevatedButton.styleFrom(backgroundColor:primary,foregroundColor:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(11))),child:Text(button,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800))))
      ])),
    ]),
  );

  Widget _stat(String a,String b,IconData i)=>Container(
    padding:const EdgeInsets.all(13), decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17)),
    child:Column(children:[Icon(i,color:primary),const SizedBox(height:5),Text(b,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),Text(a,style:TextStyle(fontSize:11,color:Colors.grey.shade600))]),
  );

  Widget _info(String a,String b)=>Container(
    margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(15),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),
    child:Row(children:[Text(a,style:TextStyle(fontSize:11,color:Colors.grey.shade600)),const Spacer(),Flexible(child:Text(b,textAlign:TextAlign.right,style:const TextStyle(fontWeight:FontWeight.w700,color:dark)))])
  );
}
