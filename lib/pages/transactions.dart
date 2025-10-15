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

/// ---------- Modelos ----------
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
  String _selectedType = 'DEPOSIT';
  String idedit = '';
  String idcontroller = '';
  String idbankcontroller = '';
  String idaccountcontroller = '';
  double totSummary = 0.0;

  // Destino para transferencias
  String idbankcontrollerDest = '';
  String idaccountcontrollerDest = '';
  Bank? _selectedBankDest;
  Account? _selectedAccountDest;
  List<Account> _accountsDest = <Account>[];

  List<Bank> _banks = <Bank>[];
  Bank _selectedBank = Bank(idbank: '0', namebank: 'BANKS', statusbank: '0');

  List<AllBank> _allbanks = <AllBank>[];
  final AllBank _selectedallBank = AllBank(
    allidbank: '0',
    allnamebank: 'BANKS',
    allstatusbank: '0',
  );

  List<Account> _accounts = <Account>[];

  Account _selectedAccount = Account(
    idaccount: '0',
    nameaccount: 'ACCOUNTS',
    statusaccount: '0',
  );

  List<AllAccount> _allaccounts = <AllAccount>[];
  final AllAccount _selectedallAccount = AllAccount(
    allidaccount: '0',
    allnameaccount: 'ACCOUNTS',
    allstatusaccount: '0',
  );

  // Streams
  Stream<QuerySnapshot<Map<String, dynamic>>>? transactionsStream;

  Future<void> getOnTheLoad() async {
    transactionsStream =
        DatabaseMethods().getTransactionDetails()
            as Stream<QuerySnapshot<Map<String, dynamic>>>?;
    if (mounted) setState(() {});
    await getTotal();
  }

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
    fetchBanksData();
    fetchallBanksData();
    fetchAccountsData();
    fetchallAccountsData();
    getNextId().then((values) {
      idcontroller = values["maxId"].toString();
      if (mounted) setState(() {});
    });

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

  /// ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
               // children: [
               //   const CircleAvatar(
                //    radius: 22,
               //     backgroundColor: Colors.black,
                //    child: Icon(
                //      Icons.account_balance_wallet,
                //      color: Colors.white,
                //    ),
               //   ),
               //   IconButton(
               //      onPressed: () {},
               //      icon: const Icon(Icons.settings),
               //    ),
               // ],
              ),
              const SizedBox(height: 20),

              // Formulario
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    DropdownButton<Bank>(
                      value:
                          _banks.firstWhereOrNull(
                            (b) => b.idbank == idbankcontroller,
                          ) ??
                          (_banks.isNotEmpty ? _banks.first : null),
                      isExpanded: true,
                      items:
                          _banks
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b.namebank),
                                ),
                              )
                              .toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          setState(() {
                            _selectedBank = v;
                            idbankcontroller = v.idbank;
                          });
                          await fetchAccountsData();
                        }
                      },
                    ),

                    const SizedBox(height: 10),
                    DropdownButton<Account>(
                      value: _accounts.firstWhereOrNull(
                        (a) => a.idaccount == idaccountcontroller,
                      ),
                      isExpanded: true,
                      hint: const Text("Select Account"),
                      items:
                          _accounts
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a,
                                  child: Text(a.nameaccount),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedAccount = v;
                            idaccountcontroller = v.idaccount;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: detailscontroller,
                      decoration: const InputDecoration(
                        hintText: "Transaction Details",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountcontroller,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              hintText: "Amount",
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: summarycontroller,
                            textAlign: TextAlign.right,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: "Summary",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      items:
                          <String>['DEPOSIT', 'WITHDRAWAL', 'TRANSFER']
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),

                    // 🔹 Solo en transfer
                    if (_selectedType == "TRANSFER") ...[
                      const SizedBox(height: 10),
                      DropdownButton<Bank>(
                        value: _banks.firstWhereOrNull(
                          (b) => b.idbank == idbankcontrollerDest,
                        ),
                        isExpanded: true,
                        hint: const Text("Destination Bank"),
                        items:
                            _banks
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(b.namebank),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) async {
                          if (v != null) {
                            setState(() {
                              _selectedBankDest = v;
                              idbankcontrollerDest = v.idbank;
                              idaccountcontrollerDest =
                                  ''; // reset cuenta destino
                            });
                            await fetchAccountsDestData(); // 🔹 cargar cuentas del banco destino
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<Account>(
                        value: _accountsDest.firstWhereOrNull(
                          (a) => a.idaccount == idaccountcontrollerDest,
                        ),
                        isExpanded: true,
                        hint: const Text("Destination Account"),
                        items:
                            _accountsDest
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a.nameaccount),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedAccountDest = v;
                              idaccountcontrollerDest = v.idaccount;
                            });
                          }
                        },
                      ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5487B4),
                          ),
                          onPressed: _addTransaction,
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _updateTransaction,
                          child: const Text(
                            "Update",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "All Transactions",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 400, child: _allTransactionsDetails()),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- Métodos Add/Update ----------
  Future<void> _addTransaction() async {
    final idtransaction = asInt(idcontroller);
    final idamount = asDouble(amountcontroller.text);
    if (idamount == 0.0) return;

    final dateTime = DateTime.now();

    if (_selectedType != "TRANSFER") {
      // 🔹 Caso normal (DEPOSIT o WITHDRAWAL)
      final insertMap = {
        "amount": idamount,
        "date": dateTime,
        "details": (detailscontroller.text).toUpperCase(),
        "idtransaction": idtransaction,
        "idaccount": asInt(idaccountcontroller),
        "idbank": asInt(idbankcontroller),
        "summary": asDouble(summarycontroller.text),
        "type": _selectedType,
      };
      await DatabaseMethods().addTransactionDetails(
        insertMap,
        idtransaction.toString(),
      );
      toastification.show(
        context: context,
        title: const Text("Transaction added"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } else {
      // 🔹 Caso TRANSFER → 2 registros pero mismo summary global
      if (idaccountcontrollerDest.isEmpty) {
        toastification.show(
          context: context,
          title: const Text('Select destination account'),
          autoCloseDuration: const Duration(seconds: 3),
          style: ToastificationStyle.flat,
          type: ToastificationType.error,
        );
        return;
      }

      final currentSummary = totSummary;

      final withdrawalMap = {
        "amount": idamount, // se inserta como negativo
        "date": dateTime,
        "details": detailscontroller.text.toUpperCase(),
        "idtransaction": idtransaction,
        "idaccount": asInt(idaccountcontroller),
        "idbank": asInt(idbankcontroller),
        "summary": currentSummary + idamount, // 👈 a lo que habia se le suma pero como es - se refleja una disminución
        "type": "WITHDRAWAL",
      };

      // Registro de depósito
      //     -500
      final depositMap = {
        "amount": idamount * (-1), // se convierte a positivo
        "date": dateTime,
        "details": detailscontroller.text.toUpperCase(),
        "idtransaction": idtransaction + 1,
        "idaccount": asInt(idaccountcontrollerDest),
        "idbank": asInt(idbankcontrollerDest),
        "summary": currentSummary, // 👈 vuelve al estado anterior
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
      "type": _selectedType,
    };

    await DatabaseMethods().updateTransactionDetails(
      updateMap,
      idtransaction.toString(),
    );
    toastification.show(
      context: context,
      title: const Text("Transaction updated"),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 2),
    );
    idedit = '';
    _clearForm();
    await _afterWriteRefresh();
  }

  void _clearForm() {
    idcontroller = '';
    amountcontroller.text = '0.0';
    detailscontroller.clear();
    amountcontroller.clear();
    summarycontroller.clear();
    datecontroller.clear();
  }

  Future<void> _afterWriteRefresh() async {
    final values = await getNextId();
    idcontroller = values["maxId"].toString();
    await getTotal();
    await fetchBanksData();
    await fetchAccountsData();
    if (mounted) setState(() {});
  }

  Future<Map> getNextId() async {
    try {
      final q =
          await FirebaseFirestore.instance
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
      return {"maxId": 0};
    }
  }

  Future<void> getTotal() async {
    double suma = 0.0;
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Transactions').get();
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
    final querySnapshot =
        await FirebaseFirestore.instance
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
    final querySnapshot =
        await FirebaseFirestore.instance
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
    final accountsSnapshot =
        await FirebaseFirestore.instance
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
    final allaccountsSnapshot =
        await FirebaseFirestore.instance
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
    final accountsSnapshot =
        await FirebaseFirestore.instance
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
      _selectedType = value < 0 ? "WITHDRAWAL" : "DEPOSIT";
      final newSummary = totSummary + value;
      summarycontroller.text = newSummary.toStringAsFixed(2);
    });
  }

  /// ---------- Listado ----------
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
        if (docs.isEmpty) return const Center(child: Text("No transactions"));
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final ds = docs[index];
            final dt = asDateTime(ds.data()["date"]);
            final formattedDate =
                dt == null
                    ? "Unknown date"
                    : DateFormat('yyyy-MM-dd hh:mm a').format(dt);
            final details = (ds.data()["details"] ?? '').toString();
            final type = (ds.data()["type"] ?? '').toString();
            final amount = asDouble(ds.data()["amount"]);
            final summary = asDouble(ds.data()["summary"]);
            final idbank = (ds.data()["idbank"]).toString();
            final idaccount = (ds.data()["idaccount"]).toString();
            final bankName =
                _allbanks
                    .firstWhereOrNull((b) => b.allidbank == idbank)
                    ?.allnamebank ??
                'UNKNOWN';
            final accountName =
                _allaccounts
                    .firstWhereOrNull((a) => a.allidaccount == idaccount)
                    ?.allnameaccount ??
                'UNKNOWN';

            return Column(
              children: [
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white,
                  child: ListTile(
                    onTap: () async {
                      final data = ds.data();

                      setState(() {
                        idedit = data["idtransaction"].toString();
                        idcontroller = idedit;
                        detailscontroller.text =
                            (data["details"] ?? '').toString();
                        amountcontroller.text =
                            asDouble(data["amount"]).toString();
                        summarycontroller.text =
                            asDouble(data["summary"]).toString();
                        _selectedType = (data["type"] ?? 'DEPOSIT').toString();

                        // IDs
                        idbankcontroller = (data["idbank"]).toString();
                        idaccountcontroller = (data["idaccount"]).toString();
                      });

                      // 🔹 Buscar banco en lista y setearlo
                      final bank = _banks.firstWhereOrNull(
                        (b) => b.idbank == idbankcontroller,
                      );
                      if (bank != null) {
                        setState(() {
                          _selectedBank = bank;
                        });
                      }

                      // 🔹 Recargar cuentas del banco seleccionado y setear cuenta
                      await fetchAccountsData();
                      final account = _accounts.firstWhereOrNull(
                        (a) => a.idaccount == idaccountcontroller,
                      );
                      if (account != null) {
                        setState(() {
                          _selectedAccount = account;
                        });
                      }
                    },

                    title: Text(
                      details.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Amount: ${formatAmountNum(amount)}",
                          style: TextStyle(
                            color:
                                type == "DEPOSIT" ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        Text("Summary: ${formatAmountNum(summary)}"),
                        Text(
                          "$bankName | $accountName",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 43, 42, 42),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          () => _confirmDelete(
                            ds.data()["idtransaction"].toString(),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(String idTransaction) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Delete!"),
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
      title: const Text("Transaction deleted"),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 2),
    );
    _clearForm();
    await _afterWriteRefresh();
  }
}
