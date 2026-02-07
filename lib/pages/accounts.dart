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

  /// === Listado cuentas estilo Dribbble ===
  Widget allAccountsDetails() {
    if (cache.accountsMap.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              "No accounts registered",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              "Start by adding your first account",
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      );
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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  idcontroller = idaccount;
                  idedit = idaccount;
                  namecontroller.text = nameaccount;
                  idbankcontroller = idbank;
                  _selectedStatus = status == "1" ? "ACTIVE" : "DISABLE";
                  statuscontroller = status;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Imagen del banco con diseño moderno
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.grey[100]!, Colors.grey[200]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: bankImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: CachedNetworkImage(
                                imageUrl: bankImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.purple[600],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.account_balance_outlined,
                                  size: 24,
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : Icon(Icons.account_balance_outlined, size: 24, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 14),

                    // Información de la cuenta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameaccount,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bankName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: status == "1"
                                    ? [Colors.green[50]!, Colors.green[100]!]
                                    : [Colors.red[50]!, Colors.red[100]!],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: status == "1" ? Colors.green[200]! : Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status == "1" ? Icons.check_circle : Icons.cancel,
                                  size: 12,
                                  color: status == "1" ? Colors.green[700] : Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status == "1" ? "Active" : "Inactive",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: status == "1" ? Colors.green[800] : Colors.red[800],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botones de acción
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              idcontroller = idaccount;
                              idedit = idaccount;
                              namecontroller.text = nameaccount;
                              idbankcontroller = idbank;
                              _selectedStatus = status == "1" ? "ACTIVE" : "DISABLE";
                              statuscontroller = status;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.edit_outlined, size: 24, color: Colors.purple[600]),
                          ),
                        ),
                        InkWell(
                          onTap: () => _confirmDeleteAccount(idaccount),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.delete_outline, size: 24, color: Colors.red[600]),
                          ),
                        ),
                      ],
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
                        colors: [Colors.purple[600]!, Colors.purple[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account Management",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "Manage your bank accounts",
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
                              colors: [Colors.purple[400]!, Colors.purple[600]!],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Account Information",
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

                    // Dropdown de banco moderno
                    DropdownButtonFormField<String>(
                      initialValue: idbankcontroller.isNotEmpty
                          ? idbankcontroller
                          : (cache.banksMap.keys.isNotEmpty ? cache.banksMap.keys.first : '0'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Bank",
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
                          borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => idbankcontroller = val);
                        }
                      },
                      items: cache.banksMap.entries
                          .map((e) => DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(e.value["name"] ?? "Unknown"),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),

                    // Input nombre cuenta con Switch
                    Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: TextField(
                            controller: namecontroller,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: "Account Name",
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
                                borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        // Switch de estado
                        Expanded(
                          flex: 3,
                          child: Container(
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
                                color: statuscontroller == '1' ? Colors.green[200]! : Colors.red[200]!,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Botón único con gradiente
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: idedit.isEmpty
                                    ? [Colors.purple[600]!, Colors.purple[800]!]
                                    : [Colors.teal[600]!, Colors.teal[800]!],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: (idedit.isEmpty ? Colors.purple : Colors.teal).withValues(alpha: 0.4),
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
                                if (idedit.isEmpty) {
                                  await _addAccount();
                                } else {
                                  await _updateAccount();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    idedit.isEmpty ? Icons.add_circle_outline : Icons.check_circle_outline,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    idedit.isEmpty ? "Add Account" : "Update Account",
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
                        if (idedit.isNotEmpty) ...[
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
                                  idedit = '';
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
                        colors: [Colors.indigo[400]!, Colors.indigo[600]!],
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
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, size: 16, color: Colors.indigo[700]),
                        const SizedBox(width: 6),
                        Text(
                          "${cache.accountsMap.length}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
      title: const Text("Account added successfully!"),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    idedit = '';
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
      title: const Text("Account updated successfully!"),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 3),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    idedit = '';
    namecontroller.clear();
    setState(() {});
  }

  Future<void> _confirmDeleteAccount(String idAccount) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Delete"),
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
      title: const Text("Account deleted successfully"),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
    );

    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    setState(() {});
  }
}
