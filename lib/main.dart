import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_profile.dart';
import 'database_list.dart';
import 'statistics_screen.dart';
import 'reclamation_screen.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  bool _hasReclamation = false;
  String _selectedUserId = '';
  List<Map<String, dynamic>> _users = [];

  final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> _checkReclamation() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/reclamations/user/$_selectedUserId'),
        headers: {
          'x-auth-token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk',
        },
      );
      if (response.statusCode == 200) {
        final reclamations =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          _hasReclamation = reclamations.isNotEmpty;
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
        headers: {'x-auth-token': authToken},
      );
      if (response.statusCode == 200) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(json.decode(response.body));
          _users.forEach((user) async {
            String userId = user['_id'];
            final reclamationResponse = await http.get(
              Uri.parse('http://localhost:3000/reclamations/user/$userId'),
              headers: {'x-auth-token': authToken},
            );
            if (reclamationResponse.statusCode == 200) {
              final reclamations = List<Map<String, dynamic>>.from(
                  json.decode(reclamationResponse.body));
              bool hasReclamation = reclamations.isNotEmpty;
              setState(() {
                user['hasReclamation'] = hasReclamation;
              });
            } else {
              throw Exception(
                  'Failed to load reclamations for user $userId');
            }
          });
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/users/$id'),
        headers: {'x-auth-token': authToken},
      );
      if (response.statusCode == 200) {
        fetchUsers();
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  void _showUserProfile(Map<String, dynamic> userData) {
    setState(() {
      _selectedUserId = userData['_id'];
    });
    _checkReclamation();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfile(userData),
      ),
    );
  }

  void _navigateToDatabaseList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DatabaseList(),
      ),
    );
  }

  void _navigateToReclamation() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReclamationScreen(
          onReclamationAdded: () {
            fetchUsers();
          },
        ),
      ),
    );
    _checkReclamation();
  }

  void _navigateToStatistics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(),
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required IconData icon,
    required Function onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed as void Function()?,
          iconSize: 50,
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        if (user['hasReclamation'] ?? false)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Icon(
                Icons.error,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserListStats(int activeCount, int inactiveCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                'Active Accounts:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                activeCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(width: 20),
          Column(
            children: [
              Text(
                'Inactive Accounts:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                inactiveCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int activeCount =
        _users.where((user) => user['accountStatus'] ?? false).length;
    int inactiveCount =
        _users.where((user) => !(user['accountStatus'] ?? false)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('ChatDB Admin'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/5583046.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                child: Theme(
                  data: ThemeData(
                    iconTheme: IconThemeData(color: Colors.white),
                    textTheme: TextTheme(
                      bodyText1: TextStyle(color: Colors.white),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavigationButton(
                        text: 'User Management',
                        icon: Icons.person,
                        onPressed: fetchUsers,
                      ),
                      _buildNavigationButton(
                        text: 'Database',
                        icon: Icons.storage,
                        onPressed: _navigateToDatabaseList,
                      ),
                      Image.asset(
                        'assets/1708505867896-logo.png',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      _buildNavigationButton(
                        text: 'Statistics',
                        icon: Icons.analytics,
                        onPressed: _navigateToStatistics,
                      ),
                      _buildNavigationButton(
                        text: 'Reclamation',
                        icon: Icons.report,
                        onPressed: _navigateToReclamation,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildUserListStats(activeCount, inactiveCount),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    elevation: 4.0,
                    child: ListTile(
                      onTap: () => _showUserProfile(_users[index]),
                      leading: _buildUserAvatar(_users[index]),
                      title: Text(_users[index]['name']),
                      subtitle: Text(_users[index]['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete User'),
                                content: Text(
                                    'Are you sure you want to delete this user?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteUser(_users[index]['_id']);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
