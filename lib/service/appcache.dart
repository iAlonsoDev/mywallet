import 'package:cloud_firestore/cloud_firestore.dart';

class AppCache {
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;
  AppCache._internal();

  // ===== Colecciones cacheadas =====
  List<Map<String, dynamic>> transactions = [];

  /// 🔹 Ahora cada bank/account es:
  Map<String, Map<String, String>> banksMap = {};
  Map<String, Map<String, String>> accountsMap = {};

  // ===== Inicialización =====
  Future<void> loadStaticData() async {
    await Future.wait([
      _loadBanks(),
      _loadAccounts(),
      _loadTransactions(),
    ]);
  }

  // ===== Banks =====
  Future<void> _loadBanks() async {
    final snapshot = await FirebaseFirestore.instance.collection("Banks").get();
    banksMap = {
      for (var doc in snapshot.docs)
        doc["idbank"].toString(): {
          "name": (doc["namebank"] ?? "").toString(),
          "status": (doc["status"] ?? "0").toString(),
        }
    };
  }

  // ===== Accounts =====
  Future<void> _loadAccounts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("Accounts").get();
    accountsMap = {
      for (var doc in snapshot.docs)
        doc["idaccount"].toString(): {
          "idbank": (doc["idbank"] ?? "0").toString(),
          "name": (doc["nameaccount"] ?? "").toString(),
          "status": (doc["status"] ?? "0").toString(),
        }
    };
  }

  // ===== Transactions =====
  Future<void> _loadTransactions() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("Transactions").get();
    transactions = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "idtransaction": data["idtransaction"].toString(),
        "idbank": data["idbank"].toString(),
        "idaccount": data["idaccount"].toString(),
        "amount": (data["amount"] ?? 0).toDouble(),
        "summary": (data["summary"] ?? 0).toDouble(),
        "details": (data["details"] ?? "").toString(),
        "date": (data["date"] as Timestamp?)?.toDate() ?? DateTime.now(),
      };
    }).toList();
  }

  // ===== Helpers =====
  String getBankName(String id) => banksMap[id]?["name"] ?? "Unknown";
  String getBankStatus(String id) => banksMap[id]?["status"] ?? "0";

  String getAccountName(String id) => accountsMap[id]?["name"] ?? "Unknown";
  String getAccountStatus(String id) => accountsMap[id]?["status"] ?? "0";
}
