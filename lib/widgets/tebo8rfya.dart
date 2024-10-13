import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
class Tob8orfya extends StatefulWidget {

  final String patrouille;
  final String group;
  final int model;

  Tob8orfya(
      {super.key,
      required this.patrouille,
      required this.group,
      required this.model
 });

  @override
  _Tob8orfyaState createState() => _Tob8orfyaState();
}

class _Tob8orfyaState extends State<Tob8orfya> {
  List<String> message = [];
  List<List> coordinates = [];

  bool submitted = false;

  int currentIndex = 0; // Track the current question index

  void getData() {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('tepo');
    collectionReference.doc(widget.model.toString()).get().then((value) {
      var fields = value.data() as Map;
      setState(() {
        message.add(fields['message1']);
        message.add(fields['message2']);
        coordinates.add(fields['coor1']);
        coordinates.add(fields['coor2']);
        debugPrint('message: ${message.toString()}');
        debugPrint('coordinates: ${coordinates[0][0].toString()}');
      });
    });
  }
  void checkSubmitted()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    setState(() {
      currentIndex=prefs.getInt('TepoIndex')??0;
    });
}
Future<void> updateScore(
      int scoreIncrease,  BuildContext context) async {
try{
    CollectionReference teams = FirebaseFirestore.instance.collection(widget.group);

    DocumentSnapshot teamSnapshot = await teams.doc(widget.patrouille).get();

    if (!teamSnapshot.exists) {
      throw Exception('Team does not exist!');
    }

   
    Map<String, dynamic> data = teamSnapshot.data() as Map<String, dynamic>;
    int gameScore = data.containsKey('tepo8rfyaScore') ? data['tepo8rfyaScore'] : 0;
    gameScore += scoreIncrease;
    await teams.doc(widget.patrouille).update({'tepo8rfyaScore': gameScore});
}catch(e){
  print(e);
}
  }
  @override
  void initState() {
    super.initState();
    getData();
    checkSubmitted();

  }


TextEditingController answerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Ensure we don't exceed the message list length
    String messageForDisplay = currentIndex < message.length ? message[currentIndex] : message.last;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor:  primaryColor,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('نموذج ${widget.model}',style: TextStyle(
                fontSize: 14,
                fontFamily: '18 Khebrat',
                color: secondColor,
              ),),
            ),
          ],
          title:  Text(
            'الطبوغرافيا',
            style: TextStyle(
              fontSize: 20,
              fontFamily: '18 Khebrat',
              color: secondColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: secondColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(messageForDisplay,textAlign:TextAlign.center,style: TextStyle(
                            fontSize: 20,
                            fontFamily: '18 Khebrat',
                            color: primaryColor,
                          ),),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: answerController,
                      decoration: InputDecoration(
                        labelText: 'النقاط',
                        hintText: 'النقاط',
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(width: 1, color: secondColor),
                        ),
                        labelStyle: TextStyle(color: secondColor),
                        hintStyle: TextStyle(color: secondColor),
                        border: OutlineInputBorder(
                          
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(width: 1, color: secondColor),
                        ),
                        
                      
                      )
                                        
                                      ),
                    ),
                SizedBox(height: 30,),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(secondColor),
                  ),
                  onPressed: () {
                    // Check if the quiz has ended
                    if (currentIndex == 2) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:secondColor,
                            content: Center(child: Text('لقد تم تسليم جميع النقاط')),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      return; // Exit the function if the quiz has ended
                    }

                    final value = double.parse(answerController.text);
                    final coordinates2 = coordinates[currentIndex]; // Get coordinates for the current question
                    if (value >= coordinates2[0] && value <= coordinates2[1]) {
                      updateScore(10, context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Center(child: Text('اجابة صحيحة')),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Center(child: Text('اجابة خاطئة')),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    // Move to the next question
                    setState(() {
                      debugPrint('currentIndex: $currentIndex');
                     
                        currentIndex++;
                        answerController.clear(); 
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setInt('TepoIndex', currentIndex);
                        });
                     
                    });
                  },
                  child: Text('تسليم',style: TextStyle(color: primaryColor),),
                ),
                ]
                  ,
                ),
              ),
         
            ],
          ),
        ),
      ),
    );
  }    
}     
              
            
      


