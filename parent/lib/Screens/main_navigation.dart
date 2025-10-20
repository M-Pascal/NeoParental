import 'package:flutter/material.dart';
import './login.dart';
import './record.dart';
import './history.dart';
import './profile.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // List of pages to display
  final List<Widget> _pages = [
    const HomeContentPage(),
    const RecordPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex != 2 && _selectedIndex != 1
          ? AppBar(
              // Hide AppBar for History page (index 2) and Record page (index 1)
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.black87,
                  size: 28,
                ),
                onPressed: () {
                  // Navigate back to login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              centerTitle: true,
              actions: [
                // Notification Icon
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black87,
                    size: 26,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications pressed!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                // Profile Icon
                IconButton(
                  icon: const Icon(
                    Icons.person_outline,
                    color: Colors.black87,
                    size: 26,
                  ),
                  onPressed: () {
                    // Navigate to profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null, // No AppBar for History and Record pages
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
            _buildNavItem(icon: Icons.hearing, label: 'Audio', index: 1),
            _buildNavItem(icon: Icons.history, label: 'History', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
              size: 24,
            ),
            // Show text for all buttons when selected
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Create a separate widget for the home content without scaffold
class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  // Sample history data for statistics
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      duration: const Duration(seconds: 15),
      analysis: 'Hunger',
      confidence: 89,
      status: AnalysisStatus.completed,
    ),
    HistoryItem(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(seconds: 23),
      analysis: 'Discomfort',
      confidence: 76,
      status: AnalysisStatus.completed,
    ),
    HistoryItem(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 2)),
      duration: const Duration(seconds: 18),
      analysis: 'Tired',
      confidence: 82,
      status: AnalysisStatus.completed,
    ),
    HistoryItem(
      id: '4',
      date: DateTime.now().subtract(const Duration(days: 3)),
      duration: const Duration(seconds: 12),
      analysis: 'Pain',
      confidence: 65,
      status: AnalysisStatus.lowConfidence,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text Section (Left Side)
                const Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Welcome to NeoParental\nYour parenting companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Image Section (Right Side)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/family_01.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.family_restroom,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistics Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatisticsSection(),
              ],
            ),
          ),

          const SizedBox(height: 100), // Extra space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'This Week',
            value:
                '${_historyItems.where((item) => item.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}',
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Avg Confidence',
            value: '${_calculateAverageConfidence()}%',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Most Common',
            value: _getMostCommonAnalysis(),
            icon: Icons.analytics,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _calculateAverageConfidence() {
    if (_historyItems.isEmpty) return 0;
    int total = _historyItems.fold(0, (sum, item) => sum + item.confidence);
    return total ~/ _historyItems.length;
  }

  String _getMostCommonAnalysis() {
    if (_historyItems.isEmpty) return 'N/A';
    Map<String, int> analysisCount = {};
    for (var item in _historyItems) {
      analysisCount[item.analysis] = (analysisCount[item.analysis] ?? 0) + 1;
    }
    return analysisCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

// Data models (if not already defined elsewhere)
class HistoryItem {
  final String id;
  final DateTime date;
  final Duration duration;
  final String analysis;
  final int confidence;
  final AnalysisStatus status;

  HistoryItem({
    required this.id,
    required this.date,
    required this.duration,
    required this.analysis,
    required this.confidence,
    required this.status,
  });
}

enum AnalysisStatus { completed, lowConfidence, failed }
