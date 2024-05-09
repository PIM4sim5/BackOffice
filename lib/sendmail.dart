import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendMailPage extends StatefulWidget {
  @override
  _SendMailPageState createState() => _SendMailPageState();
}

class _SendMailPageState extends State<SendMailPage> {
  final TextEditingController _recipientEmailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> sendEmail() async {
    final String recipientEmail = _recipientEmailController.text.trim();
    final String message = _messageController.text.trim();

    final Uri uri = Uri.parse('http://192.168.238.99:3001/send-email');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'recipientEmail': recipientEmail,
      'subject': 'Subject of the email', // You can customize this if needed
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Email'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _recipientEmailController,
              decoration: InputDecoration(labelText: 'Recipient Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Message'),
              maxLines: 8,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: sendEmail,
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
