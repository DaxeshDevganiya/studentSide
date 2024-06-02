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

class FeedbackPage extends StatefulWidget {
  final String aid;
  const FeedbackPage({required this.aid, Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formfield = GlobalKey<FormState>();

  final MessageController = TextEditingController();
  String performance = "";
  void changeUserType(String? value) {
    setState(() {
      performance = value!;
    });
  }

  Future<void> Feedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    String jwtToken = token.toString();
    final apiUrl = "$apiDomain/feedback/${widget.aid}";
    var response = await http.post(Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': jwtToken.toString()
        },
        body: jsonEncode({
          "performanceRating": performance,
          "FeedbackMessage": MessageController.text
        }));
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == 200) {
      print("success");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                )),
        title: Text(
          "Feedback",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formfield,
        child: Column(
          children: [
            SizedBox(height: 20.00),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                child: Column(
                  children: [
                    Text(
                      "Select Your Response",
                      style: TextStyle(color: Colors.black),
                    ),
                    ListTile(
                      title: Text(
                        "Excellent",
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: "Excellent",
                        groupValue: performance,
                        activeColor: Colors.blue,
                        splashRadius: 25,
                        fillColor: MaterialStateProperty.all(Colors.blue),
                        onChanged: changeUserType,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Good",
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: "Good",
                        groupValue: performance,
                        activeColor: Colors.blue,
                        fillColor: MaterialStateProperty.all(Colors.blue),
                        onChanged: changeUserType,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Average",
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: "Average",
                        groupValue: performance,
                        activeColor: Colors.blue,
                        fillColor: MaterialStateProperty.all(Colors.blue),
                        onChanged: changeUserType,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Bad",
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Radio<String>(
                        value: "Bad",
                        groupValue: performance,
                        activeColor: Colors.blue,
                        fillColor: MaterialStateProperty.all(Colors.blue),
                        onChanged: changeUserType,
                      ),
                    ),
                    TextFormField(
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      controller: MessageController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email),
                        hintText: "Response",
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
                          return "Please enter Message";
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
                              Feedback();
                            }
                          },
                          child: Text(
                            "Submit",
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
