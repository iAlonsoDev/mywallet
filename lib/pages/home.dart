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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 11,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance),
              label: "Banks",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: "Accounts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined),
              activeIcon: Icon(Icons.swap_horiz),
              label: "Transactions",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: "Details",
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Página principal
  Widget _buildHomePage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadFromCache(forceRefresh: true),
        color: Colors.blue[700],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header moderno con gradiente
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "MyWallet",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "Financial Dashboard",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _loadFromCache(forceRefresh: true),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Balance Card compacto
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Balance",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatAmount(totalBalance),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: totalBalance >= 0 ? Colors.green[700] : Colors.red[700],
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: totalBalance >= 0
                                        ? [Colors.green[50]!, Colors.green[100]!]
                                        : [Colors.red[50]!, Colors.red[100]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  totalBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                                  color: totalBalance >= 0 ? Colors.green[700] : Colors.red[700],
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(height: 1, color: Colors.grey[200]),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(Icons.star, color: Colors.blue[700], size: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Best Performance",
                                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                                      ),
                                      Text(
                                        bestBank.isEmpty ? "N/A" : bestBank,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange[50]!, Colors.orange[100]!],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange[200]!, width: 1),
                                ),
                                child: Text(
                                  "${bestRanking > 0 ? (((totalBalance / bestRanking) - 1) * 100).toStringAsFixed(0) : '0'}%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPIs modernos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _kpiCard(
                      "Best Ranking",
                      formatAmount(bestRanking),
                      Icons.emoji_events_outlined,
                      Colors.purple,
                    ),
                    const SizedBox(width: 10),
                    _kpiCard(
                      "Available",
                      formatAmount(totalAvailable),
                      Icons.account_balance_wallet_outlined,
                      Colors.teal,
                    ),
                    const SizedBox(width: 10),
                    _kpiCard(
                      "Difference",
                      formatAmount(totalBalance - bestRanking),
                      Icons.swap_horiz,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Top Banks Chart
              if (topBanksData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _barChart("Top Banks", topBanksData, "namebank"),
                ),

              const SizedBox(height: 20),

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recentTransactions.map(
                    (tx) => _transactionTile(
                      tx["details"],
                      tx["amount"],
                      tx["amount"] >= 0 ? Colors.green : Colors.red,
                      tx["date"],
                    ),
                  ).toList(),
                ),
              ),
              const SizedBox(height: 20),
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

  Widget _kpiCard(String label, String value, IconData icon, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color[700], size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[900],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart, color: Colors.blue[700], size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                                gradient: LinearGradient(
                                  colors: [Colors.blue[400]!, Colors.blue[700]!],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 16,
                                borderRadius: BorderRadius.circular(8),
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
    final formattedDate = DateFormat("MMM dd, yyyy · hh:mm a").format(date);
    final isPositive = amount >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: isPositive
                      ? [Colors.green[50]!, Colors.green[100]!]
                      : [Colors.red[50]!, Colors.red[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isPositive ? Colors.green[200]! : Colors.red[200]!,
                  width: 1,
                ),
              ),
              child: Icon(
                isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPositive ? Colors.green[700] : Colors.red[700],
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${isPositive ? '+ ' : '- '}${formatAmount(amount.abs())}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPositive ? Colors.green[800] : Colors.red[800],
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
