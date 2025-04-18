import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;

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
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFFFD700),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB0B0B0),
          ),
          labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1A1A1A),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF00E676),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          actionTextColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
          hintStyle: const TextStyle(color: Color(0xFF606060)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Vote',
      'icon': Icons.how_to_vote,
      'page': const VotingPage(),
    },
    {
      'title': 'Results',
      'icon': Icons.bar_chart,
      'page': const ResultsPage(),
    },
    {
      'title': 'Add Candidate',
      'icon': Icons.person_add,
      'page': const AddCandidatePage(),
    },
  ];

  void _switchToResults() {
    setState(() {
      _currentIndex = 1; // Results page index
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        return Scaffold(
          body: Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  backgroundColor: const Color(0xFF1A1A1A),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w500,
                  ),
                  destinations: _pages
                      .map((page) => NavigationRailDestination(
                            icon: Icon(page['icon'], color: const Color(0xFFB0B0B0)),
                            selectedIcon: Icon(page['icon'], color: const Color(0xFFFFD700)),
                            label: Text(page['title']),
                          ))
                      .toList(),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _pages[_currentIndex]['page'],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWideScreen
              ? null
              : BottomNavigationBar(
                  backgroundColor: const Color(0xFF1A1A1A),
                  selectedItemColor: const Color(0xFFFFD700),
                  unselectedItemColor: const Color(0xFFB0B0B0),
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: _pages
                      .map((page) => BottomNavigationBarItem(
                            icon: Icon(page['icon']),
                            label: page['title'],
                          ))
                      .toList(),
                ),
        );
      },
    );
  }
}

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final String serverUrl = 'http://192.168.29.80:5000';
  List<String> candidates = [];
  final _streamController = StreamController<List<String>>.broadcast();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPollingCandidates();
    _fetchAndUpdateCandidates();
  }

  void _startPollingCandidates() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_streamController.isClosed) {
        timer.cancel();
        return;
      }
      await _fetchAndUpdateCandidates();
    });
  }

  Future<void> _fetchAndUpdateCandidates() async {
    final results = await fetchResults();
    if (!_streamController.isClosed) {
      candidates = results.keys.toList();
      _streamController.add(candidates);
      setState(() => _errorMessage = null);
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
        Uri.parse('$serverUrl/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'candidate': candidate}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Voted for $candidate!"),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to vote: ${jsonDecode(response.body)['message']}"),
              backgroundColor: Colors.redAccent,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
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
            content: Text("Error voting: $e"),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<Map<String, int>> fetchResults() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/results'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, int>.from(data['results']);
      }
    } catch (e) {
      print("Error fetching results: $e");
    }
    return {};
  }

  Future<void> shutdownServer() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/shutdown'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Server shutting down..."),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          // Delay to ensure totalvotes.json is saved
          await Future.delayed(const Duration(seconds: 1));
          final homePageState = context.findAncestorStateOfType<_HomePageState>();
          homePageState?._switchToResults();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to shutdown: ${jsonDecode(response.body)['message']}"),
              backgroundColor: Colors.redAccent,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
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
            content: Text("Error shutting down: $e"),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        final gridCrossAxisCount = isWideScreen ? 4 : 2;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Votely - Vote'),
            centerTitle: true,
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 2,
            foregroundColor: Colors.white,
          ),
          body: Container(
            color: const Color(0xFF0A0A0A),
            padding: EdgeInsets.all(isWideScreen ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Cast Your Vote',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD700),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      final currentCandidates = snapshot.hasData ? snapshot.data! : candidates;
                      if (currentCandidates.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No candidates available',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB0B0B0),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  final homePageState = context.findAncestorStateOfType<_HomePageState>();
                                  homePageState?.setState(() {
                                    homePageState._currentIndex = 2;
                                  });
                                },
                                child: const Text('Add Candidates'),
                              ),
                            ],
                          ),
                        );
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: currentCandidates.length,
                        itemBuilder: (context, index) {
                          final candidate = currentCandidates[index];
                          return AnimatedButton(
                            candidate: candidate,
                            onPressed: () => sendVote(candidate),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: shutdownServer,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text('Close Server'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final String serverUrl = 'http://192.168.29.80:5000';
  final _streamController = StreamController<Map<String, int>>.broadcast();
  String? _errorMessage;
  String? _winner;
  bool _isServerShutdown = false;
  Map<String, int> _lastResults = {};

  @override
  void initState() {
    super.initState();
    _startPolling();
    _fetchAndUpdateResults();
  }

  void _startPolling() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_streamController.isClosed || _isServerShutdown) {
        timer.cancel();
        return;
      }
      await _fetchAndUpdateResults();
    });
  }

  Future<void> _fetchAndUpdateResults() async {
    final results = await fetchResults();
    if (!_streamController.isClosed) {
      if (results.isNotEmpty) {
        _lastResults = results; // Cache results
        _streamController.add(results);
        setState(() {
          _errorMessage = null;
          if (results.isNotEmpty) {
            final maxVotes = results.values.reduce((a, b) => a > b ? a : b);
            _winner = results.entries.firstWhere((entry) => entry.value == maxVotes).key;
          } else {
            _winner = null;
          }
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch results";
          _winner = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<Map<String, int>> fetchResults() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/results'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, int>.from(data['results']);
      } else {
        print("Error fetching results: ${jsonDecode(response.body)['message']}");
        setState(() => _isServerShutdown = true);
      }
    } catch (e) {
      print("Error fetching results: $e");
      setState(() => _isServerShutdown = true);
    }
    return _lastResults; // Return cached results on failure
  }

  void _exitApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Exit Votely',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (kIsWeb) {
                html.window.close();
              } else {
                SystemNavigator.pop();
              }
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        final cardWidth = isWideScreen ? 400.0 : constraints.maxWidth * 0.9;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Votely - Results'),
            centerTitle: true,
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 2,
            foregroundColor: Colors.white,
          ),
          body: Container(
            color: const Color(0xFF0A0A0A),
            padding: EdgeInsets.all(isWideScreen ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isServerShutdown ? 'Final Results' : 'Live Results',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD700),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null && !_isServerShutdown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_isServerShutdown && _winner != null)
                  Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: Card(
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFE6C200)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Winner: ${_winner!.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_isServerShutdown && _winner == null)
                  const Center(
                    child: Text(
                      'No votes recorded',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<Map<String, int>>(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                            strokeWidth: 4,
                          ),
                        );
                      }
                      final results = _isServerShutdown ? _lastResults : (snapshot.data ?? _lastResults);
                      if (results.isEmpty && !_isServerShutdown) {
                        return const Center(
                          child: Text(
                            'No results available',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB0B0B0),
                            ),
                          ),
                        );
                      }
                      final totalVotes = results.values.fold(0, (sum, v) => sum + v);
                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final candidate = results.keys.elementAt(index);
                          final votes = results[candidate] ?? 0;
                          final votePercentage = totalVotes > 0
                              ? (votes / totalVotes * 100).toStringAsFixed(1)
                              : "0.0";
                          return Center(
                            child: SizedBox(
                              width: cardWidth,
                              child: ResultCard(
                                candidate: candidate,
                                votes: votes,
                                votePercentage: votePercentage,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_isServerShutdown) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _exitApp,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 2),
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text('Exit App'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddCandidatePage extends StatefulWidget {
  const AddCandidatePage({super.key});

  @override
  _AddCandidatePageState createState() => _AddCandidatePageState();
}

class _AddCandidatePageState extends State<AddCandidatePage> {
  final String serverUrl = 'http://192.168.29.80:5000';
  final _formKey = GlobalKey<FormState>();
  final _candidateController = TextEditingController();
  String? _errorMessage;

  Future<void> addCandidate() async {
    if (!_formKey.currentState!.validate()) return;

    final candidate = _candidateController.text.trim();
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/add_candidate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'candidate': candidate}),
      );

      if (response.statusCode == 200) {
        _candidateController.clear();
        setState(() => _errorMessage = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Added $candidate!"),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = jsonDecode(response.body)['message']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to add candidate: ${jsonDecode(response.body)['message']}"),
              backgroundColor: Colors.redAccent,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = "Error adding candidate: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding candidate: $e"),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _candidateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        final formWidth = isWideScreen ? 400.0 : constraints.maxWidth * 0.9;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Votely - Add Candidate'),
            centerTitle: true,
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 2,
            foregroundColor: Colors.white,
          ),
          body: Container(
            color: const Color(0xFF0A0A0A),
            padding: EdgeInsets.all(isWideScreen ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add New Candidate',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD700),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Center(
                  child: SizedBox(
                    width: formWidth,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _candidateController,
                            decoration: const InputDecoration(
                              labelText: 'Candidate Name',
                              hintText: 'Enter candidate name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a candidate name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: addCandidate,
                            child: const Text('Add Candidate'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: _isHovered
                  ? [const Color(0xFFFFD700), const Color(0xFFE6C200)]
                  : [const Color(0xFF1A1A1A), const Color(0xFF2C2C2C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.2 : 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: InkWell(
              onTap: null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    widget.candidate.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _isHovered ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
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
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  candidate.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    '$votes Votes',
                    key: ValueKey<int>(votes),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00E676),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: double.parse(votePercentage) / 100,
              backgroundColor: const Color(0xFF2C2C2C),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD700),
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$votePercentage% of votes',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}