import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/service/database.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:random_string/random_string.dart';
import 'package:toastification/toastification.dart';

class Bank {
  final String idbank;
  final String namebank;
  final String statusbank;

  Bank(
      {required this.idbank, required this.namebank, required this.statusbank});
}

class AllBank {
  final String allidbank;
  final String allnamebank;
  final String allstatusbank;

  AllBank(
      {required this.allidbank,
      required this.allnamebank,
      required this.allstatusbank});
}

class Account {
  final String idaccount;
  final String nameaccount;
  final String statusaccount;

  Account(
      {required this.idaccount,
      required this.nameaccount,
      required this.statusaccount});
}

class AllAccount {
  final String allidaccount;
  final String allnameaccount;
  final String allstatusaccount;

  AllAccount(
      {required this.allidaccount,
      required this.allnameaccount,
      required this.allstatusaccount});
}

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  //para mandar los textbox
  TextEditingController detailscontroller = TextEditingController();
  TextEditingController amountcontroller = TextEditingController();
  TextEditingController summarycontroller = TextEditingController();
  final TextEditingController datecontroller = TextEditingController();

  String _selectedType = 'DEPOSIT'; // Valor inicial por defecto
  String idedit = '';
  String idcontroller = '';
  String idbankcontroller = '';
  String idaccountcontroller = '';
  double totSummary = 0.0;

  late List<Bank> _banks = <Bank>[]; // Lista para almacenar los bancos
  late Bank _selectedBank; // Bank seleccionado

  late List<AllBank> _allbanks = <AllBank>[];
  late AllBank _selectedallBank;

  late List<Account> _accounts =
      <Account>[]; // Lista para almacenar las cuentas
  late Account _selectedAccount; // cuenta seleccionada

  late List<AllAccount> _allaccounts = <AllAccount>[];
  late AllAccount _selectedallAccount;

  //para traer la data
  // ignore: non_constant_identifier_names
  Stream? TransactionsStream;

  getontheload() async {
    TransactionsStream = await DatabaseMethods().getTransactionDetails();
    setState(() {});
    getTotal();
  }

  @override
  void initState() {
    getontheload();
    super.initState();

    //load
    // _selectedType = 'ACTIVE';

    _selectedBank = Bank(
        idbank: '0',
        namebank: 'BANKS',
        statusbank: '0'); // Valor inicial predeterminado
    fetchBanksData();

    _selectedallBank = AllBank(
        allidbank: '0',
        allnamebank: 'BANKS',
        allstatusbank: '0'); // Valor inicial predeterminado
    fetchallBanksData();

    _selectedAccount = Account(
        idaccount: '0',
        nameaccount: 'ACCOUNTS',
        statusaccount: '0'); // Valor inicial predeterminado
    fetchAccountsData();

    _selectedallAccount = AllAccount(
        allidaccount: '0',
        allnameaccount: 'ACCOUNTS',
        allstatusaccount: '0'); // Valor inicial predeterminado
    fetchallAccountsData();

    //cargar next id
    getNextId().then((values) {
      // Establece el valor del TextEditingController con el próximo ID
      idcontroller = values["maxId"].toString();
    });
  }

//para traer la data
  Widget alltransactionsDetails() {
    return StreamBuilder(
      stream: TransactionsStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];

              DateTime date = ds["date"].toDate();
              // Formatea el DateTime como desees usando la clase DateFormat
              String formattedDate =
                  DateFormat('yyyy-MM-dd hh:mm a').format(date);

              return Column(
                children: [
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(3),
                    borderOnForeground: true,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: InkWell(
                      onTap: () async {
                        // Mostrar el cuadro de diálogo de confirmación
                        bool confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: const Text(
                                  '¿Are you sure to select this item?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Confirm'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((value) => value ?? false);

                        if (confirmed) {
                          // Establecer los valores en los controladores de texto cuando se haga clic
                          idcontroller = ds["idtransaction"].toString();
                          idedit = ds["idtransaction"].toString();
                          idbankcontroller = ds["idbank"].toString();
                          detailscontroller.text =
                              ds["details"].toString().toUpperCase();
                          idaccountcontroller = ds["idaccount"].toString();

                          // Recargar los datos de los bancos y actualizar el banco seleccionado
                          fetchBanksData().then((_) {
                            setState(() {
                              _selectedType = ds["type"].toString();

                              // Obtener el ID del banco como cadena
                              var idBank = ds["idbank"].toString();

                              // Buscar el banco en la lista _banks
                              var matchingBank = _banks.firstWhereOrNull(
                                  (bank) => bank.idbank == idBank);

                              // Establecer el banco seleccionado
                              _selectedBank = matchingBank ??
                                  Bank(
                                      idbank: '0',
                                      namebank: 'BANKS',
                                      statusbank: '0');
                            });
                          });

                          // Recargar los datos de los bancos y actualizar el banco seleccionado
                          fetchallBanksData().then((_) {
                            setState(() {
                              _selectedType = ds["type"].toString();

                              // Obtener el ID del banco como cadena
                              var idallBank = ds["idbank"].toString();

                              // Buscar el banco en la lista _banks
                              var matchingallBank = _allbanks.firstWhereOrNull(
                                  (allbank) => allbank.allidbank == idallBank);

                              // Establecer el banco seleccionado
                              _selectedallBank = matchingallBank ??
                                  AllBank(
                                      allidbank: '0',
                                      allnamebank: 'BANKS',
                                      allstatusbank: '0');
                            });
                          });

                          // Recargar los datos de los bancos y actualizar el banco seleccionado
                          fetchAccountsData().then((_) {
                            setState(() {
                              // Obtener el ID del banco como cadena
                              var idAccount = ds["idaccount"].toString();

                              // Buscar el banco en la lista _banks
                              var matchingAccounts = _accounts.firstWhereOrNull(
                                  (account) => account.idaccount == idAccount);

                              // Establecer el banco seleccionado
                              _selectedAccount = matchingAccounts ??
                                  Account(
                                      idaccount: '0',
                                      nameaccount: 'ACCOUNTS',
                                      statusaccount: '0');
                            });
                          });

                          // Recargar los datos de los bancos y actualizar el banco seleccionado
                          fetchallAccountsData().then((_) {
                            setState(() {
                              // Obtener el ID del banco como cadena
                              var idallAccount = ds["idaccount"].toString();

                              // Buscar el banco en la lista _banks
                              var matchingallAccounts =
                                  _allaccounts.firstWhereOrNull((allaccount) =>
                                      allaccount.allidaccount == idallAccount);

                              // Establecer el banco seleccionado
                              _selectedallAccount = matchingallAccounts ??
                                  AllAccount(
                                      allidaccount: '0',
                                      allnameaccount: 'ACCOUNTS',
                                      allstatusaccount: '0');
                            });
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30.0),
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 8.0,
                                      color: Color.fromARGB(255, 73, 71, 71),
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Truncar el texto si es demasiado largo
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    ds["details"].toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13.0,
                                      color: Color.fromARGB(255, 73, 71, 71),
                                    ),
                                    overflow: TextOverflow
                                        .clip, // Truncar el texto si es demasiado largo
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Delete!"),
                                          content: const Text(
                                              "Are you sure to delete this transaction?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Cierra el cuadro de diálogo sin eliminar
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // Elimina el banco si el usuario confirma
                                                await DatabaseMethods()
                                                    .deleteTransactionDetails(
                                                        ds["idtransaction"]
                                                            .toString());
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context)
                                                    .pop(); // Cierra el cuadro de diálogo
                                                idcontroller = '';
                                                idbankcontroller = '';
                                                idaccountcontroller = '';
                                                detailscontroller.text = '';
                                                amountcontroller.text = '';
                                                summarycontroller.text = '';
                                                datecontroller.text = '';
                                                toastification.show(
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  title: const Text(
                                                      "Transactions has been deleted successfully"),
                                                  autoCloseDuration:
                                                      const Duration(
                                                          seconds: 3),
                                                  style:
                                                      ToastificationStyle.flat,
                                                  type:
                                                      ToastificationType.error,
                                                );
                                                //cargar next id
                                                getNextId().then((values) {
                                                  // Establece el valor del TextEditingController con el próximo ID
                                                  idcontroller = values["maxId"]
                                                      .toString();
                                                });
                                                getTotal();
                                                fetchBanksData();
                                                fetchAccountsData();
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Icon(Icons.delete,
                                      color: Color.fromARGB(255, 238, 56, 43)),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  //width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start, // Alinea los elementos a la izquierda
                                        children: [
                                          Text(
                                            "Amount: ${formatAmount(ds["amount"])}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                              color: ds["type"] == "DEPOSIT"
                                                  ? const Color.fromARGB(
                                                      255, 55, 196, 60)
                                                  : const Color.fromARGB(
                                                      255, 238, 56, 43),
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Truncar el texto si es demasiado largo
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              //width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Alinea los elementos a la izquierda
                                    children: [
                                      Text(
                                        "Summary: ${formatAmount(ds["summary"])}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0,
                                          color:
                                              Color.fromARGB(255, 92, 90, 90),
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Truncar el texto si es demasiado largo
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              //width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Alinea los elementos a la izquierda
                                    children: [
                                      Text(
                                        (() {
                                          // Obtener el ID del banco como cadena
                                          var allidBank =
                                              ds["idbank"].toString();

                                          // Buscar la cuenta en la lista _accounts
                                          var matchingallBank = _allbanks
                                              .firstWhereOrNull((allbank) =>
                                                  allbank.allidbank ==
                                                  allidBank);

                                          // Si se encontró una cuenta correspondiente, devuelve su nombre; de lo contrario, devuelve una cadena predeterminada
                                          return matchingallBank != null
                                              ? matchingallBank.allnamebank
                                              : 'UNKNOWN';
                                        })(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11.0,
                                          color: Color.fromARGB(
                                              255, 167, 165, 165),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        (() {
                                          // Obtener el ID de la cuenta como cadena
                                          var allidAccount =
                                              ds["idaccount"].toString();

                                          // Buscar la cuenta en la lista _accounts
                                          var matchingallAccount = _allaccounts
                                              .firstWhereOrNull((allaccount) =>
                                                  allaccount.allidaccount ==
                                                  allidAccount);

                                          // Si se encontró una cuenta correspondiente, devuelve su nombre; de lo contrario, devuelve una cadena predeterminada
                                          return matchingallAccount != null
                                              ? matchingallAccount
                                                  .allnameaccount
                                              : 'UNKNOWN';
                                        })(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11.0,
                                          color: Color.fromARGB(
                                              255, 167, 165, 165),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11.0,
                                      color: Color.fromARGB(255, 167, 165, 165),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 6.0,
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

                  const SizedBox(
                      height: 10), // Espacio entre "burbujas" de registros
                ],
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
//para traer la data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 246, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(243, 244, 246, 247),
        title: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            const Text(
              "    Transactions",
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
                width: 260, // Ancho deseado para la burbuja
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
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15.0, right: 23.0),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 207, 215, 223),
              ),
              child: DropdownButton<Bank>(
                value: _selectedBank,
                onChanged: (Bank? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBank = newValue;
                      idbankcontroller = newValue.idbank;
                    });

                    if (idedit == '') {
                      fetchAccountsData();
                    } else {
                      fetchallAccountsData();
                    }
                  }
                },
                style: const TextStyle(
                  color: Color.fromARGB(255, 20, 20, 20),
                  fontSize: 14.0,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                underline: const SizedBox(),
                isExpanded: true,
                alignment:
                    Alignment.center, // Alinea el contenido verticalmente
                borderRadius: BorderRadius.circular(10),
                dropdownColor: const Color.fromARGB(255, 234, 236, 238),
                focusColor: const Color.fromARGB(255, 146, 147, 148),
                items: _banks.map<DropdownMenuItem<Bank>>((Bank bank) {
                  return DropdownMenuItem<Bank>(
                    value: bank,
                    child: Center(
                      child: Text(
                        bank.namebank,
                        textAlign:
                            TextAlign.center, // Alinea el texto horizontalmente
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(
              height: 15.0,
            ),

            Container(
              padding: const EdgeInsets.only(left: 15.0, right: 23.0),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 207, 215, 223),
              ),
              child: DropdownButton<Account>(
                value: _selectedAccount,
                onChanged: (Account? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedAccount = newValue;
                      idaccountcontroller = newValue.idaccount;
                    });
                  }
                },
                style: const TextStyle(
                  color: Color.fromARGB(255, 20, 20, 20),
                  fontSize: 14.0,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                underline: const SizedBox(),
                isExpanded: true,
                alignment:
                    Alignment.center, // Alinea el contenido verticalmente
                borderRadius: BorderRadius.circular(10),
                dropdownColor: const Color.fromARGB(255, 234, 236, 238),
                focusColor: const Color.fromARGB(255, 146, 147, 148),
                items:
                    _accounts.map<DropdownMenuItem<Account>>((Account account) {
                  return DropdownMenuItem<Account>(
                    value: account,
                    child: Center(
                      child: Text(
                        account.nameaccount,
                        textAlign:
                            TextAlign.center, // Alinea el texto horizontalmente
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(
              height: 5.0,
            ),

            Container(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              //decoration: BoxDecoration(
              //border: Border.all(),
              //borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: detailscontroller,
                decoration: const InputDecoration(
                    //border: InputBorder.none,
                    hintText: "Transactions Details"),
                style: const TextStyle(fontSize: 16.0),
              ),
            ),

            const SizedBox(
              height: 5.0,
            ),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                    child: TextField(
                      textAlign: TextAlign.right,
                      controller: amountcontroller,
                      decoration: const InputDecoration(
                        hintText: "Amount",
                      ),
                      style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 131, 130, 130)),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        double amount = double.tryParse(value) ?? 0.0;
                        setState(() {
                          //este evento es manejado por la cantidad ingresada son valores por default y luego van siendo calculados.
                          summarycontroller
                              .text = (((double.parse(summarycontroller.text) +
                                          amount) -
                                      double.parse(summarycontroller.text)) +
                                  totSummary)
                              .toStringAsFixed(2);
                          _selectedType =
                              (amount > 0) ? 'DEPOSIT' : 'WITHDRAWAL';
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5.0, right: 10.0),
                    child: TextField(
                      textAlign: TextAlign.right,
                      readOnly: true,
                      selectionControls: null,
                      controller: summarycontroller,
                      decoration: const InputDecoration(
                        hintText: "Summary",
                      ),
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 131, 130, 130),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15.0,
            ),

            Container(
              padding: const EdgeInsets.only(left: 15.0, right: 23.0),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                // border:
                //   Border.all(color: const Color.fromARGB(255, 177, 175, 175)),
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 86, 153, 219),
              ),
              child: DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
                style: const TextStyle(
                  color: Color.fromARGB(255, 20, 20, 20),
                  fontSize: 14.0,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                underline: const SizedBox(),
                isExpanded:
                    true, // Hace que el DropdownButton ocupe todo el ancho
                alignment:
                    Alignment.center, // Alinea el contenido verticalmente
                borderRadius: BorderRadius.circular(10),
                dropdownColor: const Color.fromARGB(255, 234, 236, 238),
                focusColor: const Color.fromARGB(255, 146, 147, 148),
                items: <String>['DEPOSIT', 'WITHDRAWAL']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                        child: Text(value)), // Centra el texto verticalmente
                  );
                }).toList(),
              ),
            ),

            const SizedBox(
              height: 15.0,
            ),

            //para realizar el crud
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: () async {
                      if (idedit == '') {
                        //para capturar fecha y hora
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2010, 1, 1),
                          lastDate: DateTime(2150, 12, 31),
                        );

                        // Abre el selector de hora y espera a que el usuario seleccione una hora
                        TimeOfDay? pickedTime = await showTimePicker(
                          // ignore: use_build_context_synchronously
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        // Combinar la fecha seleccionada con la hora seleccionada
                        if (pickedTime != null) {
                          pickedDate = DateTime(
                            pickedDate!.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          // Actualiza el valor del TextField con la fecha y hora seleccionadas
                          setState(() {
                            datecontroller.text = pickedDate
                                .toString(); // Actualiza el valor del TextField
                          });
                        }
                        //para capturar fecha y hora

                        int idtransaction = int.parse(idcontroller);
                        int idaccount = int.parse(idaccountcontroller);
                        int idbank = int.parse(idbankcontroller);
                        double idamount = double.parse(amountcontroller.text);
                        double idsummary = double.parse(summarycontroller.text);
                        DateTime dateTime = DateTime.parse(datecontroller.text);

                        Map<String, dynamic> insertTransactionInfoMap = {
                          "amount": idamount,
                          "date": dateTime,
                          "details": detailscontroller.text.toUpperCase(),
                          "idtransaction": idtransaction,
                          "idaccount": idaccount, //idcontroller.text,
                          "idbank": idbank,
                          "summary": idsummary,
                          "type": _selectedType,
                          //"Id": codeId,
                        };
                        await DatabaseMethods()
                            .addTransactionDetails(insertTransactionInfoMap,
                                idtransaction.toString())
                            .then((value) {
                          // Si la operación se completó correctamente
                          idcontroller = '';
                          idbankcontroller = '';
                          idaccountcontroller = '';
                          detailscontroller.text = '';
                          amountcontroller.text = '';
                          summarycontroller.text = '';
                          datecontroller.text = '';
                          toastification.show(
                            // ignore: use_build_context_synchronously
                            context: context,
                            title: const Text(
                                'Registration Transactions has been successful!'),
                            autoCloseDuration: const Duration(seconds: 3),
                            style: ToastificationStyle.flat,
                            type: ToastificationType.success,
                          );
                        }).catchError((error) {
                          // Si ocurrió un error
                          toastification.show(
                            // ignore: use_build_context_synchronously
                            context: context,
                            title: const Text('An error occurred'),
                            autoCloseDuration: const Duration(seconds: 3),
                            style: ToastificationStyle.flat,
                            type: ToastificationType.error,
                          );
                        });
                        //cargar next id
                        getNextId().then((values) {
                          // Establece el valor del TextEditingController con el próximo ID
                          idcontroller = values["maxId"].toString();
                        });
                        getTotal();
                        idedit = '';
                        fetchBanksData();
                        fetchAccountsData();
                      } else {
                        toastification.show(
                          context: context,
                          title: const Text('Only udpate is valid'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.error,
                        );
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 65, 62, 62)),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () async {
                      int idtransaction = int.parse(idcontroller);
                      int idaccount = int.parse(idaccountcontroller);
                      int idbank = int.parse(idbankcontroller);
                      //String codeId = randomAlphaNumeric(10);
                      Map<String, dynamic> updateTransactionInfoMap = {
                        "idtransaction": idtransaction,
                        "idaccount": idaccount,
                        "idbank": idbank,
                        "details": detailscontroller.text.toUpperCase(),
                        "type": _selectedType,
                        //"Id": codeId,
                      };
                      await DatabaseMethods()
                          .updateTransactionDetails(updateTransactionInfoMap,
                              idtransaction.toString())
                          .then((value) {
                        // Si la operación se completó correctamente
                        idcontroller = '';
                        idbankcontroller = '';
                        idaccountcontroller = '';
                        detailscontroller.text = '';
                        idedit = '';
                        toastification.show(
                          // ignore: use_build_context_synchronously
                          context: context,
                          title:
                              const Text('Update account has been successful!'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.info,
                        );
                      }).catchError((error) {
                        // Si ocurrió un error
                        toastification.show(
                          // ignore: use_build_context_synchronously
                          context: context,
                          title: const Text('An error occurred'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.error,
                        );
                      });
                      //cargar next id
                      getNextId().then((values) {
                        // Establece el valor del TextEditingController con el próximo ID
                        idcontroller = values["maxId"].toString();
                      });
                      getTotal();
                      idedit = '';
                      fetchBanksData();
                      fetchAccountsData();
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 65, 62, 62)),
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
            ),
            //para realizar el crud

            const SizedBox(
              height: 15.0,
            ),

            Expanded(child: alltransactionsDetails()),
          ],
        ),
      ),
    );
  }

  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(locale: 'en-US', symbol: 'Lps. ');
    String formattedAmount = formatter.format(amount);

    // Verificar si el número formateado es "-0" y reemplazarlo por "0"
    if (formattedAmount == "-Lps. 0.00") {
      formattedAmount = "Lps. 0.00";
    }

    return formattedAmount;
  }

  Future<Map> getNextId() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Transactions")
          .orderBy("idtransaction", descending: true)
          .limit(1)
          .get();

      int maxId = 0;

      if (querySnapshot.docs.isNotEmpty) {
        maxId = querySnapshot.docs.first["idtransaction"] as int;
      }

      return {"maxId": maxId + 1};
    } catch (e) {
      return {"maxId": 0};
    }
  }

  // Método para obtener el total de las transacciones
  Future<void> getTotal() async {
    double suma = 0.0;

    CollectionReference transacciones =
        FirebaseFirestore.instance.collection('Transactions');
    QuerySnapshot querySnapshot = await transacciones.get();

    // Iterar sobre los documentos y sumar los valores de "amount"
    for (var doc in querySnapshot.docs) {
      double amount = doc['amount'];
      suma += amount;
    }

    setState(() {
      totSummary = (suma * 100).round() / 100;
      summarycontroller.text = totSummary.toString();
    });
  }

  Future<void> fetchBanksData() async {
    Query<Map<String, dynamic>> banks = FirebaseFirestore.instance
        .collection('Banks')
        .orderBy("namebank", descending: false);
    var querySnapshot = await banks.get();
    List<Bank> banksList =
        []; // Inicializa la lista con un elemento predeterminado

    if (idedit == '') {
      for (var doc in querySnapshot.docs) {
        if (doc.exists && doc['status'].toString() == '1') {
          banksList.add(Bank(
              idbank: doc.id,
              namebank: doc['namebank'],
              statusbank: doc['status']));
        }
      }
      fetchAccountsData();
    } else {
      for (var doc in querySnapshot.docs) {
        banksList.add(Bank(
            idbank: doc.id,
            namebank: doc['namebank'],
            statusbank: doc['status']));
      }
      fetchallAccountsData();
    }

    setState(() {
      _banks = banksList;
      if (_banks.isNotEmpty) {
        _selectedBank = _banks[0];
        if (idedit == '') {
          idbankcontroller = _banks[0].idbank.toString();
        }
      } else {
        _selectedBank = Bank(idbank: '0', namebank: 'BANKS', statusbank: '0');
      }
    });
  }

  Future<void> fetchallBanksData() async {
    Query<Map<String, dynamic>> allbanks = FirebaseFirestore.instance
        .collection('Banks')
        .orderBy("namebank", descending: false);
    var querySnapshot = await allbanks.get();
    List<AllBank> allbanksList =
        []; // Inicializa la lista con un elemento predeterminado

    for (var doc in querySnapshot.docs) {
      allbanksList.add(AllBank(
          allidbank: doc.id,
          allnamebank: doc['namebank'],
          allstatusbank: doc['status']));
    }

    setState(() {
      _allbanks = allbanksList;
      if (_allbanks.isNotEmpty) {
        _selectedallBank = _allbanks[0];
        //idbankcontroller.text = _allbanks[0].allid.toString();
      } else {
        _selectedallBank =
            AllBank(allidbank: '0', allnamebank: 'BANKS', allstatusbank: '0');
      }
    });
  }

  Future<void> fetchAccountsData() async {
    QuerySnapshot<Map<String, dynamic>> accountsSnapshot =
        await FirebaseFirestore.instance
            .collection('Accounts')
            .orderBy("nameaccount", descending: false)
            .get();
    List<Account> accountsList = [];

    if (idedit == '') {
      for (var doc in accountsSnapshot.docs) {
        if (doc.exists &&
            doc['idbank'].toString() == idbankcontroller &&
            doc['status'].toString() == '1') {
          accountsList.add(Account(
              idaccount: doc.id,
              nameaccount: doc['nameaccount'],
              statusaccount: doc['status']));
        }
      }
    } else {
      for (var doc in accountsSnapshot.docs) {
        accountsList.add(Account(
            idaccount: doc.id,
            nameaccount: doc['nameaccount'],
            statusaccount: doc['status']));
      }
    }
    setState(() {
      _accounts = accountsList;
      if (_accounts.isNotEmpty) {
        _selectedAccount = _accounts[0];
        if (idedit == '') {
          idaccountcontroller = _accounts[0].idaccount.toString();
        }
      } else {
        _selectedAccount = Account(
            idaccount: '0', nameaccount: 'ACCOUNTS', statusaccount: '0');
      }
    });
  }

  Future<void> fetchallAccountsData() async {
    QuerySnapshot<Map<String, dynamic>> allaccountsSnapshot =
        await FirebaseFirestore.instance
            .collection('Accounts')
            .orderBy("nameaccount", descending: false)
            .get();
    List<AllAccount> allaccountsList = [];

    for (var doc in allaccountsSnapshot.docs) {
      allaccountsList.add(AllAccount(
          allidaccount: doc.id,
          allnameaccount: doc['nameaccount'],
          allstatusaccount: doc['status']));
    }

    setState(() {
      _allaccounts = allaccountsList;
      if (_allaccounts.isNotEmpty) {
        _selectedallAccount = _allaccounts[0];
      } else {
        _selectedallAccount = AllAccount(
            allidaccount: '0',
            allnameaccount: 'ACCOUNTS',
            allstatusaccount: '0');
      }
    });
  }
}
