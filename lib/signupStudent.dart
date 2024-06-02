import 'dart:convert';
import 'dart:io';

import 'package:assignment_student/EmailPage.dart';
import 'package:assignment_student/domain.dart';
import 'package:assignment_student/login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:assignment_student/main.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  ValueNotifier userCredential = ValueNotifier('');
  final apiUrl = "$apiDomain/signup";
  final apiGoogle = "$apiDomain/google/signup";
  final _formfield = GlobalKey<FormState>();
  final fistnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final contactController = TextEditingController();
  late File selectedFile;
  bool isSelected = false;
  String userType = "student";
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        isSelected = true;
        selectedFile = File(result.files.single.path!);
        // print("SELECTED FILE ${_selectedFile}");
        // print("Selected File: $_selectedFile");
      });
    } else {
      setState(() {
        selectedFile;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger Google sign-in flow

      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('User canceled sign-in');
        return;
      }
      // Get authentication details
      final googleAuth = await googleUser.authentication;
      print('Google Auth: $googleAuth');
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // print('idToken: ${credential.idToken}');
      // Make a POST request to your API endpoint
      final response = await http.post(
        Uri.parse(apiGoogle), // Replace with your API endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"idToken": googleAuth.idToken}),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Handle successful sign-up, e.g., navigate to  home screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("done"),
          ),
        );
      } else {
        // Handle API error
        print('Error signing up with Google: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing up with Google'),
          ),
        );
      }
    } catch (error) {
      // Handle sign-in error
      print('Error signing in with Google: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  Future<void> addUser() async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });
    request.files
        .add(await http.MultipartFile.fromPath('files', selectedFile!.path));
    request.fields['firstname'] = fistnameController.text;
    request.fields['lastname'] = lastnameController.text;
    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['contact'] = contactController.text;
    request.fields['role'] = userType;
    request.fields['industry'] = "-";
    var responseData = await request.send();
    // body: jsonEncode({
    //   "firstname": ,
    //   "lastname":,
    //   "email": ,
    //   "password": ,
    //   "contact": ,
    //   "role": userType,
    //   "industry": "-",
    // }));

    // var data=jsonDecode(response.body.toString());
    if (responseData.statusCode == 200) {
      // var responseData = jsonDecode(response.body);

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(responseData['message']),
      // ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("SignUp Successfully..."),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Email()),
      );
    } else {
      // var responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong please try agian"),
      ));
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(responseData['message'].toString()),
      // ));
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
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(120),
                  )),
              child: Center(
                child: Text("Sign Up",
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
                      controller: fistnameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        suffixIcon: Icon(Icons.text_format),
                        hintText: "FirstName",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter firstname";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      controller: lastnameController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.text_format),
                        hintText: "LastName",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Lastname";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email),
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter email";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.password),
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Password";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      controller: contactController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.contacts),
                        hintText: "Contact",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        labelStyle: new TextStyle(color: Colors.blue),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Contact";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.9,
                      child: OutlinedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust the border radius as needed
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.grey.shade200),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.black))),
                          onPressed: () => _pickFile(),
                          child: Text(
                            "Upload Profile Picture",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                    ),
                    SizedBox(height: 20.00),
                    SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.6,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.white))),
                          onPressed: () {
                            if (_formfield.currentState!.validate()) {
                              addUser();
                            }
                          },
                          child: Text(
                            "SignUp",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                    ),
                    SizedBox(height: 20.00),
                    Divider(),
                    SizedBox(height: 10.00),
                    SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.6,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.white))),
                          onPressed: () async {
                            // userCredential.value = await _signInWithGoogle();
                            // if (userCredential.value != null)
                            //   print(userCredential.value.user!.email);
                            _signInWithGoogle();
                          },
                          child: Text(
                            "Signup With Google",
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
                            MaterialPageRoute(builder: (context) => Email()));
                      },
                      child: Text("Already have account ? click here",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18.00,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    SizedBox(height: 20.00),
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
