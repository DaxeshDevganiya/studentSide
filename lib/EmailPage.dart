import 'dart:convert';

import 'package:assignment_student/PasswordPage.dart';
import 'package:assignment_student/domain.dart';
import 'package:assignment_student/student/StudentDashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:assignment_student/main.dart';
import 'package:http/http.dart' as http;
import 'package:assignment_student/signupStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  final apiUrl = "$apiDomain/email/login";
  final _formfield = GlobalKey<FormState>();

  final emailController = TextEditingController();

  Future<void> checkEmail() async {
    var response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"email": emailController.text, "contact": emailController.text}));
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == 200) {
      print("success");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final _fcm = await FirebaseMessaging.instance.getToken();
      final token = await _fcm.toString();
      await prefs.setString("fcmToken", token.toString());
      await prefs.setString("email", responseData['Data']['email']);
      await prefs.setString("contact", responseData['Data']['contact']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Password()),
      );
    } else {
      print("hrer work fne");
      var responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Form(
        key: _formfield,
        child: Column(
          children: [
            Container(
              width: screenWidth * 1,
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                  color: Color(primary),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(120),
                  )),
              child: Center(
                child: Text("Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            SizedBox(height: 20.00),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email),
                        hintText: "Email or Contact",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Color(primary)),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(primary), width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Color(primary)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter email or contact";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.4,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(primary)),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Color(primary)))),
                          onPressed: () {
                            if (_formfield.currentState!.validate()) {
                              checkEmail();
                            }
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                    ),
                    SizedBox(height: 20.00),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Signup()));
                      },
                      child: Text("Don't have account ? click here",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18.00,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
