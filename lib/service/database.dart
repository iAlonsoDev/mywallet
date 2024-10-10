import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  //Banks
  Future addBankDetails(
      Map<String, dynamic> insertBankInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Banks")
        .doc(id)
        .set(insertBankInfoMap);
  }

  Future<Stream<QuerySnapshot>> getBankDetails() async {
    return FirebaseFirestore.instance.collection("Banks").snapshots();
  }

  Future updateBankDetails(
      Map<String, dynamic> updateBankInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Banks")
        .doc(id as String?)
        .update(updateBankInfoMap);
  }

  Future deleteBankDetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("Banks")
        .doc(id)
        .delete();
  }

  //Accounts
  Future addAccountDetails(
      Map<String, dynamic> insertAccountInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Accounts")
        .doc(id)
        .set(insertAccountInfoMap);
  }

  Future<Stream<QuerySnapshot>> getAccountDetails() async {
    return FirebaseFirestore.instance.collection("Accounts").snapshots();
  }

  Future updateAccountDetails(
      Map<String, dynamic> updateAccountInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Accounts")
        .doc(id as String?)
        .update(updateAccountInfoMap);
  }

  Future deleteAccountDetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("Accounts")
        .doc(id)
        .delete();
  }

  // Transactions
  Future addTransactionDetails(
      Map<String, dynamic> insertTransactionInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Transactions")
        .doc(id)
        .set(insertTransactionInfoMap);
  }

  Future<Stream<QuerySnapshot>> getTransactionDetails() async {
    return FirebaseFirestore.instance
        .collection("Transactions")
        .orderBy("idtransaction", descending: true)
        .limit(100)
        .snapshots();
  }

  Future updateTransactionDetails(
      Map<String, dynamic> updateTransactionInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Transactions")
        .doc(id as String?)
        .update(updateTransactionInfoMap);
  }

  Future deleteTransactionDetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("Transactions")
        .doc(id)
        .delete();
  }


}
