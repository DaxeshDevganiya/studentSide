import 'dart:convert';

import 'package:assignment_student/student/Account.dart';
import 'package:assignment_student/student/Homepage.dart';
import 'package:assignment_student/student/PostAssignment.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:assignment_student/main.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2196F3),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                )),
        title: Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 400, // Card height
          child: PageView.builder(
            itemCount: 4,
            controller: PageController(viewportFraction: 0.8),
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                padding: EdgeInsets.all(_index == index ? 0.0 : 8.0),
                child: Card(
                  elevation: 4,
                  child: Center(child: Text('Card $index')),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
