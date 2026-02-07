import 'package:flutter/material.dart';
import 'package:mywallet/service/appcache.dart';
import 'package:mywallet/service/database.dart';
import 'package:mywallet/widgets/UploadImageWidget.dart';
import 'package:toastification/toastification.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "No hay bancos registrados",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Row(
            children: [
              // Imagen del banco
              imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.account_balance, size: 18, color: Colors.grey[400]),
                        ),
                      ),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.account_balance, size: 18, color: Colors.grey[400]),
                    ),
              const SizedBox(width: 12),

              // Info - 80%
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namebank,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == "1"
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status == "1" ? "ACTIVE" : "DISABLED",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: status == "1" ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botones acción - 20%
              Expanded(
                flex: 27,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          idcontroller = idbank;
                          namecontroller.text = namebank;
                          imagecontroller.text = imageUrl;
                          statuscontroller = status;
                          _selectedStatus = status == '1' ? 'ACTIVE' : 'DISABLE';
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.edit_outlined, size: 24, color: Colors.blue[600]),
                      ),
                    ),
                    InkWell(
                      onTap: () => _confirmDeleteBank(idbank),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.delete_outline, size: 24, color: Colors.red[600]),
                      ),
                    ),
                  ],
                ),
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header moderno
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bank Management",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "Manage your financial institutions",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Formulario estilo Dribbble
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 40,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Label moderno
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Bank Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Nombre del banco - Input moderno
                    TextField(
                      controller: namecontroller,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        labelText: "Bank Name",
                        labelStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Sección de imagen y estado con diseño moderno
                    Row(
                      children: [
                        // Widget de imagen rediseñado
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              const SizedBox(height: 4),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Switch moderno con gradiente
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: statuscontroller == '1'
                                        ? [Colors.green[50]!, Colors.green[100]!]
                                        : [Colors.red[50]!, Colors.red[100]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: statuscontroller == '1'
                                        ? Colors.green[200]!
                                        : Colors.red[200]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          statuscontroller == '1' ? Icons.check_circle : Icons.cancel,
                                          color: statuscontroller == '1' ? Colors.green[700] : Colors.red[700],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          statuscontroller == '1' ? "Active" : "Inactive",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: statuscontroller == '1' ? Colors.green[800] : Colors.red[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Switch(
                                      value: statuscontroller == '1',
                                      onChanged: (value) {
                                        setState(() {
                                          statuscontroller = value ? '1' : '0';
                                          _selectedStatus = value ? 'ACTIVE' : 'DISABLE';
                                        });
                                      },
                                      activeTrackColor: Colors.green[400],
                                      activeThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.red[300],
                                      inactiveThumbColor: Colors.white,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Botón con gradiente moderno
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: idcontroller.isEmpty
                                    ? [Colors.blue[600]!, Colors.blue[800]!]
                                    : [Colors.teal[600]!, Colors.teal[800]!],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: (idcontroller.isEmpty ? Colors.blue : Colors.teal).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final isEditing = idcontroller.isNotEmpty;
                                final idbank = isEditing ? int.parse(idcontroller) : await getNextId();

                                final bankData = {
                                  "idbank": idbank,
                                  "namebank": namecontroller.text,
                                  "image": imagecontroller.text,
                                  "status": statuscontroller,
                                };

                                if (isEditing) {
                                  await DatabaseMethods().updateBankDetails(bankData, idbank.toString());
                                  toastification.show(
                                    context: context,
                                    title: const Text("Bank updated successfully!"),
                                    autoCloseDuration: const Duration(seconds: 3),
                                    type: ToastificationType.info,
                                  );
                                } else {
                                  await DatabaseMethods().addBankDetails(bankData, idbank.toString());
                                  toastification.show(
                                    context: context,
                                    title: const Text("Bank added successfully!"),
                                    autoCloseDuration: const Duration(seconds: 3),
                                    type: ToastificationType.success,
                                  );
                                }

                                setState(() {
                                  namecontroller.clear();
                                  imagecontroller.clear();
                                  idcontroller = '';
                                });
                                await _loadBanks();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    idcontroller.isEmpty ? Icons.add_circle_outline : Icons.check_circle_outline,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    idcontroller.isEmpty ? "Add Bank" : "Update Bank",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (idcontroller.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  namecontroller.clear();
                                  imagecontroller.clear();
                                  idcontroller = '';
                                  statuscontroller = '1';
                                  _selectedStatus = 'ACTIVE';
                                });
                              },
                              icon: const Icon(Icons.close_rounded, size: 22),
                              color: Colors.grey[700],
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                        ],
                      ],
                    ),
                  
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Header de lista moderno
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.purple[600]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "List",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, size: 16, color: Colors.purple[700]),
                        const SizedBox(width: 6),
                        Text(
                          "${cache.banksMap.length}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
