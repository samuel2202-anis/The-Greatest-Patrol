import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
class Task extends StatefulWidget {
  final String video;
  String score;
  int hours;
  final bool isVideo;
  final String taskName;
  final String patrouille;
  final String group;
  int time;

  Task(
      {super.key,
      required this.video,
      required this.score,
  required this.isVideo,
      required this.time,
      required this.hours,
      required this.patrouille,
      required this.group,
      required this.taskName});

  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  String editScore = '';
  int editHours = 0;
  String submit = '';
  bool submitted = false;

  void submitTask(String submit) async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    Navigator.pop(context);

    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.none) {
    //   // No internet connection
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       backgroundColor: Colors.red,
    //       content: Center(child: Text('لا يوجد انترنت برجاء المحاولة مرة اخري')),
    //       duration: const Duration(seconds: 3),
    //     ),
    //   );
    // } else {
      CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('submitTasks');
    try {
      await collectionReference.add({
        'taskName': widget.taskName,
        'patrouille': widget.patrouille,
        'group': widget.group,
        'submit': 'Done : $submit',
        'time': DateTime.now(),
        'viewed':false
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(child: Text('تم التسليم بنجاح')),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        submitted = true;
      });
      prefs.setString('submittedTask', widget.taskName);
    }on FirebaseException catch (error) {
      print(' ya sasaaa error :$error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(child: Text('حدث خطأ ما برجاء المحاولة مرة أخري')),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  //}
  }

  void updateTasks(String tascore, int tahours) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('tasks');
    collectionReference.doc('a').update({
      'score': tascore,
      'hours': tahours,
      'time': DateTime.now().millisecondsSinceEpoch
    });
    setState(() {
      widget.score = tascore;
      widget.hours = tahours;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    checkSubmitted();

  }
void checkSubmitted()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    String? submittedTask=prefs.getString('submittedTask');
    if(submittedTask==widget.taskName){
      setState(() {
        submitted=true;
      });
    }
}


  @override
  Widget build(BuildContext context) {
    int endTime = widget.time + (widget.hours * 1000 * 60 * 60);
    List<String> lines = widget.video.split('      '); // Split the string into lines at each occurrence of '      '

    String messageForDisplay = lines.join('\n'); // Join the lines with '\n' to create a multiline string

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          leading: endTime > DateTime.now().millisecondsSinceEpoch
              ? submitted?Icon(Icons.check_circle,color: secondColor,):IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: secondColor,
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: primaryColor,
                          content: submitTaskk(),
                        );
                      },
                    );
                  })
              :
          SizedBox(),
          backgroundColor:  primaryColor,
          centerTitle: true,
          title:  Text(
            'التحدي الحالي',
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'قيمة التحدي',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: '18 Khebrat',
                      color: secondColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    widget.score,
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'candid',
                      color: secondColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'مدة التحدي',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: '18 Khebrat',
                      color: secondColor,
                    ),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: CountdownTimer(
                  endTime: endTime,
                  endWidget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('تم انتهاء وقت التسليم',style:TextStyle(color:secondColor) ,),
                  ),
                  textStyle: TextStyle(
                    fontSize: 50,
                    fontFamily: 'candid',
                    color: secondColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget updateTask() {
    return Container(
      height: 350,
      color:  primaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.score,
                cursorColor: secondColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(width: 1, color: secondColor),
                  ),
                  border: OutlineInputBorder(
                    borderSide:  BorderSide(color: secondColor),
                  ),
                  labelStyle: TextStyle(fontSize: 16, color: secondColor),
                  hintStyle: TextStyle(fontSize: 16, color: secondColor),
                  labelText: 'Score',
                  hintText: 'Score',
                ),
                onChanged: (text) {
                  editScore = text;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: widget.hours.toString(),
                keyboardType: TextInputType.number,
                cursorColor: secondColor,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide:
                          BorderSide(width: 1, color: secondColor),
                    ),
                    border: OutlineInputBorder(
                      borderSide:  BorderSide(color: secondColor),
                    ),
                    labelStyle:
                        TextStyle(fontSize: 16, color: secondColor),
                    hintStyle:
                        TextStyle(fontSize: 16, color: secondColor),
                    labelText: 'Hours',
                    hintText: 'Hours'),
                onChanged: (text) {
                  editHours = int.parse(text);
                },
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(secondColor),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => editHours.isNaN || editScore.isEmpty
                  ? null
                  : updateTasks(editScore, editHours),
            )
          ],
        ),
      ),
    );
  }

  Widget submitTaskk() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height:MediaQuery.of(context).size.height*0.5,
        // color: const primaryColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text('تسليم التحدي',style: TextStyle(fontFamily: '18 Khebrat',fontSize:18,color:secondColor ),)),
              ),
          SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('ملحوظة : اذا كان التسليم صورة او فيديو برجاء وضع رابط ملف الدرايف وتأكد بأنه مشارك مع الجميع ',style: TextStyle(fontFamily: '18 Khebrat',fontSize:14,color:Colors.red ),),
              ),
          
              TextButton(
                onPressed: () async {
                  const url = 'https://youtu.be/K5KTnxK0rq0?si=1SiTjsVeg7yDVMBD';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text('ازاي ارفع ملف علي درايف واشاركه؟', style: TextStyle(color: secondColor)),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: secondColor,
                  style: TextStyle(color: secondColor), // Add this line
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide:
                            BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide:  BorderSide(color: secondColor),
                      ),
                      fillColor: secondColor,
                      focusColor: secondColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle:
                          TextStyle(fontSize: 16, color: secondColor),
                      hintStyle:
                          TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'الاجابة',
                      hintText: 'الاجابة'),
                  onChanged: (text) {
                    submit = text;
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(secondColor),
                  ),
                  child:  Text(
                    'تسليم',
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () {
                    if (submit.isNotEmpty) {
                      submitTask(submit);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
