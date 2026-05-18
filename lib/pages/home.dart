import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:mywallet/pages/accounts.dart';
import 'package:mywallet/pages/banks.dart';
import 'package:mywallet/pages/details.dart';
import 'package:mywallet/pages/transactions.dart';
import 'package:mywallet/service/appcache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.bottom],
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
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
  bool _isLoading = false;

  double totalBalance = 0.0;
  double bestRanking = 0.0;
  double totalAvailable = 0.0;
  double topAccount = 0.0;
  String bestBank = "";

  List<Map<String, dynamic>> topBanksData = [];
  List<Map<String, dynamic>> recentTransactions = [];

  final cache = AppCache();

  static const _bankGradients = [
    [Color(0xFF6366F1), Color(0xFF4338CA)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFF06B6D4), Color(0xFF0891B2)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
  ];

  static const _chartColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    _loadFromCache(forceRefresh: true);
  }

  Future<void> _loadFromCache({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    if (forceRefresh) await cache.loadStaticData();
    _calculateSummary();
    if (mounted) setState(() => _isLoading = false);
  }

  void _calculateSummary() {
    final txs = cache.transactions;

    double totalBalanceTmp = 0;
    double totalAvailableTmp = 0;
    double bestRankingTmp = 0;
    Map<String, double> totalPerBank = {};

    const excludedBankIds = ["6", "8", "9"];

    for (var t in txs) {
      final amount = (t["amount"] ?? 0.0) as double;
      final bankId = (t["idbank"] ?? "0").toString();
      final summary = (t["summary"] ?? 0.0) as double;

      totalBalanceTmp += amount;
      if (!excludedBankIds.contains(bankId)) totalAvailableTmp += amount;
      if (summary > bestRankingTmp) bestRankingTmp = summary;

      totalPerBank.update(bankId, (v) => v + amount, ifAbsent: () => amount);
    }

    totalBalance = totalBalanceTmp;
    totalAvailable = totalAvailableTmp;
    bestRanking = bestRankingTmp;

    if (txs.isNotEmpty) {
      txs.sort((a, b) => (b["date"] as DateTime).compareTo(a["date"] as DateTime));
      recentTransactions = txs.take(5).toList();
    }

    topBanksData = totalPerBank.entries
        .where((e) => cache.getBankStatus(e.key) == "1" && e.value != 0)
        .map((e) => {"namebank": cache.getBankName(e.key), "totalAmount": e.value})
        .toList()
      ..sort((a, b) => (b["totalAmount"] as double).compareTo(a["totalAmount"] as double));

    if (topBanksData.length > 5) topBanksData = topBanksData.sublist(0, 5);

    if (topBanksData.isNotEmpty) {
      bestBank = topBanksData.first["namebank"] as String;
      topAccount = topBanksData.first["totalAmount"] as double;
    }
  }

  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: "en_US", symbol: "L. ");
    final result = formatter.format(amount);
    return result == "-L. 0.00" ? "L. 0.00" : result;
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF1F5F9),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) _loadFromCache();
        },
        children: [
          _buildHomePage(),
          const Banks(),
          const Accounts(),
          const Transactions(),
          const Details(),
        ],
      ),
      bottomNavigationBar: _buildFloatingNav(),
    );
  }

  // ─── Floating Nav ─────────────────────────────────────────────────────────

  Widget _buildFloatingNav() {
    const items = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
      _NavItem(Icons.account_balance_outlined, Icons.account_balance_rounded, 'Banks'),
      _NavItem(Icons.account_circle_outlined, Icons.account_circle_rounded, 'Accounts'),
      _NavItem(Icons.swap_horiz_outlined, Icons.swap_horiz_rounded, 'Moves'),
      _NavItem(Icons.analytics_outlined, Icons.analytics_rounded, 'Details'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.55),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemW = constraints.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _currentIndex * itemW + 6,
                  top: 8,
                  child: Container(
                    width: itemW - 12,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: List.generate(items.length, (i) {
                    final active = _currentIndex == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentIndex = i);
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 3),
                          curve: Curves.easeInOut,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: itemW,
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              active ? items[i].activeIcon : items[i].icon,
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                              size: 22,
                            ),
                            if (active) ...[
                              const SizedBox(height: 3),
                              Text(
                                items[i].label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Home page ────────────────────────────────────────────────────────────

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: () => _loadFromCache(forceRefresh: true),
      color: Colors.blue,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHero(),
            Transform.translate(
              offset: const Offset(0, -100),
              child: Column(
                children: [
                  _buildKpiRow(),
                  const SizedBox(height: 22),
                  _buildBankCardsSection(),
                  const SizedBox(height: 22),
                  if (topBanksData.isNotEmpty) _buildDonutSection(),
                  const SizedBox(height: 22),
                  _buildTransactionsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero (dark gradient) ─────────────────────────────────────────────────

  Widget _buildHero() {
    final isPositive = totalBalance >= 0;
    final pct = bestRanking > 0
        ? (((totalBalance / bestRanking) - 1) * 100).toStringAsFixed(1)
        : '0.0';

    return ClipPath(
      clipper: _HeroClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              // ── Header row ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'MyWallet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _loadFromCache(forceRefresh: true),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Balance label ──
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),

              // ── Balance amount + trend pill ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      formatAmount(totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: (isPositive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: isPositive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            color: isPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Best bank pill ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF59E0B), size: 15),
                    const SizedBox(width: 8),
                    Text(
                      'Best: ${bestBank.isEmpty ? "—" : bestBank}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                        width: 1,
                        height: 12,
                        color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(width: 10),
                    Text(
                      formatAmount(topAccount),
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── KPI row (overlapping hero) ───────────────────────────────────────────

  Widget _buildKpiRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _kpiCard('Best Ranking', formatAmount(bestRanking),
              Icons.emoji_events_rounded,
              const Color(0xFF8B5CF6), const Color(0xFF6D28D9)),
          const SizedBox(width: 10),
          _kpiCard('Available', formatAmount(totalAvailable),
              Icons.account_balance_wallet_rounded,
              const Color(0xFF06B6D4), const Color(0xFF0891B2)),
          const SizedBox(width: 10),
          _kpiCard('Difference', formatAmount(totalBalance - bestRanking),
              Icons.swap_horiz_rounded,
              const Color(0xFFEF4444), const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color c1, Color c2) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: c1.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c1.withValues(alpha: 0.2), c2.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c1.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: c1, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Horizontal bank cards ────────────────────────────────────────────────

  Widget _buildBankCardsSection() {
    if (topBanksData.isEmpty) return const SizedBox.shrink();
    final total = topBanksData.fold<double>(
        0, (s, e) => s + (e['totalAmount'] as double).abs());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text('Portfolio',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5)),
              const Spacer(),
              Text('${topBanksData.length} banks',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 138,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: topBanksData.length,
            itemBuilder: (_, i) {
              final bank = topBanksData[i];
              final amount = bank['totalAmount'] as double;
              final pct = total > 0
                  ? (amount.abs() / total * 100).toStringAsFixed(1)
                  : '0.0';
              final gradient = _bankGradients[i % _bankGradients.length];
              final initial = (bank['namebank'] as String).isNotEmpty
                  ? (bank['namebank'] as String)[0].toUpperCase()
                  : '?';

              return Container(
                width: 158,
                margin: EdgeInsets.only(
                    right: i < topBanksData.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(initial,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$pct%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      bank['namebank'] as String,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatAmount(amount),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? amount.abs() / total : 0,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                            Colors.white.withValues(alpha: 0.85)),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Donut chart ──────────────────────────────────────────────────────────

  Widget _buildDonutSection() {
    final total = topBanksData.fold<double>(
        0, (s, e) => s + (e['totalAmount'] as double).abs());
    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribution',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5)),
            const SizedBox(height: 18),
            Row(
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: topBanksData.take(6).map((e) {
                        final i = topBanksData.indexOf(e);
                        final pct =
                            (e['totalAmount'] as double).abs() / total;
                        return PieChartSectionData(
                          value: pct,
                          color: _chartColors[i % _chartColors.length],
                          radius: 28,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: topBanksData.take(5).map((e) {
                      final i = topBanksData.indexOf(e);
                      final pct = total > 0
                          ? ((e['totalAmount'] as double).abs() /
                                  total *
                                  100)
                              .toStringAsFixed(1)
                          : '0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _chartColors[i % _chartColors.length],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e['namebank'] as String,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('$pct%',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recent transactions ──────────────────────────────────────────────────

  Widget _buildTransactionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Recent Activity',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${recentTransactions.length} latest',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...recentTransactions.map(_buildTransactionTile),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final String title = tx['details'] ?? '';
    final double amount = (tx['amount'] ?? 0.0) as double;
    final DateTime date = tx['date'] ?? DateTime.now();
    final String bankId = tx['idbank'] ?? '0';
    final bool isPositive = amount >= 0;

    final bankName = cache.getBankName(bankId);
    final bankIdx =
        topBanksData.indexWhere((b) => b['namebank'] == bankName);
    final cardColor = bankIdx >= 0
        ? _bankGradients[bankIdx % _bankGradients.length][0]
        : const Color(0xFF6366F1);
    final initial =
        bankName.isNotEmpty ? bankName[0].toUpperCase() : '?';
    final formattedDate = DateFormat('MMM dd · hh:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bank initial avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor, cardColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
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
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(bankName,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: cardColor)),
                    ),
                    const SizedBox(width: 6),
                    Text(formattedDate,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'} ${formatAmount(amount.abs())}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isPositive
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 10,
                  color: isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 52)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 52)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
