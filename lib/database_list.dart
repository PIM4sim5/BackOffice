import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseList extends StatefulWidget {
  @override
  _DatabaseListState createState() => _DatabaseListState();
}

class _DatabaseListState extends State<DatabaseList> {
  List<Map<String, dynamic>> _databases = [];
  List<Map<String, dynamic>> _filteredDatabases = [];
  final TextEditingController _searchController = TextEditingController();

  final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk';

  @override
  void initState() {
    super.initState();
    fetchDatabases();
  }

  Future<void> fetchDatabases() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/files/databases'),
        headers: {'x-auth-token': authToken},
      );
      if (response.statusCode == 200) {
        setState(() {
          _databases = List<Map<String, dynamic>>.from(json.decode(response.body));
          _filteredDatabases = _databases;
        });
      } else {
        throw Exception('Failed to load databases');
      }
    } catch (error) {
      print('Error fetching databases: $error');
    }
  }

  void _filterDatabases(String query) {
    setState(() {
      _filteredDatabases = _databases.where((database) {
        final name = database['filename'].toString().toLowerCase();
        final uploadedBy = database['uploadedBy'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) || uploadedBy.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _viewDatabaseDetails(Map<String, dynamic> database) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatabaseDetailsScreen(database),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database List'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/5583046.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterDatabases,
                decoration: InputDecoration(
                  labelText: 'Search database',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDatabases.length,
                itemBuilder: (context, index) {
                  final database = _filteredDatabases[index];
                  return Card(
                    color: Colors.blueAccent,
                    child: ListTile(
                      title: Text(database['filename']),
                      subtitle: Text('Uploaded by: ${database['uploadedBy']}'),
                      onTap: () => _viewDatabaseDetails(database),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> database;

  DatabaseDetailsScreen(this.database);

  @override
  _DatabaseDetailsScreenState createState() => _DatabaseDetailsScreenState();
}

class _DatabaseDetailsScreenState extends State<DatabaseDetailsScreen> {
  bool _downloading = false;

  Future<void> _downloadFile() async {
    setState(() {
      _downloading = true;
    });
    final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1Zjg2ZGMzMWYxNjNhMmYwY2JiNGIwOSIsImlhdCI6MTcxMTM5NzY3NH0.Yr4iXbebFdKDuRNNIKPndMC9nuUvOOC7dv_FElbXTQk';

    try {
      final url = 'http://localhost:3000/file/${widget.database['_id']}';
      final response = await http.get(Uri.parse(url),headers: {'x-auth-token': authToken},);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${widget.database['filename']}');
        await file.writeAsBytes(response.bodyBytes);

        // Navigate to file details screen or display success message
      } else {
        print('Failed to download file');
      }
    } catch (error) {
      print('Error downloading file: $error');
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.database['filename']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _downloading ? null : _downloadFile,
              child: _downloading
                  ? CircularProgressIndicator()
                  : Text('Download Database'),
            ),
          ],
        ),
      ),
    );
  }
}
