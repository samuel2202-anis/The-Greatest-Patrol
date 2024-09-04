import 'package:den/widgets/news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

import '../theme.dart';
//import 'dart:html' as html;

class HomeWeb extends StatefulWidget {
  const HomeWeb({Key? key}) : super(key: key);

  @override
  _HomeWebState createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  String video = '';
  String name = '';
  String patrouille = '';
  String group = '';
  String password = '';
  String patrouilleScore = '';
  int hours = 1;
  String score = '';
  bool isPlaying = false;
  String taskName = '';
  DateTime currentPhoneDate = DateTime.now();
  int time = 0;
  int endTime = 0;
  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('nameSho3ba')!;

    // Get the task score from Firestore
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .doc('a')
        .get();

    // Extract the score from the document
    int score = int.parse((documentSnapshot.data() as Map<String, dynamic>)['score']);
    // Update the state
    setState(() {
      taskScore = score;
    });
    print('The score of task2 :$taskScore');

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

  Future<void> updateScore(bool back, String groupId, String teamId,
      int scoreIncrease, String reason, String addedBy) async {
    CollectionReference scores =
        FirebaseFirestore.instance.collection('scores');
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
      if (back) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(child: Text('تم اضافة النقاط بنجاح')),
        backgroundColor: Colors.green,
      ));
    });
  }

  Future<void> createTeam(String num, String username, String password) async {
    CollectionReference teams = FirebaseFirestore.instance.collection(num);
    return teams
        .doc(username)
        .set({
          'password': password, // store the password
          'score': 0, // initialize the score
          // add other team data here
        })
        .then((value) => print("Team Added"))
        .catchError((error) => print("Failed to add team: $error"));
  }

  String addScore = '';
  String reason = '';
  String passCode = '';
  String groupId = '';
  String teamId = '';
  int taskScore=0;

  @override
  void initState() {
    getName();
    super.initState();

  }

  Future<List<Map<String, dynamic>>> getTopScores() async {
    List<Map<String, dynamic>> allTeams = [];
    List<String> teams =['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','20','1A','2A','3A','4A'];

    // Loop through all collections
    for (int i = 0; i < teams.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(teams[i].toString())
          .orderBy('score', descending: true)
          .get();

      allTeams.addAll(querySnapshot.docs
          .map((doc) => {
                'docId': doc.id, // Add the document ID
                'collectionId': teams[i].toString(), // Add the collection ID
                ...doc.data() as Map<String, dynamic> // Add the document data
              })
          .toList());
    }

    // Sort all teams by score
    allTeams.sort((a, b) => b['score'].compareTo(a['score']));

    // Return the top 10 teams
    return allTeams.toList();
  }

  Future<void> updateTop10() async {
    // Get all scores
    List<Map<String, dynamic>> allScores = await getTopScores();

    // Sort all scores by score
    allScores.sort((a, b) => b['score'].compareTo(a['score']));

    // Take the top 10 scores
    List<Map<String, dynamic>> top10 = allScores.take(10).toList();

    // Get a reference to the 'top10' collection
    CollectionReference top10Collection =
        FirebaseFirestore.instance.collection('top10');

    // Clear the 'top10' collection
    QuerySnapshot querySnapshot = await top10Collection.get();
    List<Future<void>> deleteFutures =
        querySnapshot.docs.map((doc) => doc.reference.delete()).toList();

// Wait for all delete operations to complete
    await Future.wait(deleteFutures);

    // Write the top 10 scores to the 'top10' collection
    for (var team in top10) {
      top10Collection.add(team);
    }
  }
  bool viewScore=false;
  Stream<List<Map<String, dynamic>>> getDistinctTasks() {
    return FirebaseFirestore.instance
        .collection('submitTasks')
        .where('viewed', isEqualTo: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList()) // Transform QuerySnapshot into List<Map<String, dynamic>>
        .distinct((prevTasks, currTasks) {
      // Custom equality check
      if (prevTasks.length != currTasks.length) {
        return false;
      }
      for (int i = 0; i < prevTasks.length; i++) {
        if (prevTasks[i]['taskName'] != currTasks[i]['taskName'] ||
            prevTasks[i]['patrouille'] != currTasks[i]['patrouille'] ||
            prevTasks[i]['group'] != currTasks[i]['group']) {
          return false;
        }
      }
      return true;
    });
  }
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];

    for (int i = 1; i <= 20; i++) {
      if (i == 18 || i == 19) {
        continue;
      }
      items.add(
        DropdownMenuItem<String>(
          value: i.toString(),
          child: Center(
            child: Text(
              i.toString(),
              style: TextStyle(
                fontSize: 16,
                color: secondColor,
                fontFamily: '18 Khebrat',
              ),
            ),
          ),
        ),
      );
    }
    for (String value in ['1A', '2A', '3A', '4A']) {
      items.add(
        DropdownMenuItem<String>(
          value: value,
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: secondColor,
                fontFamily: '18 Khebrat',
              ),
            ),
          ),
        ),
      );
    }
    double screenWidth =
        MediaQuery.of(context).size.width; // Get the screen width
    double maxWidth = 500;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          actions: [
            Padding(
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
          ],
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.add,
          //     color: secondColor,
          //   ),
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           backgroundColor: primaryColor,
          //           content: Stack(
          //                 children: [
          //                   sheet(),
          //                   Positioned(
          //                     top: 16,
          //                     left: 16,
          //                     child: IconButton(
          //                       icon: Icon(Icons.close, color: secondColor),
          //                       onPressed: () {
          //                         Navigator.of(context).pop();
          //                       },
          //                     ),
          //                   ),
          //                 ],
          //               )
          //
          //         );
          //       },
          //     );
          //   },
          // ),
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
        body: Stack(
          children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'التحديات المسلمة',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: '18 Khebrat',
                            color: secondColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String enteredName = '';
                              return AlertDialog(
                                title: Text('Enter name'),
                                content: TextField(
                                  onChanged: (value) {
                                    enteredName = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      if (enteredName.isNotEmpty) {
                                        // Get all documents from 'submitTasks'
                                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                            .collection('submitTasks')
                                            .get();

                                        for (var doc in querySnapshot.docs) {
                                          // Add the document to the new collection
                                          await FirebaseFirestore.instance
                                              .collection(enteredName)
                                              .doc(doc.id)
                                              .set(doc.data() as Map<String, dynamic>);

                                          // Delete the document from 'submitTasks'
                                          await doc.reference.delete();
                                        }

                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'نقل التحدي',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: '18 Khebrat',
                              color: secondColor,
                            ),
                          ),
                        ),
                      )                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('submitTasks')
                        .where('viewed', isEqualTo: false)
                        .snapshots().distinct(

                    ),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('هناك خطأ ما '));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: Text("جاري التحميل ..."));
                      }
                      double tileHeight =
                          60.0; // Adjust this value based on your ListTile design
                      double calculatedHeight =
                          snapshot.data!.docs.length * tileHeight;
                      calculatedHeight =
                          calculatedHeight > 300 ? 300 : calculatedHeight;
                      List<DocumentSnapshot> tasks = snapshot.data!.docs;
                      tasks.sort((a, b) {
                        int comp = (a.data() as Map<String, dynamic>)['group'].compareTo((b.data() as Map<String, dynamic>)['group']);
                        if (comp != 0) return comp;
                        return (a.data() as Map<String, dynamic>)['patrouille'].compareTo((b.data() as Map<String, dynamic>)['patrouille']);
                      });
                      return SizedBox(
                        height: calculatedHeight,
                        child: ListView.builder(
                          itemCount:tasks.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot task = tasks[index];

                            return ListTile(
                                leading: Text(
                                  task['taskName'],
                                  style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                                title: Text(
                                  task['patrouille'] + ' ' + task['group'],
                                  style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                                subtitle: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: secondColor,
                                      fontFamily: '18 Khebrat',
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'التسليم: ' + task['submit'],
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            String url = task['submit'];
                                            if (url.contains('http')) {
                                              //html.window.open(url, '_blank');
                                            }
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AlertDialog(
                                            title: Text('ارسال نقاط التحدي ؟'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('نعم ارسال'),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('submitTasks')
                                                      .doc(task.id)
                                                      .update({
                                                    'viewed': true,
                                                    'viewedBy': name,
                                                  });
                                                  updateScore(
                                                      false,
                                                      task['group'],
                                                      task['patrouille'],
                                                      taskScore,
                                                      'تسليم التحدي',
                                                      name);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('لا'),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('submitTasks')
                                                      .doc(task.id)
                                                      .update({
                                                    'viewed': true,
                                                    'viewedBy': name,
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Checkbox(
                                    value: task['viewed'],
                                    activeColor: secondColor,
                                    checkColor: primaryColor,
                                    fillColor:
                                        WidgetStateProperty.all(secondColor),
                                    onChanged:
                                        null, // Checkbox is now read-only
                                  ),
                                ));
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: screenWidth < maxWidth ? screenWidth : maxWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: primaryColor,
                                        content: StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return Stack(
                                              children: [
                                                addScores(setState, items),
                                                Positioned(
                                                  top: 16,
                                                  left: 16,
                                                  child: IconButton(
                                                    icon: Icon(Icons.close,
                                                        color: secondColor),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  'اضافة نقاط',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String enteredPassword = '';
                                    return Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: AlertDialog(
                                        title: Text('ادخل كلمة المرور'),
                                        content: TextFormField(
                                          obscureText: true,
                                          onChanged: (value) {
                                            enteredPassword = value;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'كلمة المرور',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('تأكيد'),
                                            onPressed: () {
                                              const String correctPassword =
                                                  '129081';
                                              if (enteredPassword ==
                                                  correctPassword) {
                                                updateTop10();
                                                Navigator.of(context).pop();
                                              } else {
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Center(
                                                      child: Text(
                                                          ' لا يمكنك تحديث النتائج كلمة السر غير صحيحة')),
                                                  backgroundColor: Colors.red,
                                                ));
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'تحديث المراكز',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  !viewScore? Center(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String enteredPassword = '';
                            return Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                title: Text('ادخل كلمة المرور'),
                                content: TextField(
                                  onChanged: (value) {
                                    enteredPassword = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('تأكيد'),
                                    onPressed: () {
                                      const String correctPassword = '129081';
                                      if (enteredPassword == correctPassword) {
                                        setState(() {
                                          viewScore = true;
                                        });
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pop();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Center(
                                              child: Text(
                                                  ' لا يمكنك رؤية المراكز ')),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text('عرض المراكز',style: TextStyle(
                        fontSize: 30,
                        fontFamily: '18 Khebrat',
                        color: secondColor,
                      ),),
                    ),
                  )
                :
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getTopScores(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                              color: secondColor,
                            )); // Show a loading spinner while waiting for data
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Show error message if something went wrong
                      } else {
                        // Build a list of ListTile widgets from the data
                        return Container(
                          height: 300,
                          width: screenWidth < maxWidth ? screenWidth : maxWidth,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                                title: Text(
                                  '${snapshot.data![index]['docId']} ${snapshot.data![index]['collectionId']}',
                                  style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                                trailing: Text(
                                  'النقاط: ${snapshot.data![index]['score']}',
                                  style: TextStyle(
                                    fontFamily: '18 Khebrat',
                                    color: secondColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addScores(StateSetter setState, List<DropdownMenuItem<String>> items) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 400,
        // color: const primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: primaryColor,
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: secondColor,
                        fontFamily: '18 Khebrat',
                      ),
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: secondColor,
                        fontFamily: '18 Khebrat',
                      ),
                      labelText: 'المجموعة',
                    ),
                    value: items.any((item) => item.value == groupId)
                        ? groupId
                        : items.first.value,
                    items: items,
                    onChanged: (value) {
                      setState(() {
                        groupId = value.toString();
                        teamId = '';
                      });
                    },
                  ),
                ),
              ),
              if (groupId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(groupId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading");
                      }
                      print(snapshot.data!.docs.length);
                      print(snapshot.data!.docs[0].id);

                      List<DropdownMenuItem<String>> patrouilleItems =
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                          value: document.id,
                          // use the document ID as the value
                          child: Center(
                            child: Text(
                              document.id,
                              style: TextStyle(
                                fontSize: 16,
                                color: secondColor,
                                fontFamily: '18 Khebrat',
                              ),
                            ),
                          ),
                        );
                      }).toList();

                      // Check if the current value of patrouille exists in the new list of items
                      if (!patrouilleItems
                          .any((item) => item.value == teamId)) {
                        // If it doesn't, set patrouille to the value of the first item
                        teamId = patrouilleItems.first.value!;
                      }

                      return Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: primaryColor,
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              borderSide:
                                  BorderSide(width: 1, color: secondColor),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: secondColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: secondColor),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: secondColor,
                              fontFamily: '18 Khebrat',
                            ),
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: secondColor,
                              fontFamily: '18 Khebrat',
                            ),
                            labelText: 'الطليعة',
                          ),
                          value: teamId,
                          items: patrouilleItems,
                          onChanged: (value) {
                            setState(() {
                              teamId = value!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: secondColor,
                  style: TextStyle(color: secondColor), // Add this line

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      fillColor: secondColor,
                      focusColor: secondColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'النقاط',
                      hintText: 'النقاط'),
                  onChanged: (text) {
                    addScore = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: secondColor,
                  style: TextStyle(color: secondColor), // Add this line

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      fillColor: secondColor,
                      focusColor: secondColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'السبب',
                      hintText: 'السبب'),
                  onChanged: (text) {
                    reason = text;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: secondColor,
                  style: TextStyle(color: secondColor), // Add this line

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      fillColor: secondColor,
                      focusColor: secondColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'كلمة السر',
                      hintText: 'كلمة السر'),
                  onChanged: (text) {
                    password = text;
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(secondColor),
                  ),
                  child: const Text(
                    'اضافة النقاط',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    if (teamId.isNotEmpty &&
                        addScore.isNotEmpty &&
                        reason.isNotEmpty) {
                      if (password != '129081') {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Center(child: Text(' لا يمكنك اضافة نقاط كلمة السر غير صحيحة')),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }
                      updateScore(true, groupId, teamId, int.parse(addScore),
                          reason, name);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget sheet() {
    return SingleChildScrollView(
      child: Container(
        height: 350,
        //color: const primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: group,
                  cursorColor: secondColor,
                  style: TextStyle(color: secondColor),
                  // Add this line

                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(width: 1, color: secondColor),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: secondColor),
                    ),
                    labelStyle: TextStyle(fontSize: 16, color: secondColor),
                    hintStyle: TextStyle(fontSize: 16, color: secondColor),
                    labelText: 'Group',
                    hintText: 'Group',
                  ),
                  onChanged: (text) {
                    group = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: patrouille,
                  style: TextStyle(color: secondColor),
                  // Add this line

                  cursorColor: secondColor,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'Patrouille',
                      hintText: 'Patrouille'),
                  onChanged: (text) {
                    patrouille = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: password,
                  style: TextStyle(color: secondColor),
                  // Add this line

                  cursorColor: secondColor,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'Password',
                      hintText: 'Password'),
                  onChanged: (text) {
                    password = text;
                  },
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(secondColor),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: primaryColor),
                ),
                onPressed: () =>
                    group.isEmpty || patrouille.isEmpty || password.isEmpty
                        ? null
                        : createTeam(group, patrouille, password),
              )
            ],
          ),
        ),
      ),
    );
  }
}
