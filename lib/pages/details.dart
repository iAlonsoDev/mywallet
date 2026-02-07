import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                        // Header compacto
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple[600]!, Colors.deepPurple[800]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.dashboard_outlined, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Account Overview",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          "Your financial summary",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Total Balance Card compacto
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
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatChip(
                                          "Accounts",
                                          accounts.length.toString(),
                                          Icons.account_balance_wallet_outlined,
                                          Colors.blue,
                                        ),
                                        Container(width: 1, height: 35, color: Colors.grey[200]),
                                        _buildStatChip(
                                          "Active",
                                          accounts.where((a) => (a['totalAmount'] as double) > 0).length.toString(),
                                          Icons.check_circle_outline,
                                          Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // List header compacto
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.indigo[400]!, Colors.indigo[600]!],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Accounts Detail",
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

                        // Account list
                        if (accounts.isEmpty)
                          _buildEmptyState()
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: accounts.map((account) {
                                final accountName = account['nameAccount'];
                                final bankName = account['nameBank'];
                                final bankImage = account['bankImage'];
                                final accountAmount = account['totalAmount'] as double;

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
                                        // Bank image
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            gradient: LinearGradient(
                                              colors: accountAmount >= 0
                                                  ? [Colors.green[50]!, Colors.green[100]!]
                                                  : [Colors.red[50]!, Colors.red[100]!],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            border: Border.all(
                                              color: accountAmount >= 0 ? Colors.green[200]! : Colors.red[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: bankImage.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(9),
                                                  child: CachedNetworkImage(
                                                    imageUrl: bankImage,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Center(
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: accountAmount >= 0 ? Colors.green[600] : Colors.red[600],
                                                      ),
                                                    ),
                                                    errorWidget: (context, url, error) => Icon(
                                                      Icons.account_balance_outlined,
                                                      size: 22,
                                                      color: accountAmount >= 0 ? Colors.green[600] : Colors.red[600],
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.account_balance_outlined,
                                                  size: 22,
                                                  color: accountAmount >= 0 ? Colors.green[600] : Colors.red[600],
                                                ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Account info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                accountName,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                  letterSpacing: -0.2,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.business,
                                                    size: 10,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Expanded(
                                                    child: Text(
                                                      bankName,
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

                                        // Amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              formatAmount(accountAmount),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: accountAmount >= 0 ? Colors.green[800] : Colors.red[800],
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 20),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color[700], size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_outlined, size: 56, color: Colors.grey[400]),
          ),
          const SizedBox(height: 14),
          Text(
            "No account data",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Start adding transactions to see your accounts",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
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
          };
        })
        .toList();

    // Sort from highest to lowest
    accountsData.sort(
      (a, b) => (b['totalAmount'] as double).compareTo(a['totalAmount'] as double),
    );

    return accountsData;
  }
}
