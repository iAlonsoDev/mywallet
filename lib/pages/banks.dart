import 'package:flutter/material.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:mywallet/service/database.dart';
import 'package:mywallet/widgets/UploadImageWidget.dart';
import 'package:toastification/toastification.dart';

class Banks extends StatefulWidget {
  const Banks({super.key});

  @override
  State<Banks> createState() => _BanksState();
}

class _BanksState extends State<Banks> {
  final cache = AppCache();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController imagecontroller = TextEditingController();
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
        final imageUrl = bankData["image"] ?? "";

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
              CircleAvatar(
                radius: 20,
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty ? const Icon(Icons.account_balance) : null,
              ),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Column(
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
              ),

              // Botones acción
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        idcontroller = idbank;
                        namecontroller.text = namebank;
                        imagecontroller.text = imageUrl;
                        statuscontroller = status;
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
                    TextField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        labelText: "Nombre del Banco",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Subir Imagen del Banco',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    UploadImageWidget(
                      initialImageUrl: imagecontroller.text.isNotEmpty ? imagecontroller.text : null,
                      onUploaded: (url) {
                        if (mounted) {
                          setState(() {
                            imagecontroller.text = url;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Estado",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStatus = newValue;
                            statuscontroller = newValue == 'ACTIVE' ? '1' : '0';
                          });
                        }
                      },
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
                            child: const Text("Agregar"),
                            onPressed: () async {
                              final idbank =
                                  idcontroller.isEmpty
                                      ? await getNextId()
                                      : int.parse(idcontroller);

                              final newBank = {
                                "idbank": idbank,
                                "namebank": namecontroller.text,
                                "image": imagecontroller.text,
                                "status": statuscontroller,
                              };

                              await DatabaseMethods().addBankDetails(
                                newBank,
                                idbank.toString(),
                              );

                              toastification.show(
                                context: context,
                                title: const Text("Banco agregado exitosamente!"),
                                autoCloseDuration: const Duration(seconds: 3),
                                type: ToastificationType.success,
                              );

                              setState(() {
                                namecontroller.clear();
                                imagecontroller.clear();
                              });
                              await _loadBanks();
                            },
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
                            child: const Text("Actualizar"),
                            onPressed: () async {
                              if (idcontroller.isEmpty) return;

                              final idbank = int.parse(idcontroller);
                              final updateBank = {
                                "idbank": idbank,
                                "namebank": namecontroller.text,
                                "image": imagecontroller.text,
                                "status": statuscontroller,
                              };

                              await DatabaseMethods().updateBankDetails(
                                updateBank,
                                idbank.toString(),
                              );

                              toastification.show(
                                context: context,
                                title: const Text("Banco actualizado exitosamente!"),
                                autoCloseDuration: const Duration(seconds: 3),
                                type: ToastificationType.info,
                              );

                              setState(() {
                                namecontroller.clear();
                                imagecontroller.clear();
                                idcontroller = '';
                              });
                              await _loadBanks();
                            },
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
                "Todos los Bancos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
