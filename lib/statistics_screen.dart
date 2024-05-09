import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _conversations = [];

  final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk'; // Replace with your authentication token

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/conversations'),
        headers: {'x-auth-token': authToken},
      );
      if (response.statusCode == 200) {
        setState(() {
          _conversations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (error) {
      print('Error fetching conversations: $error');
    }
  }

  String categorizeConversation(String userInput) {
    // Convert the userInput to lowercase for case-insensitive matching
    userInput = userInput.toLowerCase();

    // Salutation keywords
    if (userInput.contains('hello') || userInput.contains('hi')) {
      return 'Salutation';
    }

    // Database Information keywords
    if (userInput.contains('database') ||
        userInput.contains('name of the base') ||
        userInput.contains('name of the database') ||
        userInput.contains('name of this file') ||
        userInput.contains('available databases') ||
        userInput.contains('names of the tables') ||
        userInput.contains('show me customers table') ||
        userInput.contains('content of the table') ||
        userInput.contains('elements of the table') ||
        userInput.contains('referring to this database table') ||
        userInput.contains('sample-sql-file-10-rows.sql') ||
        userInput.contains('content of this database') ||
        userInput.contains('give me users for this database') ||
        userInput.contains('informations in this database')) {
      return 'Database Information';
    }

    // Action Requests keywords
    if (userInput.contains('what can you do for me') ||
        userInput.contains('export these data') ||
        userInput.contains('statistics on the table customers') ||
        userInput.contains('statistics as a chart') ||
        userInput.contains('download link') ||
        userInput.contains('generate the file') ||
        userInput.contains('generate the link') ||
        userInput.contains('analysis in chart form') ||
        userInput.contains('statistics in chart form') ||
        userInput.contains('generate a statistic for the table customers') ||
        userInput.contains('show me the tables') ||
        userInput.contains('chart for the table cars') ||
        userInput.contains('chart for the table customers')) {
      return 'Action Requests';
    }

    // Data Analysis Requests keywords
    if (userInput.contains('export these data in an html file') ||
        userInput.contains('detailed analysis') ||
        userInput.contains('statistics as a graph') ||
        userInput.contains('chart for the table cars') ||
        userInput.contains('chart for the table customers') ||
        userInput.contains('number of customers by name')) {
      return 'Data Analysis Requests';
    }

    // Miscellaneous keywords
    if (userInput.contains('how old are you') ||
        userInput.contains('else') ||
        userInput.contains('informations on customers') ||
        userInput.contains('what is in the base') ||
        userInput.contains('what is in the base of the data') ||
        userInput.contains('graph statistic')) {
      return 'Miscellaneous';
    }

    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> questionFrequency = {};
    Map<String, List<String>> categorizedQuestions = {};

    for (var conversation in _conversations) {
      String? userInput = conversation['user_input'];
      if (userInput != null) {
        questionFrequency[userInput] = (questionFrequency[userInput] ?? 0) + 1;
        String category = categorizeConversation(userInput);
        categorizedQuestions.putIfAbsent(category, () => []);
        categorizedQuestions[category]?.add(userInput);
      }
    }

    List<MapEntry<String, int>> sortedQuestions =
        questionFrequency.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    int totalQuestions = _conversations.length;
    int uniqueQuestions = questionFrequency.length;
    int mostFrequentQuestionCount = sortedQuestions.isNotEmpty
        ? sortedQuestions.first.value
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/5583046.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Most Asked Questions:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedQuestions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sortedQuestions[index].key,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Frequency: ${sortedQuestions[index].value}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Conversation Categories:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: categorizedQuestions.length,
                  itemBuilder: (context, index) {
                    String category = categorizedQuestions.keys.toList()[index];
                    List<String> questions = categorizedQuestions[category] ?? [];
                    return Card(
                      color: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: questions.map((question) {
                                return Text(
                                  question,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('All Questions'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _conversations
                                .map((conversation) =>
                                    Text(conversation['user_input'] ?? ''))
                                .toList(),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Questions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '$totalQuestions',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unique Questions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '$uniqueQuestions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Most Frequent',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '$mostFrequentQuestionCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
