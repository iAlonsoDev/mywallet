import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Details extends StatefulWidget {
  const Details({super.key});
  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final cache = AppCache();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    initializeDateFormatting('es_ES');
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await cache.loadStaticData();
    setState(() => isLoading = false);
  }

  Future<void> _refreshData() async {
    await cache.loadStaticData();
    setState(() {});
  }

  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'en-US', symbol: 'L. ');
    String formattedAmount = formatter.format(amount);
    if (formattedAmount == "-L. 0.00") return "L. 0.00";
    return formattedAmount;
  }

  double _getTotalBalance(List<Map<String, dynamic>> accounts) {
    return accounts.fold(0.0, (sum, account) => sum + (account['totalAmount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final accounts = _getAccountsFromCache();
    final totalBalance = _getTotalBalance(accounts);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.deepPurple[600],
          child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 36),

                        // Clean Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF8B5CF6),
                                      const Color(0xFF7C3AED),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Account Overview",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey[900],
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Your financial summary",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Clean Balance Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 25,
                                  offset: const Offset(0, 6),
                                  spreadRadius: -3,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 3),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                  blurRadius: 35,
                                  offset: const Offset(0, 10),
                                  spreadRadius: -8,
                                ),
                              ],
                            ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total Balance",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                formatAmount(totalBalance),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: totalBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                  letterSpacing: -1.5,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: totalBalance >= 0
                                                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (totalBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            totalBalance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.grey[300]!,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatChip(
                                          "Accounts",
                                          accounts.length.toString(),
                                          Icons.account_balance_wallet_rounded,
                                          Colors.blue,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.grey[300]!,
                                                Colors.transparent,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                        _buildStatChip(
                                          "Active",
                                          accounts.where((a) => (a['totalAmount'] as double) > 0).length.toString(),
                                          Icons.check_circle_rounded,
                                          Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                        // Premium List Header
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6366F1),
                                      const Color(0xFF8B5CF6),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Accounts Detail",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey[900],
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6366F1).withValues(alpha: 0.15),
                                      const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.list_alt_rounded, size: 16, color: const Color(0xFF6366F1)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${accounts.length} accounts",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF6366F1),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Premium Account Cards with Progress Bars
                        if (accounts.isEmpty)
                          _buildEmptyState()
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: accounts.map((account) {
                                final accountName = account['nameAccount'];
                                final bankName = account['nameBank'];
                                final bankImage = account['bankImage'];
                                final accountAmount = account['totalAmount'] as double;

                                // Calculate percentage contribution to total
                                final percentage = totalBalance != 0
                                    ? (accountAmount.abs() / totalBalance.abs() * 100)
                                    : 0.0;
                                final isPositive = accountAmount >= 0;

                                final accountId = account['accountId'] as String;

                                return GestureDetector(
                                  onTap: () => _showAccountTransactionsBottomSheet(
                                    context,
                                    accountName,
                                    accountId,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isPositive
                                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                            : const Color(0xFFEF4444).withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                          spreadRadius: -2,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                        BoxShadow(
                                          color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                              .withValues(alpha: 0.12),
                                          blurRadius: 30,
                                          offset: const Offset(0, 8),
                                          spreadRadius: -5,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Premium Bank Image with Gradient
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(18),
                                                gradient: LinearGradient(
                                                  colors: isPositive
                                                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                                      : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: bankImage.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(18),
                                                      child: CachedNetworkImage(
                                                        imageUrl: bankImage,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => Icon(
                                                          Icons.account_balance_rounded,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.account_balance_rounded,
                                                      size: 24,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                            const SizedBox(width:12),

                                            // Account Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    accountName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black87,
                                                      letterSpacing: -0.3,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.business_rounded,
                                                        size: 14,
                                                        color: Colors.grey[500],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          bankName,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[600],
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            
                                            Text(
                                              formatAmount(accountAmount),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Premium Progress Bar with Gradient
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Contribution to Total",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                Text(
                                                  "${percentage.toStringAsFixed(1)}%",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Stack(
                                                  children: [
                                                    FractionallySizedBox(
                                                      widthFactor: percentage / 100,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: isPositive
                                                                ? [
                                                                    const Color(0xFF10B981),
                                                                    const Color(0xFF059669),
                                                                    const Color(0xFF047857),
                                                                  ]
                                                                : [
                                                                    const Color(0xFFEF4444),
                                                                    const Color(0xFFDC2626),
                                                                    const Color(0xFFB91C1C),
                                                                  ],
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                                                  .withValues(alpha: 0.5),
                                                              blurRadius: 8,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
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
                            }).toList(),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

  Widget _buildStatChip(String label, String value, IconData icon, MaterialColor color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color[400]!.withValues(alpha: 0.2),
                color[600]!.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color[300]!.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color[400]!.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color[700], size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.grey[900],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.1),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No account data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.grey[800],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Start adding transactions to see your accounts",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAccountsFromCache() {
    final Map<String, double> totalAmountsByAccount = {};
    final Map<String, String> accountToBankMap = {};

    // Process all transactions from cache
    for (var transaction in cache.transactions) {
      final idAccount = transaction['idaccount']?.toString() ?? '';
      final idBank = transaction['idbank']?.toString() ?? '';

      // Validate if account and bank are active
      final accountStatus = cache.getAccountStatus(idAccount);
      final bankStatus = cache.getBankStatus(idBank);

      if (accountStatus != "1" || bankStatus != "1") {
        continue;
      }

      final totalAmount = (transaction['amount'] ?? 0.0) is num
          ? (transaction['amount'] as num).toDouble()
          : 0.0;

      totalAmountsByAccount.update(
        idAccount,
        (val) => val + totalAmount,
        ifAbsent: () => totalAmount,
      );

      // Store bank ID for this account
      accountToBankMap[idAccount] = idBank;
    }

    if (totalAmountsByAccount.isEmpty) return [];

    // Filter accounts with non-zero balance
    final accountsData = totalAmountsByAccount.entries
        .where((entry) => entry.value.toStringAsFixed(2) != "0.00")
        .map((entry) {
          final accountName = cache.getAccountName(entry.key);
          final bankId = accountToBankMap[entry.key] ?? '0';
          final bankName = cache.getBankName(bankId);

          return {
            'nameAccount': accountName,
            'nameBank': bankName,
            'bankImage': cache.getBankImage(bankId),
            'totalAmount': entry.value,
            'accountId': entry.key,
          };
        })
        .toList();

    // Sort from highest to lowest
    accountsData.sort(
      (a, b) => (b['totalAmount'] as double).compareTo(a['totalAmount'] as double),
    );

    return accountsData;
  }

  List<Map<String, dynamic>> _getTransactionsForAccount(String accountId) {
    final now = DateTime.now();
    final transactions = cache.transactions
        .where((tx) {
          final txDate = tx['date'] as DateTime;
          final idAccount = tx['idaccount']?.toString() ?? '';

          // Filter by account id
          if (idAccount != accountId) return false;

          // Filter by current month
          if (txDate.year != now.year || txDate.month != now.month) return false;

          // Validate active transaction
          final accountStatus = cache.getAccountStatus(idAccount);
          final bankStatus = cache.getBankStatus(tx['idbank']?.toString() ?? '');
          return accountStatus == "1" && bankStatus == "1";
        })
        .toList();

    // Sort by date descending (most recent first)
    transactions.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  void _showAccountTransactionsBottomSheet(
    BuildContext context,
    String accountName,
    String accountId,
  ) {
    final transactions = _getTransactionsForAccount(accountId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionsBottomSheet(
        accountName,
        transactions,
      ),
    );
  }

  Widget _buildTransactionsBottomSheet(
    String accountName,
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM', 'es_ES').format(now);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accountName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${monthName[0].toUpperCase()}${monthName.substring(1)} ${now.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[600],
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),
          // Transactions List or Empty State
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 48,
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin transacciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay transacciones en esta cuenta para este mes',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final txDate = tx['date'] as DateTime;
                  final amount = (tx['amount'] ?? 0.0) is num
                      ? (tx['amount'] as num).toDouble()
                      : 0.0;
                  final isPositive = amount >= 0;
                  final type = tx['type']?.toString() ?? 'UNKNOWN';
                  final details = tx['details']?.toString() ?? 'Sin descripción';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Type icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: type == 'TRANSFER'
                                ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                                : isPositive
                                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            type == 'DEPOSIT'
                                ? Icons.arrow_downward_rounded
                                : type == 'WITHDRAWAL'
                                    ? Icons.arrow_upward_rounded
                                    : Icons.swap_horiz_rounded,
                            color: type == 'TRANSFER'
                                ? const Color(0xFF3B82F6)
                                : isPositive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Transaction info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date and Details on same line
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      details,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color.fromARGB(255, 39, 39, 39),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 11,
                                    color: const Color.fromARGB(255, 117, 116, 116),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    DateFormat('dd-MM-yyyy', 'es_ES').format(txDate),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Amount
                        Text(
                          formatAmount(amount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isPositive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
