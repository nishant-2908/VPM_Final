// ignore_for_file: use_build_context_synchronously, unused_field, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'mongo.dart';
import 'package:flutter/services.dart';
import 'success.dart';

class UserHome extends StatefulWidget {
  final String userValue;
  UserHome({required this.userValue});

  @override
  UserHomeState createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserHomeWidget(userValue: widget.userValue),
    );
  }
}

class UserHomeWidget extends StatefulWidget {
  final String userValue;

  UserHomeWidget({required this.userValue});

  @override
  State<UserHomeWidget> createState() => _UserHomeWidgetState();
}

class _UserHomeWidgetState extends State<UserHomeWidget> {
  bool isTrue = false;
  final UIDcontroller = TextEditingController();
  final VNcontroller = TextEditingController();
  bool _isVisible = false;
  bool isFinal = true;
  @override
  void initState() {
    super.initState();
    UIDcontroller.addListener(updateButtonVisibility);
    VNcontroller.addListener(updateButtonVisibility);
    _isVisible =
        (checkUID(UIDcontroller.text) && checkVehicleNumber(VNcontroller.text));
  }

  @override
  void dispose() {
    UIDcontroller.dispose();
    VNcontroller.dispose();
    super.dispose();
  }

  void updateButtonVisibility() {
    final isValidUID = checkUID(UIDcontroller.text);
    final isValidVehicleNumber = checkVehicleNumber(VNcontroller.text);
    setState(() {
      _isVisible = isValidUID && isValidVehicleNumber;
    });
  }

  bool checkUID(String uid) {
    return uid.trim().length == 6 && int.tryParse(uid) != null;
  }

  bool checkVehicleNumber(String vehicleNumber) {
    final pattern =
        RegExp(r'^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$', caseSensitive: false);

    if (pattern.hasMatch(vehicleNumber)) {
      return true;
    }
    return false;
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hey, ${widget.userValue.toUpperCase()}",
                        style: const TextStyle(
                            fontSize: 21, fontFamily: "Fredoka"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Column(
                      children: [
                        Visibility(
                          visible: !isTrue,
                          child: ElevatedButton(
                            onPressed: () async {
                              var switchthecontent = updateTheSwitch();
                              if (await switchthecontent) {
                                setState(() {
                                  isTrue = true;
                                });
                              } else {
                                setState(() {
                                  isTrue = false;
                                });
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Turn the Device ON",
                                style: TextStyle(
                                    fontSize: 23, fontFamily: 'Fredoka'),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Visibility(
                            visible: isTrue,
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 40),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 1),
                                          ),
                                          Text(
                                            "Enter UID (6 digits)",
                                            style: TextStyle(fontSize: 21),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 19),
                                        controller: UIDcontroller,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                        ],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'UID',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 235, 236, 234),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 2.0),
                                            child: Text(
                                              "Enter Vehicle Number (Capital Letters only)",
                                              style: TextStyle(fontSize: 21),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: TextField(
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10),
                                          UpperCaseTextFormatter(),
                                        ],
                                        obscureText: false,
                                        style: const TextStyle(fontSize: 19),
                                        controller: VNcontroller,
                                        decoration: InputDecoration(
                                          hintText: 'Vehicle Number',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 235, 236, 234),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 40),
                                      child: Visibility(
                                        visible:
                                            (checkUID(UIDcontroller.text) &&
                                                checkVehicleNumber(
                                                    VNcontroller.text)),
                                        child: Column(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                var isSuccess =
                                                    await updateTheValue(
                                                        UIDcontroller.text,
                                                        VNcontroller.text);
                                                if (isSuccess) {
                                                  setState(() {
                                                    isFinal = false;
                                                  });
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SuccessWidget()));
                                                } else {
                                                  setState(() {
                                                    isFinal = true;
                                                  });
                                                }
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 20,
                                                    left: 25,
                                                    right: 25),
                                                child: Text(
                                                  "Submit",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontFamily: "Fredoka"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.toUpperCase();
    return newValue.copyWith(text: newText);
  }
}
