import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
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

class AllBank {
  final String allidbank;
  final String allnamebank;
  final String allstatusbank;
  AllBank({
    required this.allidbank,
    required this.allnamebank,
    required this.allstatusbank,
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

class AllAccount {
  final String allidaccount;
  final String allnameaccount;
  final String allstatusaccount;
  AllAccount({
    required this.allidaccount,
    required this.allnameaccount,
    required this.allstatusaccount,
  });
}

/// ---------- Widget ----------
class Transactions extends StatefulWidget {
  const Transactions({super.key});
  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  // Controllers
  final detailscontroller = TextEditingController();
  final amountcontroller = TextEditingController();
  final summarycontroller = TextEditingController();
  final datecontroller = TextEditingController();

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

  List<AllBank> _allbanks = <AllBank>[];

  List<Account> _accounts = <Account>[];
  Account? _selectedAccount;

  List<AllAccount> _allaccounts = <AllAccount>[];

  // Streams
  Stream<QuerySnapshot<Map<String, dynamic>>>? transactionsStream;

  Future<void> getOnTheLoad() async {
    transactionsStream = DatabaseMethods().getTransactionDetails() as Stream<QuerySnapshot<Map<String, dynamic>>>?;
    if (mounted) setState(() {});
    await getTotal();
  }

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
    fetchBanksData();
    fetchallBanksData();
    fetchallAccountsData();
    amountcontroller.addListener(_handleAmountChange);
  }

  @override
  void dispose() {
    detailscontroller.dispose();
    amountcontroller.dispose();
    summarycontroller.dispose();
    datecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
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
                          const Color(0xFF3B82F6),
                          const Color(0xFF2563EB),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transaction Management",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Track your finances",
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
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
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      blurRadius: 35,
                      offset: const Offset(0, 10),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatAmountNum(totSummary),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: totSummary >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                letterSpacing: -1.5,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: totSummary >= 0
                                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (totSummary >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            totSummary >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            // Premium List Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF59E0B),
                          const Color(0xFFD97706),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Transactions list
            Expanded(child: _allTransactionsDetails()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showTransactionModal(),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  /// ========== MODAL BOTTOM SHEET ==========
  void _showTransactionModal({String? editId}) async {
    if (editId != null) {
      await _loadTransactionForEdit(editId);
    } else {
      _clearForm();
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
                              if (idedit.isEmpty) {
                                await _addTransaction();
                              } else {
                                await _updateTransaction();
                              }
                              Navigator.pop(context);
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

      final currentSummary = totSummary;

      final withdrawalMap = {
        "amount": idamount,
        "date": dateTime,
        "details": detailscontroller.text.toUpperCase(),
        "idtransaction": idtransaction,
        "idaccount": asInt(idaccountcontroller),
        "idbank": asInt(idbankcontroller),
        "summary": currentSummary + idamount,
        "type": "WITHDRAWAL",
      };

      final depositMap = {
        "amount": idamount * (-1),
        "date": dateTime,
        "details": detailscontroller.text.toUpperCase(),
        "idtransaction": idtransaction + 1,
        "idaccount": asInt(idaccountcontrollerDest),
        "idbank": asInt(idbankcontrollerDest),
        "summary": currentSummary,
        "type": "DEPOSIT",
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
    await getTotal();
    await fetchBanksData();
    await fetchallBanksData();
    await fetchallAccountsData();
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
    double suma = 0.0;
    final querySnapshot = await FirebaseFirestore.instance.collection('Transactions').get();
    for (var doc in querySnapshot.docs) {
      suma += asDouble(doc.data()['amount']);
    }
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

  Future<void> fetchallBanksData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Banks')
        .orderBy("namebank", descending: false)
        .get();
    final allbanksList = <AllBank>[];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      allbanksList.add(
        AllBank(
          allidbank: doc.id,
          allnamebank: (data['namebank'] ?? '').toString(),
          allstatusbank: (data['status'] ?? '0').toString(),
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _allbanks = allbanksList;
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

  Future<void> fetchallAccountsData() async {
    final allaccountsSnapshot = await FirebaseFirestore.instance
        .collection('Accounts')
        .orderBy("nameaccount", descending: false)
        .get();
    final allaccountsList = <AllAccount>[];
    for (var doc in allaccountsSnapshot.docs) {
      final data = doc.data();
      allaccountsList.add(
        AllAccount(
          allidaccount: data['idaccount'].toString(),
          allnameaccount: (data['nameaccount'] ?? '').toString(),
          allstatusaccount: (data['status'] ?? '0').toString(),
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _allaccounts = allaccountsList;
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
    if (transactionsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final ds = docs[index];
            final dt = asDateTime(ds.data()["date"]);
            final formattedDate = dt == null
                ? "Unknown date"
                : DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
            final details = (ds.data()["details"] ?? '').toString();
            final type = (ds.data()["type"] ?? '').toString();
            final amount = asDouble(ds.data()["amount"]);
            final summary = asDouble(ds.data()["summary"]);
            final idbank = (ds.data()["idbank"]).toString();
            final idaccount = (ds.data()["idaccount"]).toString();
            final bankName = _allbanks
                    .firstWhereOrNull((b) => b.allidbank == idbank)
                    ?.allnamebank ??
                'Unknown Bank';
            final accountName = _allaccounts
                    .firstWhereOrNull((a) => a.allidaccount == idaccount)
                    ?.allnameaccount ??
                'Unknown Account';

            MaterialColor typeColor;
            IconData typeIcon;
            if (type == "DEPOSIT") {
              typeColor = Colors.green;
              typeIcon = Icons.arrow_downward;
            } else if (type == "WITHDRAWAL") {
              typeColor = Colors.red;
              typeIcon = Icons.arrow_upward;
            } else {
              typeColor = Colors.blue;
              typeIcon = Icons.swap_horiz;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: typeColor[200]!.withValues(alpha: 0.3),
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
                    color: typeColor[400]!.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _showTransactionModal(editId: ds.id),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Premium Type Icon with gradient and glow
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [typeColor[400]!, typeColor[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: typeColor[400]!.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(typeIcon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 10),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details,
                                style: const TextStyle(
                                  fontSize: 12,
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
                                  Icon(Icons.account_balance_rounded, size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "$bankName • $accountName",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
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

                        // Amount and Summary
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatAmountNum(amount),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: typeColor[700],
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    typeColor[50]!.withValues(alpha: 0.8),
                                    typeColor[100]!.withValues(alpha: 0.4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: typeColor[200]!.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                formatAmountNum(summary),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: typeColor[700],
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 10),

                        // Premium Delete button
                        InkWell(
                          onTap: () => _confirmDelete(ds.data()["idtransaction"].toString()),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  const Color(0xFFDC2626).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(Icons.delete_rounded, size: 20, color: const Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String idTransaction) async {
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
    toastification.show(
      context: context,
      title: const Text("Transaction deleted successfully"),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 2),
    );
    _clearForm();
    await _afterWriteRefresh();
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
