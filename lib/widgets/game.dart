import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../functions.dart';
import '../theme.dart';


class QuizGame extends StatefulWidget {
  @override
  _QuizGameState createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  List<Question> questions = [
    // Add your 25 questions here
    Question(question: 'اسم القائد العام الحالي', answer: 'فوزي الاسمر'),
    Question(question: 'من هي محافظة مصر', answer: 'القاهرة'),
    Question(question: 'من هو الرئيس الحالي للجمهورية العربية السورية', answer: 'بشار الاسد'),
    Question(question: 'كم عضمة بجسم الانسان', answer: '206'),
    Question(question: 'متي تأسست الحركة الكشفية', answer: '1907',hint: 'ضع السنة فقط بدون كلمة'),


    // ...
  ];
  int currentQuestionIndex = 0;
  String userAnswer = '';
  bool secondChance = false;
  final TextEditingController answerController = TextEditingController();
  @override
  void initState() {
    super.initState();
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
    if (userAnswer == questions[currentQuestionIndex].answer) {
      saveQuestionIndex();
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
      saveQuestionIndex();
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