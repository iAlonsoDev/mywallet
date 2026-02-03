import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Importa tus otras pantallas
import 'package:mywallet/pages/accounts.dart';
import 'package:mywallet/pages/banks.dart';
import 'package:mywallet/pages/details.dart';
import 'package:mywallet/pages/transactions.dart';
import 'package:mywallet/service/appcache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyWallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  double totalBalance = 0.0;
  double bestRanking = 0.0;
  double totalAvailable = 0.0;
  double lastTransaction = 0.0;
  double topAccount = 0.0;
  String bestBank = "";

  List<Map<String, dynamic>> topBanksData = [];
  List<Map<String, dynamic>> topAccountsData = [];
  List<Map<String, dynamic>> recentTransactions = [];
  List<Map<String, dynamic>> allTransactions = [];

  final cache = AppCache();

  @override
  void initState() {
    super.initState();
    _loadFromCache(forceRefresh: true); // 🔹 primera vez siempre fresco
  }

  Future<void> _loadFromCache({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await cache.loadStaticData(); // 🔹 actualiza cache desde Firestore
    }
    _calculateSummary();
    if (mounted) setState(() {});
  }

  void _calculateSummary() {
    final txs = cache.transactions;

    double totalBalanceTmp = 0;
    double totalAvailableTmp = 0;
    double bestRankingTmp = 0;
    Map<String, double> totalPerBank = {};

    // 🔹 Define los bancos excluidos en una lista
    const excludedBankIds = ["6", "8", "9"];

    for (var t in txs) {
      final amount = (t["amount"] ?? 0.0) as double;
      final bankId = (t["idbank"] ?? "0").toString();
      final summary = (t["summary"] ?? 0.0) as double;

      totalBalanceTmp += amount;
      if (!excludedBankIds.contains(bankId)) {
        totalAvailableTmp += amount;
      }

      if (summary > bestRankingTmp) bestRankingTmp = summary;

      totalPerBank.update(
        bankId,
        (val) => val + amount,
        ifAbsent: () => amount,
      );
    }

    totalBalance = totalBalanceTmp;
    totalAvailable = totalAvailableTmp;
    bestRanking = bestRankingTmp;

    if (txs.isNotEmpty) {
      txs.sort(
        (a, b) => (b["date"] as DateTime).compareTo(a["date"] as DateTime),
      );
      lastTransaction = txs.first["amount"];
      recentTransactions = txs.take(5).toList();
    }

    topBanksData =
        totalPerBank.entries
            .map(
              (e) => {
                "namebank": cache.getBankName(e.key),
                "totalAmount": e.value,
              },
            )
            .toList()
          ..sort(
            (a, b) => (b["totalAmount"] as double).compareTo(
              a["totalAmount"] as double,
            ),
          );

    if (topBanksData.isNotEmpty) {
      bestBank = topBanksData.first["namebank"];
      topAccount = topBanksData.first["totalAmount"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            _loadFromCache(); // 🔹 usa cache, no siempre Firestore
          }
        },
        children: [
          _buildHomePage(), // index 0
          const Banks(), // index 1
          const Accounts(), // index 2
          const Transactions(), // index 3
          const Details(), // index 4
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 3),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.money), 
            label: "Home",
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Banks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.percent),
            label: "Performance",
          ),
        ],
      ),
    );
  }

  /// 🔹 Página principal
  Widget _buildHomePage() {
    return SafeArea(
      child: RefreshIndicator(
        //onRefresh: _fetchAll,
        onRefresh: () => _loadFromCache(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "MyWallet",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 84, 135, 180),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _loadFromCache(forceRefresh: true),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 84, 135, 180),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Total Balance",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatAmount(totalBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${(((totalBalance / bestRanking) - 1) * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Best Performance: $bestBank",
                      style: const TextStyle(
                        color: Color.fromARGB(179, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // KPIs
              Row(
                children: [
                  _kpiCard("Best Ranking", formatAmount(bestRanking)),
                  const SizedBox(width: 12),
                  _kpiCard("Available", formatAmount(totalAvailable)),
                  const SizedBox(width: 12),
                  _kpiCard(
                    "Difference",
                    formatAmount(totalBalance - bestRanking),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              if (topBanksData.isNotEmpty)
                _barChart("Top Banks", topBanksData, "namebank"),

              const SizedBox(height: 25),

              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...recentTransactions.map(
                (tx) => _transactionTile(
                  tx["details"],
                  tx["amount"],
                  tx["amount"] >= 0 ? Colors.green : Colors.red,
                  tx["date"],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Widgets ===
  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: "en_US", symbol: "L. ");
    String result = formatter.format(amount);
    if (result == "-L. 0.00") return "L. 0.00";
    return result;
  }

  Widget _kpiCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barChart(
    String title,
    List<Map<String, dynamic>> data,
    String labelKey,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final bank = topBanksData[group.x.toInt()]["namebank"];
                      return BarTooltipItem(
                        '$bank\n',
                        const TextStyle(color: Colors.white, fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                            text: formatAmount(rod.toY),
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= topBanksData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            topBanksData[index]["namebank"],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups:
                    data
                        .take(5)
                        .map(
                          (e) => BarChartGroupData(
                            x: data.indexOf(e),
                            barRods: [
                              BarChartRodData(
                                toY: double.parse(
                                  (e["totalAmount"] as double).toStringAsFixed(
                                    2,
                                  ),
                                ),
                                color: const Color.fromARGB(255, 84, 135, 180),
                                width: 15,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(
    String title,
    double amount,
    Color color,
    DateTime date,
  ) {
    final formattedDate = DateFormat("yyyy-MM-dd hh:mm a").format(date);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            // ignore: deprecated_member_use
            backgroundColor: color.withOpacity(0.15),
            child: Icon(Icons.swap_horiz, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            (amount >= 0 ? "+ " : "- ") + formatAmount(amount.abs()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
