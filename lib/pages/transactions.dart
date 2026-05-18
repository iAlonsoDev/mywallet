import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:mywallet/service/database.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// ---------- Helpers ----------
double asDouble(Object? v, {double fallback = 0.0}) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

int asInt(Object? v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

DateTime? asDateTime(Object? v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

String formatAmountNum(num amount) {
  final formatter = NumberFormat.currency(locale: 'en-US', symbol: 'Lps. ');
  var txt = formatter.format(amount);
  if (txt == "-Lps. 0.00") txt = "Lps. 0.00";
  return txt;
}

String mapType(String type) {
  switch (type) {
    case 'DEPOSIT':
      return 'Deposit';
    case 'WITHDRAWAL':
      return 'Withdrawal';
    case 'TRANSFER':
      return 'Transfer';
    default:
      return type;
  }
}

String mapTypeToDB(String type) {
  switch (type) {
    case 'Deposit':
      return 'DEPOSIT';
    case 'Withdrawal':
      return 'WITHDRAWAL';
    case 'Transfer':
      return 'TRANSFER';
    default:
      return type;
  }
}

/// ---------- Models ----------
class Bank {
  final String idbank;
  final String namebank;
  final String statusbank;
  Bank({
    required this.idbank,
    required this.namebank,
    required this.statusbank,
  });
}

class Account {
  final String idaccount;
  final String nameaccount;
  final String statusaccount;
  Account({
    required this.idaccount,
    required this.nameaccount,
    required this.statusaccount,
  });
}

/// ---------- Widget ----------
class Transactions extends StatefulWidget {
  const Transactions({super.key});
  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  static const _bankGradients = [
    [Color(0xFF6366F1), Color(0xFF4338CA)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFF06B6D4), Color(0xFF0891B2)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
  ];

  // Controllers
  final detailscontroller = TextEditingController();
  final amountcontroller = TextEditingController();
  final summarycontroller = TextEditingController();
  final datecontroller = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // State
  String _selectedType = 'Deposit';
  String idedit = '';
  String idcontroller = '';
  String idbankcontroller = '';
  String idaccountcontroller = '';
  double totSummary = 0.0;

  // Destination for transfers
  String idbankcontrollerDest = '';
  String idaccountcontrollerDest = '';
  Bank? _selectedBankDest;
  Account? _selectedAccountDest;
  List<Account> _accountsDest = <Account>[];

  List<Bank> _banks = <Bank>[];
  Bank? _selectedBank;

  List<Account> _accounts = <Account>[];
  Account? _selectedAccount;

  bool _isLoading = true;
  bool _isProcessing = false;

  Future<void> getOnTheLoad() async {
    await AppCache().loadStaticData();
    await fetchBanksData();
    await getTotal();
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
    amountcontroller.addListener(_handleAmountChange);
  }

  @override
  void dispose() {
    detailscontroller.dispose();
    amountcontroller.dispose();
    summarycontroller.dispose();
    datecontroller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHero(),
          _buildSearchSection(),
          Expanded(child: _allTransactionsDetails()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── Hero ─────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    final isPositive = totSummary >= 0;
    final cache = AppCache();
    final recordCount = cache.transactions.length;

    return ClipPath(
      clipper: _TxHeroClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF0F172A), Color(0xFF0C4A6E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              // Header row
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
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Track your finances',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '$recordCount records',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Balance label
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

              // Balance amount + trend pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      formatAmountNum(totSummary),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
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
                          isPositive ? 'Positive' : 'Negative',
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
            ],
          ),
        ),
      ),
    );
  }

  // ─── Search Section ───────────────────────────────────────────────────────

  Widget _buildSearchSection() {
    final cache = AppCache();
    final query = _searchQuery.trim().toLowerCase();
    final allDocs = cache.transactions;
    final filteredCount = query.isEmpty
        ? allDocs.length
        : allDocs
            .where((t) =>
                (t['details'] ?? '').toString().toLowerCase().contains(query))
            .length;

    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'All Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$filteredCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Search by description...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon:
                  Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: Colors.grey[400], size: 18),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showTransactionModal(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'New',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// ========== MODAL BOTTOM SHEET ==========
  void _showTransactionModal({String? editId}) async {
    if (editId != null) {
      await _loadTransactionForEdit(editId);
    } else {
      _clearForm();
      // Esperar a que los bancos carguen
      while (_banks.isEmpty && _isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // Auto-load first bank and its first account for new transactions
      if (_banks.isNotEmpty) {
        final firstBank = _banks.first;
        setState(() {
          _selectedBank = firstBank;
          idbankcontroller = firstBank.idbank;
        });
        await fetchAccountsData();
        if (_accounts.isNotEmpty) {
          final firstAccount = _accounts.first;
          setState(() {
            _selectedAccount = firstAccount;
            idaccountcontroller = firstAccount.idaccount;
          });
        }
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal[400]!, Colors.teal[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              idedit.isEmpty ? "New" : "Edit",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              "Fill in the details below",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.grey[200]),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bank dropdown
                        _buildModernDropdown<Bank>(
                          label: "Bank",
                          value: _selectedBank ?? (_banks.isNotEmpty ? _banks.first : null),
                          items: _banks,
                          itemBuilder: (bank) => Text(bank.namebank),
                          onChanged: (bank) async {
                            if (bank != null) {
                              setModalState(() {
                                _selectedBank = bank;
                                idbankcontroller = bank.idbank;
                                _selectedAccount = null;
                                idaccountcontroller = '';
                              });
                              setState(() {
                                _selectedBank = bank;
                                idbankcontroller = bank.idbank;
                                _selectedAccount = null;
                                idaccountcontroller = '';
                              });
                              await fetchAccountsData();

                              // Auto-select first account
                              if (_accounts.isNotEmpty) {
                                final firstAccount = _accounts.first;
                                setModalState(() {
                                  _selectedAccount = firstAccount;
                                  idaccountcontroller = firstAccount.idaccount;
                                });
                                setState(() {
                                  _selectedAccount = firstAccount;
                                  idaccountcontroller = firstAccount.idaccount;
                                });
                              }

                              setModalState(() {});
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // Account dropdown
                        _buildModernDropdown<Account>(
                          label: "Account",
                          value: _selectedAccount,
                          items: _accounts,
                          itemBuilder: (account) => Text(account.nameaccount),
                          onChanged: (account) {
                            if (account != null) {
                              setModalState(() {
                                _selectedAccount = account;
                                idaccountcontroller = account.idaccount;
                              });
                              setState(() {
                                _selectedAccount = account;
                                idaccountcontroller = account.idaccount;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // Details
                        _buildModernTextField(
                          controller: detailscontroller,
                          label: "Transaction Details",
                          icon: Icons.description_outlined,
                        ),

                        const SizedBox(height: 12),

                        // Amount and Summary
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: amountcontroller,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: "Amount",
                                  labelStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.teal[400]!, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                onChanged: (value) {
                                  final amount = asDouble(value);
                                  if (amount != 0.0) {
                                    final newType = amount < 0 ? 'Withdrawal' : 'Deposit';
                                    setModalState(() {
                                      _selectedType = newType;
                                    });
                                    setState(() {
                                      _selectedType = newType;
                                    });
                                  }
                                  // Update summary
                                  final newSummary = totSummary + amount;
                                  summarycontroller.text = newSummary.toStringAsFixed(2);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernTextField(
                                controller: summarycontroller,
                                label: "Summary",
                                icon: Icons.calculate_outlined,
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Type selector
                        Text(
                          "Transaction Type",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeChip(
                                'Deposit',
                                Icons.arrow_downward,
                                Colors.green,
                                setModalState,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTypeChip(
                                'Withdrawal',
                                Icons.arrow_upward,
                                Colors.red,
                                setModalState,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTypeChip(
                                'Transfer',
                                Icons.swap_horiz,
                                Colors.blue,
                                setModalState,
                              ),
                            ),
                          ],
                        ),

                        // Transfer destination (only if Transfer)
                        if (_selectedType == "Transfer") ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.send, color: Colors.blue[700], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Transfer Destination",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildModernDropdown<Bank>(
                                  label: "Destination Bank",
                                  value: _selectedBankDest,
                                  items: _banks,
                                  itemBuilder: (bank) => Text(bank.namebank),
                                  onChanged: (bank) async {
                                    if (bank != null) {
                                      setModalState(() {
                                        _selectedBankDest = bank;
                                        idbankcontrollerDest = bank.idbank;
                                        _selectedAccountDest = null;
                                        idaccountcontrollerDest = '';
                                      });
                                      setState(() {
                                        _selectedBankDest = bank;
                                        idbankcontrollerDest = bank.idbank;
                                        _selectedAccountDest = null;
                                        idaccountcontrollerDest = '';
                                      });
                                      await fetchAccountsDestData();

                                      // Auto-select first destination account
                                      if (_accountsDest.isNotEmpty) {
                                        final firstAccount = _accountsDest.first;
                                        setModalState(() {
                                          _selectedAccountDest = firstAccount;
                                          idaccountcontrollerDest = firstAccount.idaccount;
                                        });
                                        setState(() {
                                          _selectedAccountDest = firstAccount;
                                          idaccountcontrollerDest = firstAccount.idaccount;
                                        });
                                      }

                                      setModalState(() {});
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildModernDropdown<Account>(
                                  label: "Destination Account",
                                  value: _selectedAccountDest,
                                  items: _accountsDest,
                                  itemBuilder: (account) => Text(account.nameaccount),
                                  onChanged: (account) {
                                    if (account != null) {
                                      setModalState(() {
                                        _selectedAccountDest = account;
                                        idaccountcontrollerDest = account.idaccount;
                                      });
                                      setState(() {
                                        _selectedAccountDest = account;
                                        idaccountcontrollerDest = account.idaccount;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom buttons
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Row(
                    children: [
                      if (idedit.isNotEmpty) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[300]!, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _clearForm();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: idedit.isEmpty
                                  ? [
                                      const Color.fromARGB(255, 74, 111, 190),
                                      const Color.fromARGB(255, 29, 86, 109),
                                    ]
                                  : [
                                      const Color(0xFF14B8A6),
                                      const Color(0xFF0D9488),
                                    ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (idedit.isEmpty
                                        ? const Color.fromARGB(255, 74, 111, 190)
                                        : const Color(0xFF14B8A6))
                                    .withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: (idedit.isEmpty
                                        ? const Color.fromARGB(255, 74, 111, 190)
                                        : const Color(0xFF14B8A6))
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              if (_isProcessing) return;
                              _isProcessing = true;
                              try {
                                if (idedit.isEmpty) {
                                  final savedBankId = idbankcontroller;
                                  final savedAccountId = idaccountcontroller;
                                  await _addTransaction();
                                  // Restaurar banco y cuenta seleccionados antes de guardar
                                  final bank = _banks.firstWhereOrNull((b) => b.idbank == savedBankId);
                                  final account = _accounts.firstWhereOrNull((a) => a.idaccount == savedAccountId);
                                  setModalState(() {
                                    _selectedBank = bank;
                                    _selectedAccount = account;
                                    if (bank != null) idbankcontroller = savedBankId;
                                    if (account != null) idaccountcontroller = savedAccountId;
                                  });
                                  setState(() {
                                    _selectedBank = bank;
                                    _selectedAccount = account;
                                    if (bank != null) idbankcontroller = savedBankId;
                                    if (account != null) idaccountcontroller = savedAccountId;
                                  });
                                } else {
                                  await _updateTransaction();
                                  if (mounted) Navigator.pop(context);
                                }
                              } finally {
                                if (mounted) _isProcessing = false;
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  idedit.isEmpty ? Icons.add_circle_rounded : Icons.check_circle_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  idedit.isEmpty ? "Add" : "Update",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(String type, IconData icon, MaterialColor color, StateSetter setModalState) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setModalState(() => _selectedType = type);
        setState(() => _selectedType = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color[50]!.withValues(alpha: 0.8),
                    color[100]!.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color[300]!.withValues(alpha: 0.6) : Colors.grey[300]!,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color[400]!.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color[700] : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color[800] : Colors.grey[700],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 74, 111, 190), size: 20),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 74, 111, 190),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Widget Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: -0.2,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 74, 111, 190),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: itemBuilder(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  /// ---------- Add/Update Methods ----------
  Future<void> _addTransaction() async {
    final values = await getNextId();
    final idtransaction = values["maxId"];
    final idamount = asDouble(amountcontroller.text);
    if (idamount == 0.0) return;

    final dateTime = DateTime.now();

    if (_selectedType != "Transfer") {
      // Normal case (DEPOSIT or WITHDRAWAL)
      final insertMap = {
        "amount": idamount,
        "date": dateTime,
        "details": (detailscontroller.text).toUpperCase(),
        "idtransaction": idtransaction,
        "idaccount": asInt(idaccountcontroller),
        "idbank": asInt(idbankcontroller),
        "summary": asDouble(summarycontroller.text),
        "type": mapTypeToDB(_selectedType),
      };
      await DatabaseMethods().addTransactionDetails(
        insertMap,
        idtransaction.toString(),
      );
      toastification.show(
        context: context,
        title: const Text("Transaction added successfully!"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } else {
      // TRANSFER case → 2 records
      if (idaccountcontrollerDest.isEmpty) {
        toastification.show(
          context: context,
          title: const Text('Please select destination account'),
          autoCloseDuration: const Duration(seconds: 3),
          style: ToastificationStyle.flat,
          type: ToastificationType.error,
        );
        return;
      }

      final transferAmount = idamount.abs();
      final currentSummary = totSummary;

      // 1. Primero: resta del origen (withdrawal, monto negativo)
      final withdrawalMap = {
        "amount": -transferAmount,
        "date": dateTime,
        "details": detailscontroller.text.toUpperCase(),
        "idtransaction": idtransaction,
        "idaccount": asInt(idaccountcontroller),
        "idbank": asInt(idbankcontroller),
        "summary": currentSummary - transferAmount,
        "type": mapTypeToDB(_selectedType),
      };

      // 2. Luego: suma al destino (deposit, monto positivo)
      final depositMap = {
        "amount": transferAmount,
        "date": dateTime,
        "details": detailscontroller.text.toUpperCase(),
        "idtransaction": idtransaction + 1,
        "idaccount": asInt(idaccountcontrollerDest),
        "idbank": asInt(idbankcontrollerDest),
        "summary": currentSummary,
        "type": mapTypeToDB(_selectedType),
      };

      await DatabaseMethods().addTransactionDetails(
        withdrawalMap,
        withdrawalMap["idtransaction"].toString(),
      );
      await DatabaseMethods().addTransactionDetails(
        depositMap,
        depositMap["idtransaction"].toString(),
      );
      toastification.show(
        context: context,
        title: const Text("Transfer completed successfully!"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }

    _clearForm();
    await _afterWriteRefresh();
  }

  Future<void> _updateTransaction() async {
    final idtransaction = asInt(idcontroller);
    final idaccount = asInt(idaccountcontroller);
    final idbank = asInt(idbankcontroller);

    final updateMap = {
      "idtransaction": idtransaction,
      "idaccount": idaccount,
      "idbank": idbank,
      "details": (detailscontroller.text).toUpperCase(),
      "type": mapTypeToDB(_selectedType),
    };

    await DatabaseMethods().updateTransactionDetails(
      updateMap,
      idtransaction.toString(),
    );
    toastification.show(
      context: context,
      title: const Text("Transaction updated successfully!"),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 2),
    );
    idedit = '';
    _clearForm();
    await _afterWriteRefresh();
  }

  void _clearForm() {
    idcontroller = '';
    idedit = '';
    amountcontroller.clear();
    detailscontroller.clear();
    summarycontroller.clear();
    datecontroller.clear();
    _selectedType = 'Deposit';
    _selectedBank = null;
    _selectedAccount = null;
    _selectedBankDest = null;
    _selectedAccountDest = null;
    idbankcontroller = '';
    idaccountcontroller = '';
    idbankcontrollerDest = '';
    idaccountcontrollerDest = '';
  }

  Future<void> _afterWriteRefresh() async {
    await AppCache().loadStaticData();
    await getTotal();
    await fetchBanksData();
    if (mounted) setState(() {});
  }

  Future<Map> getNextId() async {
    try {
      final q = await FirebaseFirestore.instance
          .collection("Transactions")
          .orderBy("idtransaction", descending: true)
          .limit(1)
          .get();
      int maxId = 0;
      if (q.docs.isNotEmpty) {
        maxId = asInt(q.docs.first.data()["idtransaction"]);
      }
      return {"maxId": maxId + 1};
    } catch (_) {
      return {"maxId": 1};
    }
  }

  Future<void> getTotal() async {
    final suma = AppCache().transactions.fold<double>(
      0.0, (acc, t) => acc + (t['amount'] as double? ?? 0.0));
    if (!mounted) return;
    setState(() {
      totSummary = (suma * 100).round() / 100;
      summarycontroller.text = totSummary.toStringAsFixed(2);
    });
  }

  Future<void> fetchBanksData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Banks')
        .orderBy("namebank", descending: false)
        .get();
    final banksList = <Bank>[];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['status']?.toString() == '1') {
        banksList.add(
          Bank(
            idbank: data['idbank'].toString(),
            namebank: (data['namebank'] ?? '').toString(),
            statusbank: (data['status'] ?? '0').toString(),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _banks = banksList;
    });
  }

  Future<void> fetchAccountsData() async {
    final accountsSnapshot = await FirebaseFirestore.instance
        .collection('Accounts')
        .orderBy("nameaccount", descending: false)
        .get();

    final accountsList = <Account>[];
    for (var doc in accountsSnapshot.docs) {
      final data = doc.data();
      if (data['idbank']?.toString() == idbankcontroller &&
          data['status']?.toString() == '1') {
        accountsList.add(
          Account(
            idaccount: data['idaccount'].toString(),
            nameaccount: (data['nameaccount'] ?? '').toString(),
            statusaccount: (data['status'] ?? '0').toString(),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _accounts = accountsList;
    });
  }

  Future<void> fetchAccountsDestData() async {
    final accountsSnapshot = await FirebaseFirestore.instance
        .collection('Accounts')
        .orderBy("nameaccount", descending: false)
        .get();

    final accountsList = <Account>[];
    for (var doc in accountsSnapshot.docs) {
      final data = doc.data();
      if (data['idbank']?.toString() == idbankcontrollerDest &&
          data['status']?.toString() == '1') {
        accountsList.add(
          Account(
            idaccount: data['idaccount'].toString(),
            nameaccount: (data['nameaccount'] ?? '').toString(),
            statusaccount: (data['status'] ?? '0').toString(),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _accountsDest = accountsList;
    });
  }

  void _handleAmountChange() {
    final text = amountcontroller.text.trim();
    if (text.isEmpty) return;
    final value = asDouble(text);
    setState(() {
      _selectedType = mapType(value < 0 ? "WITHDRAWAL" : "DEPOSIT");
      final newSummary = totSummary + value;
      summarycontroller.text = newSummary.toStringAsFixed(2);
    });
  }

  /// ---------- List ----------
  Widget _allTransactionsDetails() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final cache = AppCache();
    final query = _searchQuery.trim().toLowerCase();
    final allDocs = cache.transactions;
    final docs = query.isEmpty
        ? allDocs
        : allDocs.where((t) {
            final details = (t['details'] ?? '').toString().toLowerCase();
            return details.contains(query);
          }).toList();

    if (docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 74, 111, 190).withValues(alpha: 0.1),
                      const Color.fromARGB(255, 29, 86, 109).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 74, 111, 190).withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 74, 111, 190).withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 36,
                  color: const Color.fromARGB(255, 74, 111, 190).withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "No transactions yet",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Tap the button below to add your first transaction",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: docs.length + 1,
      itemBuilder: (context, index) {
        if (index == docs.length) {
          return const SizedBox(height: 100);
        }
        final t = docs[index];
        final dt = t['date'] as DateTime?;
        final formattedDate = dt == null
            ? "Unknown"
            : DateFormat('MMM dd • hh:mm a').format(dt);
        final details = (t['details'] ?? '').toString();
        final type = (t['type'] ?? '').toString();
        final amount = t['amount'] as double? ?? 0.0;
        final summary = t['summary'] as double? ?? 0.0;
        final idbank = t['idbank'].toString();
        final idaccount = t['idaccount'].toString();
        final bankName = cache.getBankName(idbank);

        // Bank initial avatar gradient
        final gradientColors = _bankGradients[
            (int.tryParse(idbank) ?? 0) % _bankGradients.length];

        // Type chip style
        Color typeChipColor;
        String typeLabel;
        if (type == "DEPOSIT") {
          typeChipColor = const Color(0xFF10B981);
          typeLabel = 'DEPOSIT';
        } else if (type == "WITHDRAWAL") {
          typeChipColor = const Color(0xFFEF4444);
          typeLabel = 'WITHDRAWAL';
        } else {
          typeChipColor = const Color(0xFF3B82F6);
          typeLabel = 'TRANSFER';
        }

        final bankInitial = bankName.isNotEmpty
            ? bankName[0].toUpperCase()
            : '?';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isProcessing
                  ? null
                  : () => _showTransactionModal(
                      editId: t['idtransaction'].toString()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Bank initial avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          bankInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details + type chip
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.isEmpty ? bankName : details,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeChipColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  typeLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: typeChipColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
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

                    // Amount + summary column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatAmountNum(amount),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: typeChipColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            formatAmountNum(summary),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600],
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Delete button
                    InkWell(
                      onTap: _isProcessing
                          ? null
                          : () => _confirmDelete(
                              t['idtransaction'].toString()),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),

                    // Account name hidden — kept for data reference only
                    Visibility(
                      visible: false,
                      child: Text(cache.getAccountName(idaccount)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(String idTransaction) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text(
                "Are you sure you want to delete this transaction?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ) ??
          false;

      if (!ok) return;

      await DatabaseMethods().deleteTransactionDetails(idTransaction);
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text("Transaction deleted successfully"),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
      _clearForm();
      await _afterWriteRefresh();
    } finally {
      if (mounted) _isProcessing = false;
    }
  }

  Future<void> _loadTransactionForEdit(String docId) async {
    final data = await FirebaseFirestore.instance
        .collection('Transactions')
        .doc(docId)
        .get()
        .then((doc) => doc.data());
    if (data == null) return;

    setState(() {
      idedit = data["idtransaction"].toString();
      idcontroller = idedit;
      detailscontroller.text = (data["details"] ?? '').toString();
      amountcontroller.text = asDouble(data["amount"]).toString();
      summarycontroller.text = asDouble(data["summary"]).toString();
      _selectedType = mapType((data["type"] ?? 'DEPOSIT').toString());

      // IDs
      idbankcontroller = (data["idbank"]).toString();
      idaccountcontroller = (data["idaccount"]).toString();
    });

    // Find bank and set it
    final bank = _banks.firstWhereOrNull((b) => b.idbank == idbankcontroller);
    if (bank != null) {
      setState(() {
        _selectedBank = bank;
      });
    }

    // Reload accounts and set account
    await fetchAccountsData();
    final account = _accounts.firstWhereOrNull(
      (a) => a.idaccount == idaccountcontroller,
    );
    if (account != null) {
      setState(() {
        _selectedAccount = account;
      });
    }
  }
}

// ─── Clipper ──────────────────────────────────────────────────────────────────

class _TxHeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
