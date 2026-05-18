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
  final TextEditingController namecontroller = TextEditingController();

  String _selectedStatus = 'ACTIVE';
  String idcontroller = '';
  String idedit = '';
  String idbankcontroller = '';
  String statuscontroller = '1';

  static const _bankGradients = [
    [Color(0xFF6366F1), Color(0xFF4338CA)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFF06B6D4), Color(0xFF0891B2)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await cache.loadStaticData();
    idcontroller = (await getNextId()).toString();
    if (cache.banksMap.isNotEmpty && idbankcontroller.isEmpty) {
      idbankcontroller = cache.banksMap.keys.first;
    }
    if (mounted) setState(() {});
  }

  void _selectAccount(String idaccount, Map<String, String> data) {
    setState(() {
      idcontroller = idaccount;
      idedit = idaccount;
      namecontroller.text = data["name"] ?? '';
      idbankcontroller = data["idbank"] ?? '';
      statuscontroller = data["status"] ?? '1';
      _selectedStatus = statuscontroller == '1' ? 'ACTIVE' : 'DISABLE';
    });
  }

  void _clearForm() {
    setState(() {
      idedit = '';
      namecontroller.clear();
      statuscontroller = '1';
      _selectedStatus = 'ACTIVE';
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHero(),
            Transform.translate(
              offset: const Offset(0, -100),
              child: Column(
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 20),
                  _buildAccountList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero ─────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return ClipPath(
      clipper: _AccountsHeroClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 70),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF1A0F2E), Color(0xFF4C1D95)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.account_circle_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Manage your bank accounts',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '${cache.accountsMap.length} accounts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form card ────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    final isEditing = idedit.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isEditing ? 'Edit Account' : 'New Account',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bank dropdown
            DropdownButtonFormField<String>(
              initialValue: idbankcontroller.isNotEmpty &&
                      cache.banksMap.containsKey(idbankcontroller)
                  ? idbankcontroller
                  : (cache.banksMap.keys.isNotEmpty
                      ? cache.banksMap.keys.first
                      : null),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              decoration:
                  _inputDecoration('Bank', const Color(0xFF8B5CF6)),
              onChanged: (val) {
                if (val != null) setState(() => idbankcontroller = val);
              },
              items: cache.banksMap.entries
                  .map((e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value["name"] ?? "Unknown"),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Account name + status switch
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: TextField(
                    controller: namecontroller,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: _inputDecoration(
                        'Account Name', const Color(0xFF8B5CF6)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: _buildStatusToggle(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                Expanded(child: _buildSaveButton(isEditing)),
                if (isEditing) ...[
                  const SizedBox(width: 10),
                  _buildCancelButton(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    final active = statuscontroller == '1';
    final color = active ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Switch(
            value: active,
            onChanged: (v) => setState(() {
              statuscontroller = v ? '1' : '0';
              _selectedStatus = v ? 'ACTIVE' : 'DISABLE';
            }),
            activeTrackColor: Colors.green[400],
            activeThumbColor: Colors.white,
            inactiveTrackColor: Colors.red[300],
            inactiveThumbColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    final c1 = isEditing ? const Color(0xFF14B8A6) : const Color(0xFF8B5CF6);
    final c2 = isEditing ? const Color(0xFF0D9488) : const Color(0xFF6D28D9);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c1, c2]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: c1.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
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
              isEditing
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_rounded,
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              isEditing ? 'Update Account' : 'Add Account',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        onPressed: _clearForm,
        icon: const Icon(Icons.close_rounded, size: 18),
        color: Colors.grey[600],
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  // ─── Account list ─────────────────────────────────────────────────────────

  Widget _buildAccountList() {
    final accountsList = cache.accountsMap.entries.toList();
    if (accountsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text('No accounts yet',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
      );
    }

    // Build bank index for color assignment
    final bankKeys = cache.banksMap.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Account List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${accountsList.length} total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...accountsList.asMap().entries.map((entry) {
            final i = entry.key;
            final idaccount = entry.value.key;
            final data = entry.value.value;
            final idbank = data["idbank"] ?? "0";
            final bankColorIdx = bankKeys.indexOf(idbank);
            final colorIdx =
                bankColorIdx >= 0 ? bankColorIdx : i;
            return _buildAccountTile(idaccount, data, colorIdx);
          }),
        ],
      ),
    );
  }

  Widget _buildAccountTile(
      String idaccount, Map<String, String> data, int colorIdx) {
    final nameaccount = data["name"] ?? "Unknown";
    final status = data["status"] ?? "0";
    final idbank = data["idbank"] ?? "0";
    final bankName = cache.getBankName(idbank);
    final bankImage = cache.getBankImage(idbank);
    final isActive = status == "1";
    final gradient = _bankGradients[colorIdx % _bankGradients.length];
    final initial =
        bankName.isNotEmpty ? bankName[0].toUpperCase() : '?';
    final statusColor =
        isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _selectAccount(idaccount, data),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Bank avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: bankImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: bankImage,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            errorWidget: (ctx, url, err) => Center(
                              child: Text(initial,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20)),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20)),
                        ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameaccount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Bank chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: gradient[0].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          bankName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: gradient[0],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  children: [
                    _iconBtn(Icons.edit_rounded, const Color(0xFF8B5CF6),
                        () => _selectAccount(idaccount, data)),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.delete_rounded, const Color(0xFFEF4444),
                        () => _confirmDeleteAccount(idaccount)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(String label, Color focusColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

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
    if (mounted) setState(() {});
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
    if (mounted) setState(() {});
  }

  Future<void> _confirmDeleteAccount(String idAccount) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Account',
                style: TextStyle(fontWeight: FontWeight.w800)),
            content: const Text(
                'Are you sure you want to delete this account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete',
                    style: TextStyle(color: Color(0xFFEF4444))),
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
    if (mounted) setState(() {});
  }
}

// ─── Clipper ──────────────────────────────────────────────────────────────────

class _AccountsHeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 50)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
