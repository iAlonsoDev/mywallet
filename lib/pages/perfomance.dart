import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/service/appcache.dart';

class Performence extends StatefulWidget {
  const Performence({super.key});
  @override
  State<Performence> createState() => _PerformenceState();
}

class _PerformenceState extends State<Performence> {
  final cache = AppCache();

  double totalbalance = 0.0;
  double totalavailable = 0.0;
  double bestranking = 0.0;
  double lasttransaction = 0.0;
  double topaccount = 0.0;
  String bestaccount = "";

  @override
  void initState() {
    super.initState();
    _loadFromCache();
  }

  Future<void> _loadFromCache({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      await cache.loadStaticData(); // 🔹 Carga desde cache local
    }

    _calculateSummary();
    if (mounted) setState(() {});
  }

  void _calculateSummary() {
    final txs = cache.transactions;

    totalbalance = txs.fold(0, (sum, t) => sum + (t["amount"] as double));
    totalavailable = txs
        .where((t) => t["idbank"].toString() != "8")
        .fold(0, (sum, t) => sum + (t["amount"] as double));

    bestranking =
        txs.isNotEmpty
            ? txs
                .map((t) => t["summary"] as double)
                .reduce((a, b) => a > b ? a : b)
            : 0.0;

    if (txs.isNotEmpty) {
      final lastTx = txs.reduce(
        (a, b) => (a["date"] as DateTime).isAfter(b["date"]) ? a : b,
      );
      lasttransaction = lastTx["amount"];
    }

    // Top bank
    final Map<String, double> totals = {};
    for (var t in txs) {
      totals.update(
        t["idbank"].toString(),
        (val) => val + (t["amount"] as double),
        ifAbsent: () => (t["amount"] as double),
      );
    }

    if (totals.isNotEmpty) {
      final best = totals.entries.reduce((a, b) => a.value > b.value ? a : b);
      bestaccount = cache.getBankName(best.key);
      topaccount = best.value;
    }
  }

  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'en-US', symbol: 'L. ');
    String formattedAmount = formatter.format(amount);
    if (formattedAmount == "-L. 0.00") return "L. 0.00";
    return formattedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: RefreshIndicator(
          //onRefresh: _loadFromCache, //
          onRefresh: () => _loadFromCache(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ===== Encabezado =====
                //const Text(
                //  "Accounts Summary",
                //  style: TextStyle(
                //    fontSize: 16,
                //    fontWeight: FontWeight.bold,
                //    color: Colors.black87,
                //  ),
                //),
                const SizedBox(height: 12),

                // ===== Lista de cuentas =====
                ..._getTopAccounts().map((account) {
                  final accountName = account['nameAccount'];
                  final bankName = account['nameBank'];
                  final accountAmount = account['totalAmount'] as double;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            accountAmount < 0 ? Colors.redAccent : Colors.green,
                        child: Text(
                          bankName.isNotEmpty ? bankName[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        accountName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        bankName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Text(
                        formatAmount(accountAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accountAmount < 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTopAccounts() {
    final Map<String, double> totalAmountsByAccount = {};

    for (var tx in cache.transactions) {
      final idAccount = tx['idaccount'];
      final idBank = tx['idbank'];

      // 🔹 validar si la cuenta y el banco están activos
      final accountStatus = cache.getAccountStatus(idAccount);
      final bankStatus = cache.getBankStatus(idBank);

      if (accountStatus != "1" || bankStatus != "1") {
        continue; // ⏭️ saltar cuentas/bancos inactivos
      }

      final totalAmount = (tx['amount'] ?? 0.0) as double;
      totalAmountsByAccount.update(
        idAccount,
        (val) => val + totalAmount,
        ifAbsent: () => totalAmount,
      );
    }

    if (totalAmountsByAccount.isEmpty) return [];

    // 🔹 Filtrar cuentas con saldo distinto de cero (redondeado a 2 decimales)
    final topAccountsData =
        totalAmountsByAccount.entries
            .where((entry) => entry.value.toStringAsFixed(2) != "0.00")
            .map((entry) {
              final accountName = cache.getAccountName(entry.key);
              final bankId =
                  cache.transactions
                      .firstWhere(
                        (t) => t['idaccount'] == entry.key,
                        orElse: () => {"idbank": "0"},
                      )['idbank']
                      .toString();
              final bankName = cache.getBankName(bankId);

              return {
                'nameAccount': accountName,
                'nameBank': bankName,
                'totalAmount': entry.value,
              };
            })
            .toList();

    // 🔹 Ordenar de mayor a menor
    topAccountsData.sort(
      (a, b) =>
          (b['totalAmount'] as double).compareTo(a['totalAmount'] as double),
    );

    return topAccountsData;
  }
}
