import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/pages/banks.dart';
import 'package:mywallet/pages/accounts.dart';
import 'package:mywallet/pages/transactions.dart';
import 'package:flutter/material.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';


import 'dart:async';
import 'package:flutter_echarts/flutter_echarts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Firestore Example',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  double totalbalance = 0.0;
  double totalavailable = 0.0;
  double bestranking = 0.0;
  double lasttransaction = 0.0;
  double topaccount = 0.0;
  var bestaccount = "";

  QuerySnapshot? transactionsSnapshot;

  Future<void> fetchTransactions() async {
    // Asigna el resultado a la variable pública
    transactionsSnapshot =
        await FirebaseFirestore.instance.collection('Transactions').get();
  }

  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    fetchTransactions();
    fetchTransactions().then((_) {
      // Ahora que transactionsSnapshot está inicializado, podemos actualizar los valores
      _updategetTotalTransactionsSummary();
      _updategetTotalAmountAvailable();
      _updategetBestRanking();
      _updategetLastTransaction();
      _updategetTopBank();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            const Text(
              "  MyWallet",
              style: TextStyle(
                color: Color.fromARGB(221, 80, 75, 75),
                fontSize: 30.0,
                decorationColor: Color.fromARGB(221, 40, 70, 204),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 5), // Ajusta la posición de la burbuja
              child: SizedBox(
                width: 180, // Ancho deseado para la burbuja
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30), // Agrega relleno solo horizontalmente
                  height: 10, // Altura de la burbuja
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.blue), // Borde con color azul
                    borderRadius: BorderRadius.circular(20), // Borde redondeado
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25.0),
            Text(
              formatAmount(totalbalance),
              style: const TextStyle(
                fontSize: 30.0,
                color: Color.fromARGB(255, 47, 49, 46),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'TOTAL MONEY',
              style: TextStyle(
                fontSize: 12.0,
                color: Color.fromARGB(255, 63, 63, 63),
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              '________________________________________________________________',
              style: TextStyle(
                fontSize: 11.0,
                color: Color.fromARGB(255, 197, 197, 197),
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 20.0),
            // caja 1 - 2
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Centra los recuadros horizontalmente
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0), // Margen a ambos lados
                    child: Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 245, 243, 250),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BEST RANKING',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formatAmount(bestranking),
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0), // Margen a ambos lados
                    child: Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 245, 243, 250),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL AVAILABLE',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formatAmount(totalavailable),
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10.0),
            // caja 3-4
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Centra los recuadros horizontalmente
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0), // Margen a ambos lados
                    child: Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 245, 243, 250),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOP - $bestaccount',
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formatAmount(topaccount),
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0), // Margen a ambos lados
                    child: Material(
                      elevation: 8.0,
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 245, 243, 250),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LAST TRANSACTION',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formatAmount(lasttransaction),
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 40.0),

            Center(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getTopBanks(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data;

                    if (data == null || data.isEmpty) {
                      return const Text('Data is loading...');
                    }

                    return SizedBox(
                      width: 400,
                      height: 400,
                      child: Echarts(
                        option: '''
            {
              tooltip: {
                trigger: 'item',
                formatter: '{b} <br/>{a}: {c}'
              },
              legend: {
                orient: 'horizontal',
                data: ${data.map((e) => '"${e['namebank']}"').toList()},
              },
              series: [
                {
                  name: 'Amount',
                  type: 'pie',
                  radius: ['50%', '70%'],
                  avoidLabelOverlap: true,
                  label: {
                    show: true,
                    position: 'center'
                  },
                  emphasis: {
                    label: {
                      show: true,
                      fontSize: '16',
                      fontWeight: 'normal',
                    }
                  },
                  labelLine: {
                    show: true
                  },
                  data: ${data.map((e) => '{"value": ${e['totalAmount'].toStringAsFixed(2)}, "name": "${e['namebank']}"}').toList()}
                }
              ]
            }
            ''',
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 30.0),

            Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getTopAccounts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final List<Map<String, dynamic>> accountsData =
                          snapshot.data ?? [];
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: ListView.builder(
                          //shrinkWrap: true,
                          itemCount: accountsData.length,
                          itemBuilder: (context, index) {
                            final account = accountsData[index];
                            final String accountName = account['nameAccount'];
                            final String bankName = account['nameBank'];
                            final double accountAmount = account['totalAmount'];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(5),
                                    borderOnForeground: true,
                                    color: const Color.fromARGB(
                                        255, 245, 243, 250),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 0.5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$bankName, $accountName',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12.0,
                                                  color: Color.fromARGB(
                                                      255, 92, 90, 90),
                                                ),
                                              ),
                                              Text(
                                                formatAmount(accountAmount),
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: accountAmount < 0
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionBubble(
        items: [
          Bubble(
            title: "Refresh",
            iconColor: const Color.fromARGB(255, 238, 233, 233),
            bubbleColor: const Color.fromARGB(255, 86, 153, 219),
            icon: Icons.refresh,
            titleStyle: const TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 238, 233, 233)),
            onPress: () {
              setState(() {
                fetchTransactions().then((_) {
                  // Ahora que transactionsSnapshot está inicializado, podemos actualizar los valores
                  _updategetTotalTransactionsSummary();
                  _updategetTotalAmountAvailable();
                  _updategetBestRanking();
                  _updategetLastTransaction();
                  _updategetTopBank();
                });
              });
            },
          ),
          // Floating action menu item
          Bubble(
            title: "Banks",
            iconColor: const Color.fromARGB(255, 238, 233, 233),
            bubbleColor: const Color.fromARGB(255, 86, 153, 219),
            icon: Icons.account_balance,
            titleStyle: const TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 238, 233, 233)),
            onPress: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Banks()));
            },
          ),
          // Floating action menu item
          Bubble(
            title: "Accounts",
            iconColor: const Color.fromARGB(255, 238, 233, 233),
            bubbleColor: const Color.fromARGB(255, 86, 153, 219),
            icon: Icons.menu_book,
            titleStyle: const TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 238, 233, 233)),
            onPress: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Accounts()));
            },
          ),
          //Floating action menu item
          Bubble(
            title: "Transactions",
            iconColor: const Color.fromARGB(255, 238, 233, 233),
            bubbleColor: const Color.fromARGB(255, 86, 153, 219),
            icon: Icons.money,
            titleStyle: const TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 238, 233, 233)),
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Transactions()),
              );
            },
          ),
        ],
        animation: _animation,
        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        // Floating Action button Icon color
        iconColor: Colors.blue,
        // Flaoting Action button Icon
        iconData: Icons.add,
        backGroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
    );
  }

  //metodo para la grafica 1
  Future<List<Map<String, dynamic>>> _getTopBanks() async {
    // final topAccountsQuery = await FirebaseFirestore.instance
    //    .collection('Transactions')
    //   .orderBy('amount', descending: true)
    //   .get();

    //final topAccounts = topAccountsQuery.docs;
    //final topAccounts = transactionsSnapshot?.docs.toList();

    final Map<String, double> totalAmountsByBank =
        {}; // Mapa para almacenar los totales por banco

    if (transactionsSnapshot != null) {
      for (var account in transactionsSnapshot!.docs) {
        int idBank = account['idbank'];
        double totalAmount = account['amount'];

        // Sumar el monto al total del banco correspondiente
        totalAmountsByBank.update(
          idBank.toString(),
          (value) => value + totalAmount,
          ifAbsent: () => totalAmount,
        );
      }
    } else {
      return [];
    }

    // Obtener los nombres de los bancos en una sola consulta si hay datos en totalAmountsByBank
    if (totalAmountsByBank.isNotEmpty) {
      final bankSnapshots = await FirebaseFirestore.instance
          .collection('Banks')
          .where(FieldPath.documentId,
              whereIn: totalAmountsByBank.keys.toList())
          .get();

      // Convertir los snapshots en un mapa de nombres de bancos
      final bankNamesMap = {
        for (var snapshot in bankSnapshots.docs)
          snapshot.id: snapshot['namebank']
      };

      // Convertir el mapa en una lista de mapas para mantener la estructura original
      final List<Map<String, dynamic>> topBanksData = totalAmountsByBank.entries
          .where((entry) => entry.value >= 1 || entry.value <= -1)
          .map((entry) {
        final bankName = bankNamesMap[entry.key] ?? 'Unknown';
        return {
          'namebank': bankName, // Nombre del banco
          'totalAmount': entry.value, // Total acumulado para el banco
        };
      }).toList();

      return topBanksData;
    } else {
      // Manejar el caso donde totalAmountsByBank está vacío
      return []; // Retornar una lista vacía o manejarlo según tu lógica
    }
  }

  //metodo para la grafica 2
  Future<List<Map<String, dynamic>>> _getTopAccounts() async {
    // topTransactionsQuery = await FirebaseFirestore.instance
    //   .collection('Transactions')
    //  .orderBy('amount', descending: true)
    //   .get();

    //final topTransactions = topTransactionsQuery.docs;
    //final topTransactions = transactionsSnapshot?.docs.toList();

    final Map<String, double> totalAmountsByAccount = {};

    // Verificar que transactionsSnapshot no sea nulo
    if (transactionsSnapshot != null) {
      for (var transaction in transactionsSnapshot!.docs) {
        final int idAccount = transaction['idaccount'];
        final double totalAmount = transaction['amount'];
        totalAmountsByAccount.update(
            idAccount.toString(), (value) => (value) + totalAmount,
            ifAbsent: () => totalAmount);
      }
    } else {
      // Manejar el caso donde transactionsSnapshot es null
      return []; // Retornar una lista vacía o manejarlo según tu lógica
    }

    // Obtener los nombres de las cuentas si totalAmountsByAccount no está vacío
    if (totalAmountsByAccount.isNotEmpty) {
      final accountSnapshots = await FirebaseFirestore.instance
          .collection('Accounts')
          .where(FieldPath.documentId,
              whereIn: totalAmountsByAccount.keys.toList())
          .get();

      // Convertir los snapshots en un mapa de nombres de cuentas
      final Map<String, String> accountNamesMap = {
        for (var snapshot in accountSnapshots.docs)
          snapshot.id: snapshot['nameaccount']
      };

      // Obtener los nombres de los bancos si transactionsSnapshot no es nulo
      final bankIds = transactionsSnapshot!.docs
          .map((transaction) => transaction['idbank'].toString())
          .toSet();

      if (bankIds.isNotEmpty) {
        final bankSnapshots = await FirebaseFirestore.instance
            .collection('Banks')
            .where(FieldPath.documentId, whereIn: bankIds.toList())
            .get();

        // Convertir los snapshots en un mapa de nombres de bancos
        final Map<String, String> bankNamesMap = {
          for (var snapshot in bankSnapshots.docs)
            snapshot.id: snapshot['namebank']
        };

        // Construir la lista de resultados
        final List<Map<String, dynamic>> topAccountsData = totalAmountsByAccount
            .entries
            .where((entry) => entry.value >= 1 || entry.value <= -1)
            .map((entry) {
          final accountName = accountNamesMap[entry.key] ?? 'Unknown';
          final bankId = accountSnapshots.docs
              .firstWhere((doc) => doc.id == entry.key)['idbank'];
          final bankName = bankNamesMap[bankId.toString()] ?? 'Unknown';
          return {
            'nameAccount': accountName,
            'nameBank': bankName,
            'totalAmount': entry.value,
          };
        }).toList();

        topAccountsData
            .sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
        return topAccountsData;
      } else {
        return []; // Retornar una lista vacía o manejarlo según tu lógica
      }
    } else {
      // Manejar el caso donde totalAmountsByAccount está vacío
      return []; // Retornar una lista vacía o manejarlo según tu lógica
    }
  }

  // Método para formatear la cantidad como moneda
  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'en-US', symbol: 'L. ');
    String formattedAmount = formatter.format(amount);

    // Verificar si el número formateado es "-0" y reemplazarlo por "0"
    if (formattedAmount == "-L. 0.00") {
      formattedAmount = "L. 0.00";
    }

    return formattedAmount;
  }

  // Método para obtener el total de las transacciones
  Future<double> getTotalTransactionSummary() async {
    //QuerySnapshot snapshot = FirebaseFirestore.instance.collection("Transactions").get();

    double totSummary = 0.0;
    for (var doc in transactionsSnapshot!.docs) {
      totSummary += doc["amount"];
    }
    return totSummary;
  }

  Future<void> _updategetTotalTransactionsSummary() async {
    double totalS = await getTotalTransactionSummary();
    setState(() {
      totalbalance = totalS;
    });
  }

  // Método para obtener el total de las transacciones
  Future<double> getTotalAmountAvailable() async {
    // QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Transactions").get();
    double totavailable = 0.0;
    for (var doc in transactionsSnapshot!.docs) {
      if (doc.exists && doc['idbank'].toString() != '8') {
        totavailable += doc["amount"];
      }
    }
    return totavailable;
  }

  Future<void> _updategetTotalAmountAvailable() async {
    double totalA = await getTotalAmountAvailable();
    setState(() {
      totalavailable = totalA;
    });
  }

  // metodo para obtener el best ranking
  Future<double> getBestRanking() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Transactions")
        .orderBy("summary", descending: true)
        .limit(1)
        .get();
    double maxAmount = querySnapshot.docs.first["summary"];
    return maxAmount;
  }

  Future<void> _updategetBestRanking() async {
    double bestRank = await getBestRanking();
    setState(() {
      bestranking = bestRank;
    });
  }

  // metodo para obtener la ultima transaccion
  Future<double> getLastTransaction() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Transactions")
        .orderBy("date", descending: true)
        .limit(1)
        .get();
    double lastTrans = querySnapshot.docs.first["amount"];
    return lastTrans;
  }

  Future<void> _updategetLastTransaction() async {
    double lastTrans = await getLastTransaction();
    setState(() {
      lasttransaction = lastTrans;
    });
  }

  // metodo para traer la mejor cuenta y su respectivo banco
  Future<void> _updategetTopBank() async {
    //QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance.collection('Transactions').get();

    Map<int, double> totalMoneyPerBank = {};

    for (var transactionDoc in transactionsSnapshot!.docs) {
      final int idBank = transactionDoc['idbank'];
      final double amount = transactionDoc['amount'];

      if (totalMoneyPerBank.containsKey(idBank)) {
        totalMoneyPerBank[idBank] = (totalMoneyPerBank[idBank] ?? 0.0) + amount;
      } else {
        totalMoneyPerBank[idBank] = amount;
      }
    }

    int bankWithMostMoney = 0;
    double mostMoney = 0.0;

    totalMoneyPerBank.forEach((key, value) {
      if (value > mostMoney) {
        bankWithMostMoney = key;
        mostMoney = value;
      }
    });

    // Ahora tienes el id del banco (bankWithMostMoney) con más dinero.
    // Puedes usarlo para obtener el nombre correspondiente desde Firestore.

    final DocumentSnapshot bankDoc = await FirebaseFirestore.instance
        .collection('Banks')
        .doc(bankWithMostMoney.toString())
        .get();
    final String bankName = bankDoc['namebank'];

    setState(() {
      topaccount = mostMoney;
      bestaccount = bankName;
    });
  }
}
