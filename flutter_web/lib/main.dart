import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Votely',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Dark background
        primaryColor: const Color(0xFFFFF176), // Neon yellow accent
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF176), // Neon yellow
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            elevation: 8,
            shadowColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp edges
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF2C2C2C), // Dark card background
          elevation: 10,
          shadowColor: Colors.black,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VotingPage(),
    );
  }
}

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final candidates = ["Alice", "Bob", "Charlie"];
  final _streamController = StreamController<Map<String, int>>.broadcast();

  @override
  void initState() {
    super.initState();
    // Start periodic fetching
    _startPolling();
    // Initial fetch
    _fetchAndUpdateResults();
  }

  void _startPolling() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_streamController.isClosed) {
        timer.cancel();
        return;
      }
      await _fetchAndUpdateResults();
    });
  }

  Future<void> _fetchAndUpdateResults() async {
    final results = await fetchResults();
    if (!_streamController.isClosed) {
      print("Fetched results: $results"); // Debug log
      _streamController.add(results);
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> sendVote(String candidate) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'candidate': candidate}),
      );

      if (response.statusCode == 200) {
        // Immediately fetch and update results
        await _fetchAndUpdateResults();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Voted for $candidate!",
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
              backgroundColor: const Color(0xFF00E676), // Neon green
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to vote: ${response.body}",
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: $e",
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        );
      }
    }
  }

  Future<Map<String, int>> fetchResults() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/results'));
      print("HTTP response status: ${response.statusCode}"); // Debug log
      print("HTTP response body: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, int>.from(data['results']);
      }
    } catch (e) {
      print("Error fetching results: $e");
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "VOTELY",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C2C2C), // Dark app bar
        elevation: 10,
        shadowColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "CAST YOUR VOTE",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF176), // Neon yellow
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: candidates.map((c) {
                return SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () => sendVote(c),
                    child: Text(
                      c.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text(
              "LIVE RESULTS",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF176), // Neon yellow
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<Map<String, int>>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFF176),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text(
                        "ERROR LOADING RESULTS",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  }
                  final results = snapshot.data!;
                  print("Rendering results: $results"); // Debug log
                  return ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      final votes = results[candidate] ?? 0;
                      return Card(
                        elevation: 10,
                        shadowColor: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                candidate.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$votes VOTES",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E676), // Neon green
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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