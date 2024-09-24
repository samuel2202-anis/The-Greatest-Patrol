import 'package:den/widgets/news.dart';
import 'package:den/widgets/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../login.dart';
import '../theme.dart';
import 'finishWidget.dart';
import 'game.dart';

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
  String score = '';
  bool finished = false;
  bool isPlaying = false;
  bool isVideo=true;
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
        isVideo=fields['video'];
        task = fields['task'];
        endTime = time + (hours * 1000 * 60 * 60);
      });
      if (task.isNotEmpty) {
        _controller = VideoPlayerController.network(task)
          ..initialize().then((_) {
            setState(() {});
          });

        if (_controller != null &&
            endTime > currentPhoneDate.millisecondsSinceEpoch) {
          _controller!.play();
        }
      }
    });
  }
  Future<List<Map<String, dynamic>>> getTop10FromCollection() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('top10')
        .orderBy('score', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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




  VideoPlayerController? _controller;

  bool _showVideo = true;
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
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor:  primaryColor,
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
            backgroundColor:  primaryColor,
            centerTitle: true,
            title:  Text(
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
                            'عرض التحدي',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: '18 Khebrat',
                              color: secondColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async{ SharedPreferences prefs = await SharedPreferences.getInstance();
    finished = prefs.getBool('finished') ?? false;
    print('finished: $finished');
    finished?  showDialog(
            context: context,
            builder: (BuildContext context) {
              return FinishWidget();
            },
          ):Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizGame(
                                      groupId: group,
                                      teamId: patrouille,
                                )),
                          );
    } 
                         , child: Text(
                            '  اللعبة  ',
                            style: TextStyle(
                              fontSize: 12,
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
                  Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: CountdownTimer(
                        endTime: endTime,
                        endWidget: Text(
                          'لا يوجد تحديات الان',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: '18 Khebrat',
                            color: secondColor,
                          ),
                        ),
                        textStyle: TextStyle(
                          fontSize: 60,
                          fontFamily: 'candid',
                          color: secondColor,
                        ),
                      ),
                    ),
                  ),
                  if (endTime > currentPhoneDate.millisecondsSinceEpoch)
                    Center(
                      child: Text(
                        'نقاط التحدي : $score',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: '18 Khebrat',
                          color: secondColor,
                        ),
                      ),
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
                    builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color:secondColor)); // Show a loading spinner while waiting for data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}'); // Show error message if something went wrong
                      } else {
                        // Build a list of ListTile widgets from the data
                        return SizedBox(
                          height: 380,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color:group==snapshot.data![index]['collectionId']&&patrouille==snapshot.data![index]['docId']?secondColor: primaryColor.withOpacity(0.7),
                                child: ListTile(
                                  leading: Text('${index + 1}',style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color:group==snapshot.data![index]['collectionId']&&patrouille==snapshot.data![index]['docId']?primaryColor: secondColor,
                                  ),),
                                  title: Text('${snapshot.data![index]['docId']} ${snapshot.data![index]['collectionId']}',style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color: group==snapshot.data![index]['collectionId']&&patrouille==snapshot.data![index]['docId']?primaryColor:secondColor,
                                  ),),
                                  trailing: Text('النقاط: ${snapshot.data![index]['score']}',style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color:group==snapshot.data![index]['collectionId']&&patrouille==snapshot.data![index]['docId']?primaryColor:secondColor,
                                  ),),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ),
            if (isVideo&&_showVideo &&
                _controller != null &&
                endTime > currentPhoneDate.millisecondsSinceEpoch)
              Stack(
                children: [
                  Opacity(
                    opacity: 0.8, // Adjust this value to change the opacity
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                  Center(
                    child: _controller!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: 1, // Change aspect ratio to 1:1
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                VideoPlayer(_controller!),
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      _controller!.value.isPlaying
                                          ? _controller!.pause()
                                          : _controller!.play();
                                    });
                                  },
                                ),
                                Positioned(
                                  top: 8,
                                  left: 16,
                                  child: IconButton(
                                    icon:
                                        Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _showVideo = false;
                                        _controller!.pause();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FutureBuilder<void>(
                            future: Future.delayed(Duration(seconds: 7)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (!_controller!.value.isInitialized) {
                                  // If the video is still not initialized after 10 seconds, hide the video player
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _showVideo = false;
                                        _controller!.pause();
                                      });
                                    }
                                  });
                                }
                                return Container();
                              } else {
                                // While waiting for the future to complete, show a loading spinner
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: secondColor,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
          ]),
        ));
  }
}
