import 'dart:convert';

import 'package:assignment_student/EmailPage.dart';
import 'package:assignment_student/ForgotPassword.dart';
import 'package:assignment_student/OtpPage.dart';
import 'package:assignment_student/domain.dart';
import 'package:assignment_student/student/StudentDashboard.dart';
import 'package:flutter/material.dart';
import 'package:assignment_student/main.dart';
import 'package:http/http.dart' as http;
import 'package:assignment_student/signupStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  String _email = '';
  @override
  void initState() {
    super.initState();
    getemail();
  }

  final apiUrl = "$apiDomain/password/login";
  final _formfield = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  getemail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = (prefs.getString('email') ?? '');
    });
  }

  Future<void> checkPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString("email").toString();

    final contact = await prefs.getString("contact").toString();

    var response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "contact": contact,
          "password": passwordController.text
        }));
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message']),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Otp()),
      );
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
      appBar: AppBar(
        backgroundColor: Color(primary),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Email()),
                )),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Form(
        key: _formfield,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your're Signing in as",
                    ),
                    Text(
                      _email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.key),
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(color: Colors.grey),
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
                          return "Please enter password";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()),
                            );
                          },
                          child: Text(
                            "Forgot Password ?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20.00),
                    Center(
                      child: SizedBox(
                        height: screenHeight * 0.07,
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Color(primary)),
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(
                                        fontSize: 14, color: Colors.black))),
                            onPressed: () {
                              if (_formfield.currentState!.validate()) {
                                checkPassword();
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
                    ),
                    SizedBox(height: 20.00),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()));
                        },
                        child: Text("Don't have account ? click here",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18.00,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
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
