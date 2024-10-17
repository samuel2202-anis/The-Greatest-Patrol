import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:den/questions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'finishWidget.dart';


class QuizGame extends StatefulWidget {
  final String groupId;
  final String teamId;

  const QuizGame({super.key, required this.groupId, required this.teamId});
  @override
  _QuizGameState createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
 
  int currentQuestionIndex = 0;
  String userAnswer = '';
  bool secondChance = false;
  final TextEditingController answerController = TextEditingController();
  String? groupId ;
  String? teamId ;
  @override
  void initState() {
    super.initState();
    groupId = widget.groupId;
    teamId = widget.teamId;
    loadQuestionIndex();
    saveALoadSecondChance(false);
  }

  void loadQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedIndex = prefs.getInt('currentQuestionIndex');
    if (savedIndex != null) {
      setState(() {
        currentQuestionIndex = savedIndex;
      });
    }
  }
  void saveALoadSecondChance(bool save) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint('saveSecondChance: $save');
    if(save){
      await prefs.setBool('secondChance', secondChance);
    }else
 {
    bool? savedSecondChance = prefs.getBool('secondChance');
    if (savedSecondChance != null) {
      setState(() {
        secondChance = savedSecondChance;
      });
      print('secondChance: $secondChance');
    }}
  }

  void saveQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentQuestionIndex', currentQuestionIndex);
  }
  void saveFinish() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('finished', true);

  }
  Future<void> submitAnswer() async {
    print(' currentQuestionIndex: $currentQuestionIndex , questions.length: ${questions.length}');
    if (currentQuestionIndex >= questions.length) {
      saveFinish();
      // Quiz is over
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FinishWidget();
        },
      );
      return;
    }

    if (userAnswer.trim().toLowerCase() == questions[currentQuestionIndex].answer.trim().toLowerCase() || (userAnswer.startsWith('ZQ') && (currentQuestionIndex+1) % 2 == 0)) {
      if(userAnswer.startsWith('ZQ')&& (currentQuestionIndex+1) % 2 == 0){
        final taskScore = int.parse(userAnswer.substring(userAnswer.length - 2));
        updateScore( groupId!, teamId!, taskScore, context);
      }else{
     updateScore( groupId!, teamId!, 10, context);} // Adjust parameters as needed
      saveQuestionIndex();
      setState(() {
        if(currentQuestionIndex == questions.length - 1){
          saveFinish();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FinishWidget();
            },
          );
          return;
        }
        currentQuestionIndex++;
        secondChance = false;
        saveALoadSecondChance(true);
        answerController.clear();
      });
    } else if (!secondChance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(child: Text('تسليم خاطئ, لديك محاولة واحدة اخري وسيتم الانتقال للتالي')),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        secondChance = true;
        saveALoadSecondChance(true);
        answerController.clear();
      });
    } else {
      saveQuestionIndex();

      setState(() {
        if(currentQuestionIndex == questions.length - 1){
          saveFinish();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FinishWidget();
            },
          );
          return;
        }
        currentQuestionIndex++;
        secondChance = false;
        saveALoadSecondChance(true);
        answerController.clear();
      });
       CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('submitTasks');
  
      await collectionReference.add({
        'taskName': 'اللعبة ${currentQuestionIndex} ', 
        'patrouille': widget.teamId,
        'group': widget.groupId,
        //'group': ((int.parse(widget.groupId)*4)-1).toString(),

        'submit': userAnswer,
        'time': DateTime.now(),
        'viewed':false
      });
    }
    answerController.clear();
    userAnswer = '';
  }
 Future<void> updateScore(String groupId, String teamId,
      int scoreIncrease,  BuildContext context) async {
try{
    CollectionReference teams = FirebaseFirestore.instance.collection(groupId);

    DocumentSnapshot teamSnapshot = await teams.doc(teamId).get();

    if (!teamSnapshot.exists) {
      throw Exception('Team does not exist!');
    }

    int newScore = teamSnapshot.get('score') + scoreIncrease; // Ensure this line is correct
    await teams.doc(teamId).update({'score': newScore});
    Map<String, dynamic> data = teamSnapshot.data() as Map<String, dynamic>;
    int gameScore = data.containsKey('gameScore') ? data['gameScore'] : 0;
    gameScore += scoreIncrease;
    await teams.doc(teamId).update({'gameScore': gameScore});
}catch(e){
  print(e);
}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor:  primaryColor,
          centerTitle: true,
          title:  Text(
            'اللعبة',
            style: TextStyle(
              fontSize: 20,
              fontFamily: '18 Khebrat',
              color: secondColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: secondColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(' رقم ${currentQuestionIndex + 1}/30',style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: '18 Khebrat',
                                  color: primaryColor
                                ),),
                              ),
                            ),
                            SizedBox(height: 12,),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(questions[currentQuestionIndex].question,textAlign:TextAlign.center,style: TextStyle(
            
                                  fontSize: 20,
                                  fontFamily: '18 Khebrat',
                                  color: primaryColor,
                                ),),
                              ),
                            ),
            
                            SizedBox(height: 12,),
                            if(questions[currentQuestionIndex].hint != null)
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.lightbulb_outline,color: primaryColor,),
                                      Text('  : ${questions[currentQuestionIndex].hint}',style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: '18 Khebrat',
                                        color: primaryColor
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
            
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('ملاحظات : \n- في حالة الخطأ اذا كنت متأكد من الاجابة قم بتسليمها مرة اخري وسيتم مراجعة الاجابة.\n - في حالة الالعاب يجب مشاركة جميع افراد الطليعة .',style: TextStyle(
                    fontSize: 14,
                    fontFamily: '18 Khebrat',
                    color: secondColor,
                  ),),
                ),
               // Text(questions[currentQuestionIndex].question),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: answerController,
                    style: TextStyle(
                      color: secondColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'الاجابة',
                      hintStyle: TextStyle(
                        color: secondColor,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: secondColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: secondColor,
                        ),
                      ),
                    ),
            
                    onChanged: (value) {
                      userAnswer = value;
                    },
                  ),
                ),
                SizedBox(height: 24,),
                ElevatedButton(
                  onPressed: submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondColor,
                  ),
                  child: Text('تسليم',style: TextStyle(
                    fontSize: 18,
                    fontFamily: '18 Khebrat',
                    color: primaryColor,
                  ),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
}