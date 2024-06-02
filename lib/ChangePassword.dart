import 'dart:convert';

import 'package:assignment_student/PasswordPage.dart';
import 'package:assignment_student/domain.dart';
import 'package:assignment_student/student/Homepage.dart';
import 'package:assignment_student/student/StudentDashboard.dart';
import 'package:flutter/material.dart';
import 'package:assignment_student/main.dart';
import 'package:http/http.dart' as http;
import 'package:assignment_student/signupStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswod extends StatefulWidget {
  const ChangePasswod({super.key});

  @override
  State<ChangePasswod> createState() => _ChangePasswodState();
}

class _ChangePasswodState extends State<ChangePasswod> {
  final _formfield = GlobalKey<FormState>();

  final Password = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  Future<void> changePassword() async {
    const apiUrl = "$apiDomain/changePassword";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    String jwtToken = token.toString();
    final response = await http.post(Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token'
        },
        body: jsonEncode({
          "currentPassword": Password.text,
          "newPassword": newPassword.text,
          "confirmPassword": confirmPassword.text
        }));
    var responseData = jsonDecode(response.body);
    print(responseData);
    if (responseData['status'] == 200) {
      print("success");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message']),
      ));
    } else {
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                )),
        title: Text(
          "Change Password",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formfield,
        child: Column(
          children: [
            // Container(
            //   width: screenWidth * 1,
            //   height: screenHeight * 0.3,
            //   decoration: BoxDecoration(
            //       color: Colors.blue,
            //       borderRadius: BorderRadius.only(
            //         bottomRight: Radius.circular(120),
            //       )),
            //   child: Center(
            //     child: Text("Login",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 40.0,
            //           fontWeight: FontWeight.bold,
            //         )),
            //   ),
            // ),
            SizedBox(height: 20.00),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                child: Column(
                  children: [
                    TextFormField(
                      controller: Password,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.password),
                        hintText: "Current Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Current Password";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      controller: newPassword,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.password),
                        hintText: "New Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter new Password";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      controller: confirmPassword,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.password),
                        hintText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Confirm Password";
                        }
                      },
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.7,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.black))),
                          onPressed: () {
                            if (_formfield.currentState!.validate()) {
                              changePassword();
                            }
                          },
                          child: Text(
                            "Change Password",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
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
