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

  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController imagecontroller = TextEditingController();
  String _selectedStatus = 'ACTIVE';
  String idcontroller = '';
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
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    await cache.loadStaticData();
    if (mounted) setState(() {});
  }

  void _selectBank(String idbank, Map<String, String> data) {
    setState(() {
      idcontroller = idbank;
      namecontroller.text = data["name"] ?? '';
      imagecontroller.text = data["image"] ?? '';
      statuscontroller = data["status"] ?? '1';
      _selectedStatus = statuscontroller == '1' ? 'ACTIVE' : 'DISABLE';
    });
  }

  void _clearForm() {
    setState(() {
      idcontroller = '';
      namecontroller.clear();
      imagecontroller.clear();
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
                  _buildBankList(),
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
      clipper: _BanksHeroClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 70),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF0F172A), Color(0xFF1E3A8A)],
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
                    child: const Icon(Icons.account_balance_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Manage your institutions',
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
                      '${cache.banksMap.length} banks',
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
    final isEditing = idcontroller.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
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
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isEditing ? 'Edit Bank' : 'New Bank',
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

            // Name field
            TextField(
              controller: namecontroller,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              decoration: _inputDecoration('Bank Name', const Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 12),

            // Image + Status row
            Row(
              children: [
                Expanded(
                  child: UploadImageWidget(
                    initialImageUrl: imagecontroller.text.isNotEmpty
                        ? imagecontroller.text
                        : null,
                    onUploaded: (url) {
                      if (mounted) setState(() => imagecontroller.text = url);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildStatusToggle()),
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
    return GestureDetector(
      onTap: () => setState(() {
        statuscontroller = active ? '0' : '1';
        _selectedStatus = active ? 'DISABLE' : 'ACTIVE';
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              active ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
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
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    final c1 = isEditing ? const Color(0xFF14B8A6) : const Color(0xFF3B82F6);
    final c2 = isEditing ? const Color(0xFF0D9488) : const Color(0xFF2563EB);
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
        onPressed: _onSave,
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
              isEditing ? 'Update Bank' : 'Add Bank',
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

  // ─── Bank list ────────────────────────────────────────────────────────────

  Widget _buildBankList() {
    final banksList = cache.banksMap.entries.toList();
    if (banksList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text('No banks yet',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Bank List',
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${banksList.length} total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...banksList.asMap().entries.map((entry) {
            final i = entry.key;
            final idbank = entry.value.key;
            final data = entry.value.value;
            return _buildBankTile(idbank, data, i);
          }),
        ],
      ),
    );
  }

  Widget _buildBankTile(String idbank, Map<String, String> data, int index) {
    final namebank = data["name"] ?? "Unknown";
    final status = data["status"] ?? "0";
    final imageUrl = data["image"] ?? "";
    final isActive = status == "1";
    final gradient = _bankGradients[index % _bankGradients.length];
    final initial =
        namebank.isNotEmpty ? namebank[0].toUpperCase() : '?';
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
          onTap: () => _selectBank(idbank, data),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
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
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
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
                        namebank,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
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
                    _iconBtn(Icons.edit_rounded, const Color(0xFF3B82F6),
                        () => _selectBank(idbank, data)),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.delete_rounded, const Color(0xFFEF4444),
                        () => _confirmDeleteBank(idbank)),
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

  Future<void> _onSave() async {
    final isEditing = idcontroller.isNotEmpty;
    final idbank =
        isEditing ? int.parse(idcontroller) : await getNextId();

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

    _clearForm();
    await _loadBanks();
  }

  Future<int> getNextId() async {
    if (cache.banksMap.isEmpty) return 1;
    final maxId = cache.banksMap.keys
        .map((k) => int.tryParse(k) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<void> _confirmDeleteBank(String idBank) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Bank',
                style: TextStyle(fontWeight: FontWeight.w800)),
            content: const Text(
                'Are you sure you want to delete this bank?'),
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

// ─── Clipper ──────────────────────────────────────────────────────────────────

class _BanksHeroClipper extends CustomClipper<Path> {
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
