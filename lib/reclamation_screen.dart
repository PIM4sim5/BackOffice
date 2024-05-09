import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Import dart:async for Timer

class ReclamationScreen extends StatefulWidget {
  final Function()? onReclamationAdded;

  ReclamationScreen({Key? key, this.onReclamationAdded}) : super(key: key);

  @override
  _ReclamationScreenState createState() => _ReclamationScreenState();
}

class _ReclamationScreenState extends State<ReclamationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reclamationDescriptionController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  List<Map<String, dynamic>> _reclamations = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchReclamations();
    // Start polling for new reclamations
    _timer = Timer.periodic(Duration(seconds: 30), (Timer t) => fetchReclamations());
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchReclamations() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/reclamations'),
        headers: {
          'x-auth-token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _reclamations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load reclamations');
      }
    } catch (error) {
      print('Error fetching reclamations: $error');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/users'),
        headers: {
          'x-auth-token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<void> createReclamation() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/reclamations'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk',
        },
        body: jsonEncode({
          'reclamationDescription': _reclamationDescriptionController.text,
          'userId': _selectedUserId,
        }),
      );
      if (response.statusCode == 201) {
        // Reclamation created successfully
        print('Reclamation created');
        // Clear the form fields
        _reclamationDescriptionController.clear();
        setState(() {
          _selectedUserId = null;
        });
        // Fetch reclamations after creating new one
        fetchReclamations();
      } else {
        throw Exception('Failed to create reclamation');
      }
    } catch (error) {
      print('Error creating reclamation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.onReclamationAdded?.call();

    return Scaffold(
      appBar: AppBar(
        title: Text('New Reclamation'),
        backgroundColor: Color.fromARGB(255, 4, 85, 234),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/5583046.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _reclamationDescriptionController,
                      maxLines: 4,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Reclamation Description',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                      items: _users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user['_id'].toString(),
                          child: Text(user['name'], style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select User',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 240, 237, 237)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a user';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          createReclamation();
                        }
                      },
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                'Reclamations:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: _reclamations.isEmpty
                    ? Center(
                        child: Text('No reclamations yet', style: TextStyle(color: Colors.white)),
                      )
                    : ListView.builder(
                        itemCount: _reclamations.length,
                        itemBuilder: (context, index) {
                          final reclamation = _reclamations[index];
                          return Card(
                            elevation: 3.0,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            color: Colors.red,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reclamation Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    reclamation['reclamationDescription'],
                                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    'User:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('User: ${reclamation['userId']}', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
