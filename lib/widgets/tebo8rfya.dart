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
  double angle1 = 0;
  double angle2 = 0;

  bool submitted = false;

  int currentIndex = 0; // Track the current question index
String messageForDisplay='';
  void getData() {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('tepo');
    collectionReference.doc(widget.model.toString()).get().then((value) {
      var fields = value.data() as Map;
      setState(() {
        message.add(fields['message1']);
        message.add(fields['message2']);
        message.add(fields['message3']);
        coordinates.add(fields['coor1']);
        coordinates.add(fields['coor2']);
        angle1=fields['angle1'].toDouble();
        angle2=fields['angle2'].toDouble();
     messageForDisplay = currentIndex < message.length ? message[currentIndex] : message.last;

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
    //checkSubmitted();

  }


TextEditingController northController = TextEditingController();
TextEditingController eastController = TextEditingController();
TextEditingController angleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Ensure we don't exceed the message list length
   // String messageForDisplay = currentIndex < message.length ? message[currentIndex] : message.last;

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
        body: message.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: secondColor,
                ),
              )
            :
        SingleChildScrollView(
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
                          child: currentIndex!=1?Text(messageForDisplay,textAlign:TextAlign.center,style: TextStyle(
                            fontSize: 20,
                            fontFamily: '18 Khebrat',
                            color: primaryColor,
                          ),)
                          :Image.network(message[1],height: 200,),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    if(currentIndex<2)
                    Column(
                      children: [
                        Center(
                          child: Text(' ادخل النقاط مثل 172617.31 -- عدد 6 نقط بعد الرقم',style: TextStyle(
                            fontSize: 14,
                            fontFamily: '18 Khebrat',
                            color: secondColor,                      
                          ),textDirection:TextDirection.rtl,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, right: 16, left: 16),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: northController,
                          
                          decoration: InputDecoration(
                            labelText: 'النقطة في اتجاه الشمال (N)',
                            hintText: 'النقطة في اتجاه الشمال (N)',
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
                        Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: eastController,
                      decoration: InputDecoration(
                        labelText: 'النقطة في اتجاه الشرق (E)',
                        hintText: 'النقطة في اتجاه الشرق (E)',
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
                      ],
                    ),
                    if(currentIndex>=2)
                       Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: angleController,
                      decoration: InputDecoration(
                        labelText: 'الزاوية',
                        hintText: 'الزاوية',
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
                    if (currentIndex == 3) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:secondColor,
                            content: Center(child: Text('لقد تم تسليم جميع الطلبات')),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      return; // Exit the function if the quiz has ended
                    }
                  if(currentIndex<2){
                    final northAnswer = double.parse(northController.text);
                    final eastAnswer = double.parse(eastController.text);

                    final coordinates2 = coordinates[currentIndex]; 
                    if (northAnswer >= coordinates2[0] && northAnswer <= coordinates2[2]&&
                        eastAnswer >= coordinates2[1] && eastAnswer <= coordinates2[3]) {
                  _checkAnswer(true);
                    } else {
                      _checkAnswer(false);

                    }}else{
                      final angleAnswer = double.parse(angleController.text);
                      if(angleAnswer>=angle1&&angleAnswer<=angle2){
                        _checkAnswer(true);
                      }else{
                        _checkAnswer(false);
                      }
                    }
                    // Move to the next question
                    setState(() {
                      debugPrint('currentIndex: $currentIndex');                
                        currentIndex++;
                        northController.clear();
                        eastController.clear();
                        angleController.clear(); 
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
  void dispose() {
    northController.dispose();
    eastController.dispose();
    angleController.dispose();
    super.dispose();
  } 
  void _checkAnswer(bool correct){
if(correct){
   updateScore(10, context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Center(child: Text('اجابة صحيحة')),
                          duration: const Duration(seconds: 3),
                        ),
                      );
  }else{
    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Center(child: Text('اجابة خاطئة')),
                          duration: const Duration(seconds: 3),
                        ),
                      );
  }
}     
              
            
}      


