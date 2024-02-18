// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_print
import 'user_home.dart';
import 'mongo.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({Key? key}) : super(key: key);

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isVisible = false;
  String value = '';
  String userNameWarning = '';
  bool incorrect = false;
  @override
  void initState() {
    super.initState();
    userNameController.addListener(updateButtonVisibility);
    passwordController.addListener(updateButtonVisibility);
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void updateButtonVisibility() {
    final isValid = checkUsernameAndPassword(
      userNameController.text,
      passwordController.text,
    );
    setState(() {
      _isVisible = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      checkerboardOffscreenLayers: false,
      title: "Trial",
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.lightGreen,
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 10,
          centerTitle: true,
          title: const Text(
            "Welcome to Pollution Meter",
            style: TextStyle(fontSize: 24, fontFamily: "Poppins"),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              "Hey Officer!",
                              style: TextStyle(
                                  fontSize: 25, fontFamily: "Fredoka"),
                            ),
                          ),
                          Text(
                            "Enter Username",
                            style: TextStyle(fontSize: 21),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextField(
                        style: const TextStyle(fontSize: 19),
                        controller: userNameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 235, 236, 234),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Enter Password",
                              style: TextStyle(fontSize: 21),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      child: TextField(
                        obscureText: true,
                        style: const TextStyle(fontSize: 19),
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 235, 236, 234),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Visibility(
                        visible: _isVisible,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                var value = await checkUsername(
                                    userNameController.text,
                                    passwordController.text);
                                if (value == 'Success') {
                                  setState(() {
                                    incorrect = false;
                                    userNameWarning = '';
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserHomeWidget(
                                              userValue:
                                                  userNameController.text,
                                            )),
                                  );
                                } else if (value == 'Incorrect Password') {
                                  setState(() {
                                    userNameWarning = 'Incorrect Password';
                                    incorrect = true;
                                  });
                                } else {
                                  incorrect = true;
                                  userNameWarning = 'No such user exists';
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 25),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      fontSize: 24, fontFamily: "Fredoka"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Visibility(
                        visible: !_isVisible,
                        child: Column(
                          children: [
                            Text(value),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 20, bottom: 20, left: 25, right: 25),
                                child: Text(
                                  "Go back Home",
                                  style: TextStyle(
                                      fontSize: 24, fontFamily: "Fredoka"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Visibility(
                          visible: (incorrect && _isVisible),
                          child: Text(
                            userNameWarning,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 19),
                          ),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkUsernameAndPassword(String a, String b) {
    if (a.trim().isEmpty || b.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void addNumber() {
    print(2 + 2);
  }
}
