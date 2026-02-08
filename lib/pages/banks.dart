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
  }

  // === Listado de bancos ===
  Widget allBanksDetails() {
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
                  idcontroller = idbank;
                  namecontroller.text = namebank;
                  imagecontroller.text = imageUrl;
                  statuscontroller = status;
                  _selectedStatus = status == '1' ? 'ACTIVE' : 'DISABLE';
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
                                    const Color(0xFF10B981),
                                    const Color(0xFF059669),
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
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444))
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child:
                          imageUrl.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
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

                    // Premium Bank Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namebank,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                              idcontroller = idbank;
                              namecontroller.text = namebank;
                              imagecontroller.text = imageUrl;
                              statuscontroller = status;
                              _selectedStatus =
                                  status == '1' ? 'ACTIVE' : 'DISABLE';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.15),
                                  const Color(
                                    0xFF2563EB,
                                  ).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _confirmDeleteBank(idbank),
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
                          const Color(0xFF3B82F6),
                          const Color(0xFF2563EB),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                    child: const Icon(
                      Icons.account_balance_rounded,
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
                          "Bank Management",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage your financial institutions",
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
                                const Color(0xFF3B82F6),
                                const Color(0xFF2563EB),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Bank Information",
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

                    // Premium Bank Name Input
                    TextField(
                      controller: namecontroller,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      decoration: InputDecoration(
                        labelText: "Bank Name",
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
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sección de imagen y estado con diseño moderno
                    Row(
                      children: [
                        // Widget de imagen rediseñado
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              UploadImageWidget(
                                initialImageUrl:
                                    imagecontroller.text.isNotEmpty
                                        ? imagecontroller.text
                                        : null,
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
                        const SizedBox(width: 10),

                        // Switch moderno con gradiente
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(10),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          statuscontroller == '1'
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          color:
                                              statuscontroller == '1'
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFEF4444),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            statuscontroller == '1'
                                                ? "Active"
                                                : "Inactive",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  statuscontroller == '1'
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFEF4444),
                                              letterSpacing: 0.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Botón con gradiente moderno
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    idcontroller.isEmpty
                                        ? [
                                          const Color(0xFF3B82F6),
                                          const Color(0xFF2563EB),
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
                                  color: (idcontroller.isEmpty
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF14B8A6))
                                      .withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: (idcontroller.isEmpty
                                          ? const Color(0xFF3B82F6)
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
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () async {
                                final isEditing = idcontroller.isNotEmpty;
                                final idbank =
                                    isEditing
                                        ? int.parse(idcontroller)
                                        : await getNextId();

                                final bankData = {
                                  "idbank": idbank,
                                  "namebank": namecontroller.text,
                                  "image": imagecontroller.text,
                                  "status": statuscontroller,
                                };

                                if (isEditing) {
                                  await DatabaseMethods().updateBankDetails(
                                    bankData,
                                    idbank.toString(),
                                  );
                                  toastification.show(
                                    context: context,
                                    title: const Text(
                                      "Bank updated successfully!",
                                    ),
                                    autoCloseDuration: const Duration(
                                      seconds: 3,
                                    ),
                                    type: ToastificationType.info,
                                  );
                                } else {
                                  await DatabaseMethods().addBankDetails(
                                    bankData,
                                    idbank.toString(),
                                  );
                                  toastification.show(
                                    context: context,
                                    title: const Text(
                                      "Bank added successfully!",
                                    ),
                                    autoCloseDuration: const Duration(
                                      seconds: 3,
                                    ),
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
                                    idcontroller.isEmpty
                                        ? Icons.add_circle_rounded
                                        : Icons.check_circle_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    idcontroller.isEmpty
                                        ? "Add Bank"
                                        : "Update Bank",
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
                        if (idcontroller.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
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
                                  imagecontroller.clear();
                                  idcontroller = '';
                                  statuscontroller = '1';
                                  _selectedStatus = 'ACTIVE';
                                });
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: Colors.grey[700],
                              padding: const EdgeInsets.all(4),
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
                          const Color(0xFF8B5CF6),
                          const Color(0xFF7C3AED),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "Bank List",
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
                          const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          const Color(0xFF7C3AED).withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
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
                          color: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${cache.banksMap.length} banks",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8B5CF6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
