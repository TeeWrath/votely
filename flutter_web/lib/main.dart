import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Voting',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const VotingPage(),
    );
  }
}

class VotingPage extends StatelessWidget {
  const VotingPage({super.key});

  Future<void> sendVote(String candidate) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/vote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'candidate': candidate}),
    );

    if (response.statusCode == 200) {
      print("Vote sent!");
    } else {
      print("Failed to vote: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidates = ["Alice", "Bob", "Charlie"];

    return Scaffold(
      appBar: AppBar(title: const Text("Vote for Your Candidate")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: candidates.map((c) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  sendVote(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Voted for $c")),
                  );
                },
                child: Text("Vote for $c"),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
