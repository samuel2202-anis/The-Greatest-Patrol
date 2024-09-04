import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:den/theme.dart';
import 'package:den/widgets/home.dart';
import 'package:den/widgets/homeWeb.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWeb extends StatefulWidget {
  const LoginWeb({super.key});

  @override
  State<LoginWeb> createState() => _LoginState();
}

class _LoginState extends State<LoginWeb> {
  String name = '';

  String password = '';
  bool loading = false;

  Future<bool> login(BuildContext context,  String username,
      String password) async {
    DocumentReference team =
    FirebaseFirestore.instance.collection('sho3ba').doc(username);
    return team.get().then((doc) async {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['password'] == password) {

          setState(() {
            loading = false;
          });
          // Save the username in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('nameSho3ba', name);
          // Navigate to the home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeWeb()),
          );
          return true;
        } else {
          showMessage(context, "كلمة المرور غير صحيحة تواصل معايا ياشف ",
              Colors.red);
          setState(() {
            loading = false;
          });
          return false;
        }
      } else {
        showMessage(context, "هناك خطأ ما تواصل معايا ياشف", Colors.red);
        setState(() {
          loading = false;
        });
        return false;
      }
    }).catchError((error) {
      showMessage(context, "يرجي التواصل مع القائد المحترم", Colors.red);
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryColor,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Text(
                  'SGWEN Game',
                  style: TextStyle(
                    color: thirdColor,
                    fontSize: 30,
                    fontFamily: '18 Khebrat',
                  ),
                ),
                Text(
                  'تسجيل الدخول ',
                  style: TextStyle(
                    color: thirdColor,
                    fontSize: 18,
                    fontFamily: '18 Khebrat',
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: name,
                    cursorColor: secondColor,

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
                      labelText: 'اسم القائد',
                      fillColor: secondColor,
                      focusColor: secondColor,

                      hintText:  'اسم القائد',
                    // Add your suffix icon here
                    ),
                    onChanged: (text) {
                      name = text;
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
                    color: thirdColor,
                  ),
                )
                    : ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(thirdColor),
                    ),
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color: primaryColor,
                        fontFamily: '18 Khebrat',
                      ),
                    ),
                    onPressed: () {
                      if (
                          name.isNotEmpty &&
                          password.isNotEmpty) {
                        login(context, name, password);
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
