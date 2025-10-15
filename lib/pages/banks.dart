import 'package:flutter/material.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:mywallet/service/database.dart';
import 'package:toastification/toastification.dart';

class Banks extends StatefulWidget {
  const Banks({super.key});

  @override
  State<Banks> createState() => _BanksState();
}

class _BanksState extends State<Banks> {
  final cache = AppCache();

  TextEditingController namecontroller = TextEditingController();
  String _selectedStatus = 'ACTIVE';
  String idcontroller = '';
  String statuscontroller = '1';

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    await cache.loadStaticData(); // carga Banks al cache
    if (mounted) setState(() {});
    getNextId().then((maxId) {
      idcontroller = maxId.toString();
    });
  }

  // === Listado de bancos ===
  Widget allBanksDetails() {
    if (cache.banksMap.isEmpty) {
      return const Center(child: Text("No banks found"));
    }

    final banksList = cache.banksMap.entries.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: banksList.length,
      itemBuilder: (context, index) {
        final idbank = banksList[index].key;
        final bankData = banksList[index].value;
        final namebank = bankData["name"] ?? "Unknown";
        final status = bankData["status"] ?? "0";

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
                    namebank,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                      idcontroller = idbank;
                      namecontroller.text = namebank;
                      statuscontroller = status;
                      setState(() {
                        _selectedStatus = status == '1' ? 'ACTIVE' : 'DISABLE';
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDeleteBank(idbank),
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
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //children: [
                //  const CircleAvatar(
                //    radius: 22,
                //    backgroundColor: Colors.black,
                //    child: Icon(Icons.account_balance, color: Colors.white),
                //  ),
                //  IconButton(
                //    onPressed: () async => await _loadBanks(),
                //    icon: const Icon(Icons.refresh),
                //  ),
               // ],
              ),
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
                    TextField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        hintText: "Bank Name",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStatus = newValue;
                            statuscontroller = newValue == 'ACTIVE' ? '1' : '0';
                          });
                        }
                      },
                      isExpanded: true,
                      items:
                          <String>['ACTIVE', 'DISABLE']
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 10),
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
                          onPressed: () async {
                            final idbank =
                                idcontroller.isEmpty
                                    ? await getNextId()
                                    : int.parse(idcontroller);

                            final newBank = {
                              "idbank": idbank,
                              "namebank": namecontroller.text,
                              "status": statuscontroller,
                            };

                            await DatabaseMethods().addBankDetails(
                              newBank,
                              idbank.toString(),
                            );

                            toastification.show(
                              context: context,
                              title: const Text("Bank added successfully!"),
                              autoCloseDuration: const Duration(seconds: 3),
                              type: ToastificationType.success,
                            );

                            namecontroller.clear();
                            await _loadBanks();
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () async {
                            if (idcontroller.isEmpty) return;

                            final idbank = int.parse(idcontroller);
                            final updateBank = {
                              "idbank": idbank,
                              "namebank": namecontroller.text,
                              "status": statuscontroller,
                            };

                            await DatabaseMethods().updateBankDetails(
                              updateBank,
                              idbank.toString(),
                            );

                            toastification.show(
                              context: context,
                              title: const Text("Bank updated successfully!"),
                              autoCloseDuration: const Duration(seconds: 3),
                              type: ToastificationType.info,
                            );

                            namecontroller.clear();
                            idcontroller = '';
                            await _loadBanks();
                          },
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

              // Lista bancos
              const Text(
                "All Banks",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              allBanksDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> getNextId() async {
    if (cache.banksMap.isEmpty) return 1;
    final maxId = cache.banksMap.keys
        .map((k) => int.tryParse(k) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<void> _confirmDeleteBank(String idBank) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Delete!"),
                content: const Text(
                  "Are you sure you want to delete this bank?",
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

    await DatabaseMethods().deleteBankDetails(idBank);

    if (!mounted) return;
    toastification.show(
      context: context,
      title: const Text("Bank deleted successfully"),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flat,
      type: ToastificationType.error,
    );

    await _loadBanks();
  }
}
