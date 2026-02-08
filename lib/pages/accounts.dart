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
    if (mounted) {
      setState(() {});
    }
  }

  /// === Listado cuentas estilo Dribbble ===
  Widget allAccountsDetails() {
    
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  status == "1"
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
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
                color: (status == "1"
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444))
                    .withValues(alpha: 0.1),
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
                    // Premium Bank Image
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors:
                              status == "1"
                                  ? [
                                    const Color(0xFF8B5CF6),
                                    const Color(0xFF7C3AED),
                                  ]
                                  : [
                                    const Color(0xFFEF4444),
                                    const Color(0xFFDC2626),
                                  ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (status == "1"
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFFEF4444))
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child:
                          bankImage.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: CachedNetworkImage(
                                  imageUrl: bankImage,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Icon(
                                        Icons.account_balance_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.account_balance_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(width: 12),

                    // Premium Account Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameaccount,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bankName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    status == "1"
                                        ? [
                                          const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.2),
                                          const Color(
                                            0xFF059669,
                                          ).withValues(alpha: 0.1),
                                        ]
                                        : [
                                          const Color(
                                            0xFFEF4444,
                                          ).withValues(alpha: 0.2),
                                          const Color(
                                            0xFFDC2626,
                                          ).withValues(alpha: 0.1),
                                        ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    status == "1"
                                        ? const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.3)
                                        : const Color(
                                          0xFFEF4444,
                                        ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (status == "1"
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444))
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status == "1"
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 12,
                                  color:
                                      status == "1"
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status == "1" ? "Active" : "Inactive",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        status == "1"
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFEF4444),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Premium Action Buttons
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              idcontroller = idaccount;
                              idedit = idaccount;
                              namecontroller.text = nameaccount;
                              idbankcontroller = idbank;
                              _selectedStatus =
                                  status == "1" ? "ACTIVE" : "DISABLE";
                              statuscontroller = status;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF8B5CF6,
                                  ).withValues(alpha: 0.15),
                                  const Color(
                                    0xFF7C3AED,
                                  ).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _confirmDeleteAccount(idaccount),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.15),
                                  const Color(
                                    0xFFDC2626,
                                  ).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.delete_rounded,
                              size: 20,
                              color: const Color(0xFFEF4444),
                            ),
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

              // Premium Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6),
                          const Color(0xFF7C3AED),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Management",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage your bank accounts",
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
              const SizedBox(height: 24),

              // Premium Form with Glass Effects
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
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
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      blurRadius: 35,
                      offset: const Offset(0, 10),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Label
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF8B5CF6),
                                const Color(0xFF7C3AED),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Account Information",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Premium Bank Dropdown
                    DropdownButtonFormField<String>(
                      initialValue:
                          idbankcontroller.isNotEmpty
                              ? idbankcontroller
                              : (cache.banksMap.keys.isNotEmpty
                                  ? cache.banksMap.keys.first
                                  : '0'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      decoration: InputDecoration(
                        labelText: "Bank",
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
                            color: Color(0xFF8B5CF6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
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
                    const SizedBox(height: 12),

                    // Input nombre cuenta con Switch
                    Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: TextField(
                            controller: namecontroller,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            decoration: InputDecoration(
                              labelText: "Account Name",
                              labelStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
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
                                  color: Color(0xFF8B5CF6),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Switch de estado
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    statuscontroller == '1'
                                        ? [
                                          const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.15),
                                          const Color(
                                            0xFF059669,
                                          ).withValues(alpha: 0.08),
                                        ]
                                        : [
                                          const Color(
                                            0xFFEF4444,
                                          ).withValues(alpha: 0.15),
                                          const Color(
                                            0xFFDC2626,
                                          ).withValues(alpha: 0.08),
                                        ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    statuscontroller == '1'
                                        ? const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.3)
                                        : const Color(
                                          0xFFEF4444,
                                        ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (statuscontroller == '1'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444))
                                      .withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Switch(
                                  value: statuscontroller == '1',
                                  onChanged: (value) {
                                    setState(() {
                                      statuscontroller = value ? '1' : '0';
                                      _selectedStatus =
                                          value ? 'ACTIVE' : 'DISABLE';
                                    });
                                  },
                                  activeTrackColor: Colors.green[400],
                                  activeThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.red[300],
                                  inactiveThumbColor: Colors.white,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Botón único con gradiente
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    idedit.isEmpty
                                        ? [
                                          const Color(0xFF8B5CF6),
                                          const Color(0xFF7C3AED),
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
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFF14B8A6))
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: (idedit.isEmpty
                                          ? const Color(0xFF8B5CF6)
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
                                    idedit.isEmpty
                                        ? Icons.add_circle_rounded
                                        : Icons.check_circle_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    idedit.isEmpty
                                        ? "Add Account"
                                        : "Update Account",
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
                        if (idedit.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
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
                              icon: const Icon(Icons.close_rounded, size: 24),
                              color: Colors.grey[700],
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Premium List Header
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF4F46E5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "Account List",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withValues(alpha: 0.15),
                          const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt_rounded,
                          size: 16,
                          color: const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${cache.accountsMap.length} accounts",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6366F1),
                            letterSpacing: 0.3,
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
    if (mounted) {
      setState(() {});
    }
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
    if (mounted) {
      setState(() {});
    }
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
    if (mounted) {
      setState(() {});
    }
  }
}
