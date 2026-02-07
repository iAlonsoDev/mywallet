import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:mywallet/service/database.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      return const Center(child: Text("No se encontraron cuentas"));
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
        final bankImage = cache.getBankImage(idbank);

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
              // Imagen del banco
              bankImage.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: bankImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.account_balance, size: 20),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.account_balance),
                    ),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Column(
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
      
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const SizedBox(height: 20),

              // Formulario
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 🔹 Dropdown de bancos desde cache
                    DropdownButtonFormField<String>(
                      initialValue:
                          idbankcontroller.isNotEmpty
                              ? idbankcontroller
                              : (cache.banksMap.keys.isNotEmpty
                                  ? cache.banksMap.keys.first
                                  : '0'),
                      decoration: const InputDecoration(
                        labelText: "Banco",
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        labelText: "Nombre de la Cuenta",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Estado",
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _addAccount,
                            child: const Text("Agregar"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _updateAccount,
                            child: const Text("Actualizar"),
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
                "Todas las Cuentas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      title: const Text("Cuenta agregada"),
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
      title: const Text("Cuenta actualizada"),
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
                title: const Text("Confirmar Eliminación"),
                content: const Text(
                  "¿Estás seguro de que quieres eliminar esta cuenta?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Eliminar"),
                  ),
                ],
              ),
        ) ??
        false;

    if (!ok) return;

    await DatabaseMethods().deleteAccountDetails(idAccount);
    toastification.show(
      context: context,
      title: const Text("Cuenta eliminada"),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 2),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    setState(() {});
  }
}
