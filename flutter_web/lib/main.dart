import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Votely',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212), // Darker background
        primaryColor: const Color(0xFFFFF176), // Neon yellow
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE0E0E0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF176), // Neon yellow
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 12,
            shadowColor: Colors.black.withOpacity(0.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.black, width: 3),
            ),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2C2C2C), // Dark card
          elevation: 15,
          shadowColor: Colors.black.withOpacity(0.6),
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: 3),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF00E676), // Neon green
          contentTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          actionTextColor: Colors.white,
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
    _startPolling();
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
      print("Fetched results: $results");
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
        await _fetchAndUpdateResults();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Voted for $candidate!"),
              action: SnackBarAction(
                label: 'CLOSE',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to vote: ${response.body}"),
              backgroundColor: Colors.redAccent,
              action: SnackBarAction(
                label: 'CLOSE',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'CLOSE',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<Map<String, int>> fetchResults() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/results'),
      );
      print("HTTP response status: ${response.statusCode}");
      print("HTTP response body: ${response.body}");
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF121212), const Color(0xFF1A1A1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 20,
                shadowColor: Colors.black.withOpacity(0.7),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "VOTELY",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Color(0xFFFFF176),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isWideScreen ? 32.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "CAST YOUR VOTE",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFF176),
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWideScreen ? 40 : 30),
                      Wrap(
                        spacing: isWideScreen ? 16 : 12,
                        runSpacing: isWideScreen ? 16 : 12,
                        alignment: WrapAlignment.center,
                        children:
                            candidates.map((c) {
                              return SizedBox(
                                width: isWideScreen ? 200 : 160,
                                child: AnimatedButton(
                                  candidate: c,
                                  onPressed: () => sendVote(c),
                                ),
                              );
                            }).toList(),
                      ),
                      SizedBox(height: isWideScreen ? 50 : 40),
                      const Text(
                        "LIVE RESULTS",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFF176),
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWideScreen ? 30 : 20),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StreamBuilder<Map<String, int>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: SizedBox(
                          height: 100,
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFF176),
                            strokeWidth: 6,
                            backgroundColor: Color(0xFF2C2C2C),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "ERROR LOADING RESULTS",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    }
                    final results = snapshot.data!;
                    final totalVotes = results.values.fold(
                      0,
                      (sum, v) => sum + v,
                    );
                    print("Rendering results: $results");
                    return Column(
                      children:
                          candidates.map((candidate) {
                            final votes = results[candidate] ?? 0;
                            final votePercentage =
                                totalVotes > 0
                                    ? (votes / totalVotes * 100)
                                        .toStringAsFixed(1)
                                    : "0.0";
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWideScreen ? 32 : 20,
                                vertical: 8,
                              ),
                              child: ResultCard(
                                candidate: candidate,
                                votes: votes,
                                votePercentage: votePercentage,
                              ),
                            );
                          }).toList(),
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

class AnimatedButton extends StatefulWidget {
  final String candidate;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.candidate,
    required this.onPressed,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: ElevatedButton(
          onPressed: null, // Handled by GestureDetector
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isPressed ? const Color(0xFFD4CA60) : const Color(0xFFFFF176),
            foregroundColor: Colors.black,
            elevation: _isPressed ? 8 : 12,
            shadowColor: Colors.white.withOpacity(0.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.white, width: 3),
            ),
          ),
          child: Text(
            widget.candidate.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String candidate;
  final int votes;
  final String votePercentage;

  const ResultCard({
    super.key,
    required this.candidate,
    required this.votes,
    required this.votePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    candidate.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      "$votes VOTES",
                      key: ValueKey<int>(votes),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E676),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: double.parse(votePercentage) / 100,
                backgroundColor: const Color(0xFF1A1A1A),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFF176),
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                "$votePercentage% of votes",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
