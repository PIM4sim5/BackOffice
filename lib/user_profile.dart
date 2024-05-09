import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfile extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserProfile(this.userData);

  Future<void> sendActivationEmail() async {
    final String recipientEmail = userData['email'];
    final String message = 'Please activate your account';

    final Uri uri = Uri.parse('http://172.16.3.151:3001/send-email');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'recipientEmail': recipientEmail,
      'subject': 'Activate Your Account',
      'message': message,
    };

    try {
      final http.Response response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        print('Email sent successfully');
        // Optionally, you can show a success message to the user
      } else {
        print('Failed to send email');
        // Optionally, you can show an error message to the user
      }
    } catch (e) {
      print('Error: $e');
      // Handle any errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accountStatusColor =
        userData['accountStatus'] ?? false ? Color.fromARGB(255, 237, 233, 233) : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/5583046.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name: ${userData['name']}',
                    style: TextStyle(fontSize: 18.0, color: Colors.white), // Changed color to white
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${userData['email']}',
                    style: TextStyle(fontSize: 18.0, color: Colors.white), // Changed color to white
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Activation Code: ${userData['activationCode'] ?? 'Not Available'}',
                    style: TextStyle(fontSize: 18.0, color: Colors.white), // Changed color to white
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Account Status: ${userData['accountStatus'] ?? false ? 'Activated' : 'Not Activated'}',
                    style: TextStyle(fontSize: 18.0, color: accountStatusColor),
                  ),
                  if (!(userData['accountStatus'] ?? false)) SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!(userData['accountStatus'] ?? false)) {
                        sendActivationEmail();
                      }
                    },
                    child: Text('Send Mail to Activate Account', style: TextStyle(color: const Color.fromARGB(255, 224, 7, 7))), // Changed color to white
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Back to Home', style: TextStyle(color: Colors.white)), // Changed color to white
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
