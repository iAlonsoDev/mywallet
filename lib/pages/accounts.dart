import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:mywallet/service/database.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final cache = AppCache();

  TextEditingController namecontroller = TextEditingController();

  String _selectedStatus = 'ACTIVE';
  String idcontroller = '';
  String idedit = '';
  String idbankcontroller = '';
  String statuscontroller = '1';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    setState(() {});
  }

  /// === Listado cuentas desde CACHE ===
  Widget allAccountsDetails() {
    if (cache.accountsMap.isEmpty) {
      return const Center(child: Text("No accounts found"));
    }

    final accountsList = cache.accountsMap.entries.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accountsList.length,
      itemBuilder: (context, index) {
        final idaccount = accountsList[index].key;
        final accountData = accountsList[index].value;
        final nameaccount = accountData["name"] ?? "Unknown";
        final status = accountData["status"] ?? "0";

        // Banco de la cuenta
        final idbank = accountData["idbank"]?.toString() ?? "0";
        final bankName = cache.getBankName(idbank);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameaccount,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bankName,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  Text(
                    status == "1" ? "ACTIVE" : "DISABLED",
                    style: TextStyle(
                      fontSize: 10,
                      color: status == "1" ? Colors.green : Colors.redAccent,
                    ),
                  ),
                ],
              ),

              // Botones acción
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        idcontroller = idaccount;
                        idedit = idaccount;
                        namecontroller.text = nameaccount;
                        idbankcontroller = idbank;
                        _selectedStatus = status == "1" ? "ACTIVE" : "DISABLE";
                        statuscontroller = status;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDeleteAccount(idaccount),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //const CircleAvatar(
              //  radius: 22,
              //  backgroundColor: Colors.black,
              //   child: Icon(Icons.account_circle, color: Colors.white),
              // ),
              const SizedBox(height: 20),

              // Formulario
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // 🔹 Dropdown de bancos desde cache
                    DropdownButton<String>(
                      value:
                          idbankcontroller.isNotEmpty
                              ? idbankcontroller
                              : (cache.banksMap.keys.isNotEmpty
                                  ? cache.banksMap.keys.first
                                  : '0'),
                      isExpanded: true,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => idbankcontroller = val);
                        }
                      },
                      items:
                          cache.banksMap.entries
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e.key,
                                  child: Text(e.value["name"] ?? "Unknown"),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        hintText: "Account Name",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStatus = val;
                            statuscontroller = val == 'ACTIVE' ? '1' : '0';
                          });
                        }
                      },
                      items:
                          ['ACTIVE', 'DISABLE']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              84,
                              135,
                              180,
                            ),
                          ),
                          onPressed: _addAccount,
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _updateAccount,
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

              // Lista cuentas
              const Text(
                "All Accounts",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              allAccountsDetails(),
            ],
          ),
        ),
      ),
    );
  }

  // === CRUD ===
  Future<int> getNextId() async {
    if (cache.accountsMap.isEmpty) return 1;
    final maxId = cache.accountsMap.keys
        .map((k) => int.tryParse(k) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<void> _addAccount() async {
    final idaccount = int.parse(idcontroller);
    final newData = {
      "idaccount": idaccount,
      "idbank": int.parse(idbankcontroller),
      "nameaccount": namecontroller.text,
      "status": statuscontroller,
    };
    await DatabaseMethods().addAccountDetails(newData, idaccount.toString());
    toastification.show(
      context: context,
      title: const Text("Account added"),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 2),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    namecontroller.clear();
    setState(() {});
  }

  Future<void> _updateAccount() async {
    final idaccount = int.parse(idcontroller);
    final newData = {
      "idaccount": idaccount,
      "idbank": int.parse(idbankcontroller),
      "nameaccount": namecontroller.text,
      "status": statuscontroller,
    };
    await DatabaseMethods().updateAccountDetails(newData, idaccount.toString());
    toastification.show(
      context: context,
      title: const Text("Account updated"),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 2),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    namecontroller.clear();
    setState(() {});
  }

  Future<void> _confirmDeleteAccount(String idAccount) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Delete!"),
                content: const Text(
                  "Are you sure you want to delete this account?",
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

    await DatabaseMethods().deleteAccountDetails(idAccount);
    toastification.show(
      context: context,
      title: const Text("Account deleted"),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 2),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    setState(() {});
  }
}
