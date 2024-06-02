import 'dart:convert';

import 'package:assignment_student/domain.dart';
import 'package:assignment_student/main.dart';
import 'package:assignment_student/student/Homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool emailNotification = true;
  bool inAppNotification = true;
  @override
  void initState() {
    super.initState();
    getUserInfo();
    // Fetch previous settings from the backend API when the widget is initialized
  }

  getUserInfo() async {
    const apiUrl = "$apiDomain/getUserInfo";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    String jwtToken = token.toString();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      final emailNotificationString =
          responseData['data']['emailNotification'] ?? 'false';
      emailNotification = emailNotificationString.toLowerCase() == 'true';

      // Convert string to boolean for inAppNotification
      final inAppNotificationString =
          responseData['data']['inAppNotification'] ?? 'false';
      inAppNotification = inAppNotificationString.toLowerCase() == 'true';

      // Update the state
      setState(() {});
    }
  }

  Future<void> _updateNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString("token");
    String jwtToken = token.toString();
    const apiUrl = "$apiDomain/NotificationPreference";
    final response = await http.post(Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token'
        },
        body: jsonEncode({
          "emailNoti": emailNotification.toString(),
          "InappNoti": inAppNotification.toString(),
        }));
    if (response.statusCode == 200) {
      print('Notification settings updated successfully');
    } else {
      print('Failed to update notification settings: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Setting",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Email Notifications'),
                Switch(
                  value: emailNotification,
                  onChanged: (value) {
                    setState(() {
                      emailNotification = value;
                      _updateNotificationSettings();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('In-App Notifications'),
                Switch(
                  value: inAppNotification,
                  onChanged: (value) {
                    setState(() {
                      inAppNotification = value;
                      _updateNotificationSettings();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
