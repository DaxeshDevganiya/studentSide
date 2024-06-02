import 'dart:convert';

import 'dart:io';

import 'package:assignment_student/domain.dart';
import 'package:assignment_student/student/Homepage.dart';
import 'package:date_field/date_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:assignment_student/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PostAssignment extends StatefulWidget {
  const PostAssignment({super.key});

  @override
  State<PostAssignment> createState() => _PostAssignmentState();
}

class _PostAssignmentState extends State<PostAssignment> {
  bool _isChecked = false;
  final apiUrl = "$apiDomain/post/assignments";
  final _formfield = GlobalKey<FormState>();
  final Assignmentname = TextEditingController();
  Map<String, dynamic>? paymentIntent;
  var clientkey =
      "sk_test_51OyfljGQ4hnFke5n7hOj6jngpiK4Vs0SsjYxwwnisDBn0Co8qnBJwx4I2rz90cD4P70H3YN5lGdxwp2LxiXX65lu00vDXvCmam";

  var selectedDate;
  late File selectedFile;
  bool isSelected = false;
  final price = TextEditingController();
  String industryController = "";
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

  createPaymentIntent(String amount, String currency) async {
    try {
      // TODO: Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      // TODO: POST request to stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ' + clientkey, //SecretKey used here
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(price.text)) * 100;
    return calculatedAmout.toString();
  }

  Future<void> makePayment() async {
    try {
      // TODO: Create Payment intent
      paymentIntent = await createPaymentIntent(price.text, 'CAD');

      // TODO: Initialte Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          applePay: null,
          googlePay: null,
          style: ThemeMode.light,
          merchantDisplayName: 'Task System',
        ),
      )
          .then((value) {
        print("Success" + value.toString());
      });

      // TODO: now finally display payment sheeet
      displayPaymentSheet(); // Payment Sheet
    } catch (e, s) {
      String ss = "exception 1 :$e";
      String s2 = "reason :$s";
      print("exception 1:$e");
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    Text("Payment Successfull"),
                  ],
                ),
              ],
            ),
          ),
        );

        // TODO: update payment intent to null
        paymentIntent = null;
        addAssignment();
      }).onError((error, stackTrace) {
        String ss = "exception 2 :$error";
        String s2 = "reason :$stackTrace";
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      String ss = "exception 3 :$e";
    } catch (e) {
      print('$e');
    }
  }

  Future<void> addAssignment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    String jwtToken = token.toString();
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': jwtToken.toString()
    });
    request.files
        .add(await http.MultipartFile.fromPath('files', selectedFile!.path));
    request.fields['assignmentName'] = Assignmentname.text;
    request.fields['industry'] = industryController;
    request.fields['price'] = price.text;
    request.fields['deadlineDate'] = selectedDate;
    var responseData = await request.send();

    if (responseData.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Assignment Posted Successfully.."),
      ));
    } else if (responseData.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Price Must be Greater than 10"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong please try agian"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = [
      'Web Development',
      'Social media marketing',
      'Mobile solution',
      'Health Care',
      'Mobile Solution'
    ];
    String? selectedItem = 'Web Development';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2196F3),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                )),
        title: Text(
          "Post Assignment",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Form(
                key: _formfield,
                child: Column(
                  children: [
                    // Text("Request for post Assignment",
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 25.0,
                    //       fontWeight: FontWeight.bold,
                    //     )),
                    // SizedBox(height: 20.00),
                    TextFormField(
                      controller: Assignmentname,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        fillColor: const Color.fromRGBO(238, 238, 238, 1),
                        filled: true,
                        hintText: "Assignment Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
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
                          return "Please enter Assignment Name";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    DateTimeFormField(
                      style: TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        fillColor: const Color.fromRGBO(238, 238, 238, 1),
                        filled: true,
                        hintText: 'Enter Date',
                        labelStyle: TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.00)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.00)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                        ),
                      ),
                      mode: DateTimeFieldPickerMode.dateAndTime,
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 7)),
                      initialPickerDateTime:
                          DateTime.now().add(const Duration(days: 1)),
                      onChanged: (DateTime? value) {
                        selectedDate = value.toString();
                      },
                    ),
                    SizedBox(height: 20.00),
                    TextFormField(
                      controller: price,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: "Price",
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
                          return "Please enter a price";
                        }
                      },
                    ),
                    SizedBox(height: 20.00),
                    SizedBox(
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.9,
                      child: OutlinedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust the border radius as needed
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.black))),
                          onPressed: () => _pickFile(),
                          child: Text(
                            "Upload File",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                    ),
                    SizedBox(height: 20.00),
                    DropdownButtonFormField(
                        value: selectedItem,
                        items: items
                            .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    ))))
                            .toList(),
                        onChanged: (item) => setState(() {
                              selectedItem = item;
                              industryController = selectedItem.toString();
                            })),
                    SizedBox(height: 20.00),
                    CheckboxListTile(
                      title: Text('I agree to the terms and conditions'),
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20.00),
                    SizedBox(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.4,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.black))),
                          onPressed: () {
                            if (_formfield.currentState!.validate()) {
                              if (_isChecked) {
                                makePayment();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please agree to the terms and conditions',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              }
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
              ))),
    );
  }
}
