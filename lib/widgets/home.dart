import 'package:den/widgets/news.dart';
import 'package:den/widgets/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';
import '../theme.dart';
import 'finishWidget.dart';
import 'game.dart';
import 'tebo8rfya.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String task = '';
  String patrouille = '';
  String group = '';
  String name = '';
  String password = '';
  String patrouilleScore = '';
  int hours = 1;
  bool start=false;
  String score = '';
  bool finished = false;
  bool isVideo = true;
  String taskName = '';
  DateTime currentPhoneDate = DateTime.now();
  int time = 0;
  int endTime = 0;

  void getPoint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    group = prefs.getString('group')!;
    finished = prefs.getBool('finished') ?? false;
    print('finished: $finished');
    patrouille = prefs.getString('patrouille')!;
    name = prefs.getString('name')!;
    if (group.isNotEmpty && patrouille.isNotEmpty) {
      CollectionReference teams = FirebaseFirestore.instance.collection(group);
      teams.doc(patrouille).get().then((value) {
        var fields = value.data() as Map;
        setState(() {
          patrouilleScore = fields['score'].toString();
        });
      });
    }
  }

  void getTasks() {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('tasks');
    collectionReference.doc('a').get().then((value) {
      var fields = value.data() as Map;
      setState(() {
        score = fields['score'];
        hours = fields['hours'];
        time = fields['time'].millisecondsSinceEpoch;
        taskName = fields['name'];
        isVideo = fields['video'];
        start=fields['start'];
        task = fields['task'];
        endTime = time + (hours * 1000 * 60 * 60);
      });
    });
  }

  Future<List<Map<String, dynamic>>> getTop10FromCollection() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('top10')
        .orderBy('score', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<int> fetchNotificationCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('news').get();
    return snapshot.docs.length;
  }

  Future<int> getSavedNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('notificationCount') ?? 0;
  }

  Future<int> getNewNotificationCount() async {
    List<int> counts = await Future.wait(
        [fetchNotificationCount(), getSavedNotificationCount()]);
    int fetchedCount = counts[0];
    int savedCount = counts[1];
    int newNotificationsCount = fetchedCount - savedCount;
    print(newNotificationsCount);
    return newNotificationsCount;
  }

  String addScore = '';
  String reason = '';
  String groupId = '';
  String teamId = '';

  @override
  void initState() {
    getPoint();
    getTasks();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            actions: [
               
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('group');
                      prefs.remove('patrouille');
                      prefs.remove('name');
                      // Navigate to the login screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: Icon(
                      Icons.logout,
                      color: secondColor,
                    )),
              )

            ],
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context,
                              MaterialPageRoute(builder: (context) => News()))
                          .then((value) {
                        setState(() {
                          getNewNotificationCount();
                        });
                      });
                    },
                    icon: Icon(
                      Icons.notifications,
                      color: secondColor,
                    ),
                  ),
                  FutureBuilder<int>(
                    future: getNewNotificationCount(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        return Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${snapshot.data}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Container(); // return an empty container when there's no data
                    },
                  ),
                ],
              ),
            ),
            backgroundColor: primaryColor,
            centerTitle: true,
            title: Text(
              'THE GAME',
              style: TextStyle(
                fontSize: 30,
                fontFamily: '18 Khebrat',
                color: secondColor,
              ),
            ),
          ),
          body: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.2, // Change this value to adjust the opacity
                child: Image.asset('assets/game.png', fit: BoxFit.cover),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            secondColor,
                            secondColor,
                            thirdColor,
                            //primaryColor
                          ], // Replace with your desired colors
                        ),
                        borderRadius: BorderRadius.circular(
                            7), // Change this to adjust the border radius
                      ),
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0.0, // Add this line
                        child: ListTile(
                          title: Text(
                            'طليعة : $patrouille',
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontFamily: '18 Khebrat'),
                          ),
                          trailing: Text(
                            'عدد النقاط : $patrouilleScore',
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontFamily: '18 Khebrat'),
                          ),
                          subtitle: Text(
                            'المجموعة : $group',
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 13,
                                fontFamily: '18 Khebrat'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التحدي الحالي',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: '18 Khebrat',
                            color: secondColor,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Task(
                                      video: task,
                                      group: group,
                                      isVideo: isVideo,
                                      taskName: taskName,
                                      patrouille: patrouille,
                                      hours: hours,
                                      score: score,
                                      time: time,
                                    )),
                          ),
                          child: Text(
                            'عرض اخر تحدي',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: '18 Khebrat',
                              color: secondColor,
                            ),
                          ),
                        ),
                       
                  
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        
                        decoration: BoxDecoration(
                          color: secondColor,
                          
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if(!start){
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return notStarted();
                                },
                              );
                            }
                         else {  final model = await showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    backgroundColor: secondColor,
                                    title: Text('برجاء ادخال رقم النموذج الخاص بالطليعة',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 14,
                                          fontFamily: '18 Khebrat',
                                        )),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          for (int i = 1; i <= 6; i++)
                                            ListTile(
                                              leading: Icon(
                                                Icons.arrow_left_rounded,
                                                color: primaryColor,
                                              ),
                                              title: Text(' نموذج $i ',
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: '18 Khebrat',
                                                  )),
                                              onTap: () => Navigator.of(context).pop(i),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                            if (model != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Tob8orfya(
                                  group: group,
                                  patrouille: patrouille,
                                  model: model,
                                )),);
                            }}
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 40,
                                color: primaryColor,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'الطبوغرافيا',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: '18 Khebrat',
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                      
                        ),
                      ),
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: secondColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if(!start){
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return notStarted();
                                },
                              );
                            }
                            else{SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            finished = prefs.getBool('finished') ?? false;
                            print('finished: $finished');
                            finished
                                ? showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FinishWidget();
                                    },
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => QuizGame(
                                              groupId: group,
                                              teamId: patrouille,
                                            )),
                                  );}
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gamepad,
                                size: 40,
                                color: primaryColor,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'اللعبة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: '18 Khebrat',
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'المراكز',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: '18 Khebrat',
                        color: secondColor,
                      ),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getTop10FromCollection(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                                color:
                                    secondColor)); // Show a loading spinner while waiting for data
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Show error message if something went wrong
                      } else {
                        // Build a list of ListTile widgets from the data
                        return SizedBox(
                          height: 380,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: group ==
                                            snapshot.data![index]
                                                ['collectionId'] &&
                                        patrouille ==
                                            snapshot.data![index]['docId']
                                    ? secondColor
                                    : primaryColor.withOpacity(0.7),
                                child: ListTile(
                                  leading: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontFamily: '18 Khebrat',
                                      color: group ==
                                                  snapshot.data![index]
                                                      ['collectionId'] &&
                                              patrouille ==
                                                  snapshot.data![index]['docId']
                                          ? primaryColor
                                          : secondColor,
                                    ),
                                  ),
                                  title: Text(
                                    '${snapshot.data![index]['docId']} ${snapshot.data![index]['collectionId']}',
                                    style: TextStyle(
                                      fontFamily: '18 Khebrat',
                                      color: group ==
                                                  snapshot.data![index]
                                                      ['collectionId'] &&
                                              patrouille ==
                                                  snapshot.data![index]['docId']
                                          ? primaryColor
                                          : secondColor,
                                    ),
                                  ),
                                  trailing: Text(
                                    'النقاط: ${snapshot.data![index]['score']}',
                                    style: TextStyle(
                                      fontFamily: '18 Khebrat',
                                      color: group ==
                                                  snapshot.data![index]
                                                      ['collectionId'] &&
                                              patrouille ==
                                                  snapshot.data![index]['docId']
                                          ? primaryColor
                                          : secondColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ]),
        ));
  }
  Widget notStarted (){
    return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    backgroundColor: secondColor,
                                    title: Text('المسابقة لم تبدأ بعد',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 14,
                                          fontFamily: '18 Khebrat',
                                        )),
                                    content: Builder(
                                      builder: (context) => Container(
                                        width: 300,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'المسابقة ستبدأ في اليوم المنتظر .. استعدواا',
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontFamily: '18 Khebrat',
                                              ),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'اغلاق',
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily: '18 Khebrat',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
  }
}
