import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:den/theme.dart';
import 'package:den/widgets/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String patrouille = '';
  String group = '';
  String password = '';
  bool loading = false;
  Future<QuerySnapshot>? futureSnapshot;

  void updateGroup(String newGroup) {
    setState(() {
      group = newGroup;
      futureSnapshot = FirebaseFirestore.instance.collection(group).get();
    });
  }
  Future<bool> login(BuildContext context, String num, String username,
      String password) async {
    DocumentReference team =
        FirebaseFirestore.instance.collection(num).doc(username);
    return team.get().then((doc) async {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['password'] == password) {
          String name= username +' '+'ال' + num;
          showMessage(
              context,
              "مرحباً بدخول $name في مسابقة شعبة الكشافة والمرشدات ",
              Colors.green);
          setState(() {
            loading = false;
          });
          // Save the username in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', name);
          await prefs.setString('group', num);
          await prefs.setString('patrouille', username);
          // Navigate to the home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
          return true;
        } else {
          showMessage(context, "كلمة المرور غير صحيحة تواصل مع قائد الوحدة ",
              Colors.red);
          setState(() {
            loading = false;
          });
          return false;
        }
      } else {
        showMessage(context, "هناك خطأ ما تواصل مع قائد الوحدة", Colors.red);
        setState(() {
          loading = false;
        });
        return false;
      }
    }).catchError((error) {
      showMessage(context, "يرجي التواصل مع قائد الوحدة", Colors.red);
      setState(() {
        loading = false;
      });
      return false;
    });
  }

  void showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message,textAlign: TextAlign.center,)),
      backgroundColor: color,
    ));
  }

  bool passwordI = true;

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
        body: Stack(children: [
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.1, // Change this value to adjust the opacity
              child: Image.asset('assets/game.png', fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Text(
                  'SGWEN Game',
                  style: TextStyle(
                    color: secondColor,
                    fontSize: 30,
                    fontFamily: '18 Khebrat',
                  ),
                ),
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: secondColor,
                    fontSize: 18,
                    fontFamily: '18 Khebrat',
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: primaryColor,
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(width: 1, color: thirdColor),
                        ),
                        border: OutlineInputBorder(
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
                      value: items.any((item) => item.value == group) ? group : items.first.value,
                      items: items,
                      onChanged: (value) {
                        setState(() {
                          group = value.toString();
                          patrouille = '';
                          updateGroup(value!);

                        });
                      },
                    ),
                  ),
                ),
                if (group.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<QuerySnapshot>(
                      future: futureSnapshot,
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Loading");
                        }

                        if (snapshot.hasData) {
                          List<DropdownMenuItem<String>> patrouilleItems = snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return DropdownMenuItem<String>(
                              value: document.id,
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

                          if (!patrouilleItems.any((item) => item.value == patrouille)) {
                            patrouille = patrouilleItems.first.value!;
                          }

                          return Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: primaryColor,
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1, color: secondColor),
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
                              value: patrouille,
                              items: patrouilleItems,
                              onChanged: (value) {
                                setState(() {
                                  patrouille = value!;
                                });
                              },
                            ),
                          );
                        } else {
                          return const Text('لا يوجد طلائع');
                        }
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: password,
                    cursorColor: secondColor,
                    obscureText: passwordI,
                    style: TextStyle(color: secondColor), // Add this line

                    // This will hide the password text
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(fontSize: 16, color: secondColor),
                      labelText: 'كلمة المرور',
                      fillColor: secondColor,
                              focusColor: secondColor,

                      hintText: 'كلمة المرور',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordI = !passwordI;
                            });
                          },
                          icon: Icon(
                            passwordI ? Icons.visibility : Icons.visibility_off,
                            color: secondColor,
                          )), // Add your suffix icon here
                    ),
                    onChanged: (text) {
                      password = text;
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: secondColor,
                        ),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(secondColor),
                        ),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: '18 Khebrat',
                          ),
                        ),
                        onPressed: () {
                          if (group.isNotEmpty &&
                              patrouille.isNotEmpty &&
                              password.isNotEmpty) {
                            login(context, group, patrouille, password);
                            setState(() {
                              loading = true;
                            });
                          }
                        })
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
