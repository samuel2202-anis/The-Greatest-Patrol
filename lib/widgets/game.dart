import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../functions.dart';
import '../theme.dart';


class QuizGame extends StatefulWidget {
  final String groupId;
  final String teamId;

  const QuizGame({super.key, required this.groupId, required this.teamId});
  @override
  _QuizGameState createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  List<Question> questions = [
    Question(question: 'غني اغنية كشفية مع طليعتك ( مساعدين)', answer: 'اغنية كشفية'),
    Question(question: 'شفرة عادية', answer: 'شفرة'),
    Question(question: 'ما هي االدولة التي تم بها اخر مؤتمر كشفي عالمي ( شفرة)', answer: 'الدولة'),
    Question(question: 'متي تأسست الحركة الكشفية في مصر', answer: '1914'),
    Question(question: 'من هي مؤسسة المرشدات ', answer: 'أوليفير'),
    Question(question: 'عمل ( 15 ضغط فردي + 30 بطن فردي + عربية فول في دقيقة للطليعة) ( مساعدين)', answer: 'تمارين'),
    Question(question: 'كم عدد المصريين الحاصلين علي نوبل', answer: '4'),
    Question(question: 'لعبة رمي الجولة (مساعدين)', answer: 'رمي الجولة'),
    Question(question: 'شفرة عادية', answer: 'شفرة'),
    Question(question: 'كيم تذوق ( مساعدين)', answer: 'تذوق'),
    Question(question: 'كيم شم ( مساعدين)', answer: 'شم'),
    Question(question: 'الفرق بين الشمال الحقيقي والشمال المغناطيسي', answer: 'الفرق'),
    Question(question: 'لف ودوران وكورة ( مساعدين)', answer: 'لف ودوران وكورة'),
    Question(question: 'ربط الفولار بطريقتين مختلفتين ( اصغر فرد بالطليعة)(مساعدين)', answer: 'ربط الفولار'),
    Question(question: 'كم عضمة في جسم الانسان (206 عضمة) ( شفرة)', answer: '206'),
    Question(question: 'رسم الزي الكشفي ( مساعدين)', answer: 'رسم الزي'),
    Question(question: 'ماهي عدد المجالس بالفرقة ', answer: 'عدد المجالس'),
    Question(question: 'ارسم 5 اعلام لتاريخ مصر ( مساعدين)', answer: 'اعلام'),
    Question(question: 'اذكر اسم اول فارس بالحركة ', answer: 'اسم اول فارس'),
    Question(question: 'شفرة عادية ', answer: 'شفرة'),
    Question(question: 'ماهي اسم الزهرة المستخدمة في علم وعد الفتيان ', answer: 'اسم الزهرة'),
    Question(question: 'عمل رسالة بالسيمافور(مساعدين)', answer: 'رسالة بالسيمافور'),
    Question(question: 'ماهي المسافة بين العريف واول فرد في التفتيش', answer: 'المسافة'),
    Question(question: 'شفرة عادية', answer: 'شفرة'),
    Question(question: 'كيم نظر', answer: 'نظر'),
  ];
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

  void saveQuestionIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentQuestionIndex', currentQuestionIndex);
  }
  void submitAnswer() {
    print(' currentQuestionIndex: $currentQuestionIndex , questions.length: ${questions.length}');
    if (currentQuestionIndex >= questions.length) {
      // Quiz is over
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return finish();
        },
      );
      return;
    }
    if (userAnswer.trim().toLowerCase() == questions[currentQuestionIndex].answer.trim().toLowerCase() || userAnswer.startsWith('ZQ')) {
      // Call updateScore from HomeWeb class
      if(userAnswer.startsWith('ZQ')){
        final taskScore = int.parse(userAnswer[userAnswer.length - 1]);
        updateScore( groupId!, teamId!, taskScore, context);
      }else{
     updateScore( groupId!, teamId!, 10, context);} // Adjust parameters as needed
     // saveQuestionIndex();
      setState(() {
        if(currentQuestionIndex == questions.length - 1){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return finish();
            },
          );
          return;
        }
        currentQuestionIndex++;
        secondChance = false;
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
        answerController.clear();
      });
    } else {
     // saveQuestionIndex();
      setState(() {
        if(currentQuestionIndex == questions.length - 1){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return finish();
            },
          );
          return;
        }
        currentQuestionIndex++;
        secondChance = false;
        answerController.clear();
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
    await teams.doc(teamId).update({'score': newScore}); // Ensure this line is correct
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
                              child: Text(' رقم ${currentQuestionIndex + 1}/25',style: TextStyle(
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
                                padding: const EdgeInsets.all(8.0),
                                child: Text(' 🗝 : ${questions[currentQuestionIndex].hint}',style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: '18 Khebrat',
                                  color: primaryColor
                                ),),
                              ),
                            ),

                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
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
    );
  }
  Widget finish(){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: secondColor,
        title: Text('انتهت اللعبة !',style: TextStyle(
          fontSize: 20,
          fontFamily: '18 Khebrat',
          color: primaryColor,
        ),textAlign: TextAlign.center,),
        content: Text('لقد تم تسليم جميع التحديات بنجاح',style: TextStyle(
          fontSize: 16,
          fontFamily: '18 Khebrat',
          color: primaryColor,
        ),textAlign: TextAlign.center,),
        actions: <Widget>[
          TextButton(
            child: Text('اغلاق',style: TextStyle(
              fontSize: 16,
              fontFamily: '18 Khebrat',
              color: primaryColor,
            ),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}