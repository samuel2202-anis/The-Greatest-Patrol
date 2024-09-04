import 'package:cloud_firestore/cloud_firestore.dart';

class Functions{
  Future<List<Map<String, dynamic>>> getTopScores() async {
    List<Map<String, dynamic>> allTeams = [];

    // Loop through all collections
    for (int i = 1; i <= 20; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(i.toString())
          .orderBy('score', descending: true)
          .get();

      allTeams.addAll(querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
    }

    // Sort all teams by score
    allTeams.sort((a, b) => b['score'].compareTo(a['score']));

    // Return the top 10 teams
    return allTeams.take(10).toList();
  }
  Future<int> getTeamScore(String groupId, String teamId) async {
    DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection(groupId).doc(teamId).get();

    if (!teamSnapshot.exists) {
      throw Exception('Team does not exist!');
    }

    return teamSnapshot.get('score');
  }
  // Function to update a team's score
   Future<void> updateScore(String groupId, String teamId, int scoreIncrease, String reason,String addedBy) async {
    CollectionReference scores = FirebaseFirestore.instance.collection('scores');
    CollectionReference teams = FirebaseFirestore.instance.collection(groupId);

    // Create a new score update event
    await scores.add({
      'teamId': teamId,
      'groupId': groupId,
      'scoreIncrease': scoreIncrease,
      'reason': reason,
      'addedBy': addedBy,
    });

    // Use a transaction to increase the team's score
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot teamSnapshot = await transaction.get(teams.doc(teamId));

      if (!teamSnapshot.exists) {
        throw Exception('Team does not exist!');
      }

      int newScore = teamSnapshot.get('score') + scoreIncrease;
      transaction.update(teams.doc(teamId), {'score': newScore});
    });
  }
}
class Question {
  final String question;
  final String answer;
  String? hint;

  Question({required this.question, required this.answer,this.hint});
}