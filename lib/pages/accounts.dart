import 'package:mywallet/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:random_string/random_string.dart';
import 'package:toastification/toastification.dart';

class Bank {
  final String id;
  final String name;
  final String status;

  Bank({required this.id, required this.name, required this.status});
}

class AllBank {
  final String allid;
  final String allname;
  final String allstatus;

  AllBank(
      {required this.allid, required this.allname, required this.allstatus});
}

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  //para mandar los textbox
  TextEditingController namecontroller = TextEditingController();

  String _selectedStatus = 'ACTIVE'; // Valor inicial por defecto
  String idedit = '';
  String idcontroller = '';
  String idbankcontroller = '';
  String statuscontroller = '';

  late List<Bank> _banks = <Bank>[]; // Lista para almacenar los bancos
  late Bank _selectedBank; // Bank seleccionado

  late List<AllBank> _allbanks = <AllBank>[]; // Lista para almacenar los bancos
  // ignore: unused_field
  late AllBank _selectedallBank; // Bank seleccionado

  //para traer la data
  // ignore: non_constant_identifier_names
  Stream? AccountsStream;

  getontheload() async {
    AccountsStream = await DatabaseMethods().getAccountDetails();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();

    //load
    _selectedStatus = 'ACTIVE';
    statuscontroller = '1';

    _selectedBank = Bank(
        id: '0', name: 'BANKS', status: '0'); // Valor inicial predeterminado
    fetchBanksData();

    _selectedallBank = AllBank(
        allid: '0',
        allname: 'BANKS',
        allstatus: '0'); // Valor inicial predeterminado
    fetchallBanksData();

    //cargar next id
    getNextId().then((maxId) {
      // Establece el valor del TextEditingController con el próximo ID
      idcontroller = maxId.toString();
    });
  }

//para traer la data
  Widget allaccountsDetails() {
    return StreamBuilder(
      stream: AccountsStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return Column(
                children: [
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(3),
                    borderOnForeground: true,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: InkWell(
                      onTap: () {
                        // Establecer los valores en los controladores de texto cuando se haga clic
                        idcontroller = ds["idaccount"].toString();
                        idedit = ds["idaccount"].toString();
                        namecontroller.text = ds["nameaccount"];

                        // Recargar los datos de los bancos y actualizar el banco seleccionado
                        fetchBanksData().then((_) {
                          setState(() {
                            _selectedStatus =
                                ds["status"] == '1' ? 'ACTIVE' : 'DISABLE';
                            statuscontroller = ds["status"].toString();

                            // Obtener el ID del banco como cadena
                            var idBank = ds["idbank"].toString();
                            idbankcontroller = idBank;

                            // Buscar el banco en la lista _banks
                            var matchingBank = _banks
                                .firstWhereOrNull((bank) => bank.id == idBank);

                            // Establecer el banco seleccionado
                            _selectedBank = matchingBank ??
                                Bank(id: '0', name: 'BANKS', status: '0');
                          });
                        });
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
                                      fontSize: 2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ds["idaccount"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Color.fromARGB(255, 92, 90, 90),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    ds["nameaccount"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Color.fromARGB(255, 92, 90, 90),
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Truncar el texto si es demasiado largo
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  ds["status"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Color.fromARGB(255, 92, 90, 90),
                                  ),
                                ),
                                const SizedBox(width: 50),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Delete!"),
                                          content: const Text(
                                              "Are you sure to delete this account?"),
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
                                                    .deleteAccountDetails(
                                                        ds["idaccount"]
                                                            .toString());
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context)
                                                    .pop(); // Cierra el cuadro de diálogo
                                                //idcontroller.text = '';

                                                namecontroller.text = '';
                                                toastification.show(
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  title: const Text(
                                                      "Accounts has been deleted successfully"),
                                                  autoCloseDuration:
                                                      const Duration(
                                                          seconds: 3),
                                                  style:
                                                      ToastificationStyle.flat,
                                                  type:
                                                      ToastificationType.error,
                                                );
                                                //cargar next id
                                                getNextId().then((maxId) {
                                                  // Establece el valor del TextEditingController con el próximo ID
                                                  idcontroller =
                                                      maxId.toString();
                                                });

                                                fetchBanksData();
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
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
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

                                          // Buscar el banco en la lista _banks
                                          var matchingallBank = _allbanks
                                              .firstWhereOrNull((allbank) =>
                                                  allbank.allid == allidBank);

                                          // Si se encontró un banco correspondiente, devuelve su nombre; de lo contrario, devuelve una cadena predeterminada
                                          return matchingallBank != null
                                              ? matchingallBank.allname
                                              : 'UNKNOWN';
                                        })(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12.0,
                                          color:
                                              Color.fromARGB(255, 92, 90, 90),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        ds["status"] == "1"
                                            ? "ACTIVE"
                                            : "DISABLED",
                                        style: TextStyle(
                                          color: ds["status"] == "1"
                                              ? const Color.fromARGB(
                                                  255, 55, 196, 60)
                                              : const Color.fromARGB(
                                                  255, 238, 56, 43),
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                  const Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "",
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 2.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
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
              "    Accounts",
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
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: DropdownButton<Bank>(
                value: _selectedBank,
                onChanged: (Bank? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBank = newValue;
                      idbankcontroller = newValue.id;
                    });
                    //if (idedit == '') {
                    //  fetchBanksData();
                    //} else {
                    //  fetchallBanksData();
                    //}
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
                        bank.name,
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
                controller: namecontroller,
                decoration: const InputDecoration(
                    //border: InputBorder.none,
                    hintText: "Accounts Name"),
                style: const TextStyle(fontSize: 14.0),
              ),
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
                value: _selectedStatus,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                      statuscontroller = newValue == 'ACTIVE' ? '1' : '0';
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
                items: <String>['ACTIVE', 'DISABLE']
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
                      int idaccount = int.parse(idcontroller);
                      int idbank = int.parse(idbankcontroller);
                      //String codeId = randomAlphaNumeric(10);
                      Map<String, dynamic> insertAccountInfoMap = {
                        "idaccount": idaccount, //idcontroller.text,
                        "idbank": idbank,
                        "nameaccount": namecontroller.text,
                        "status": statuscontroller
                        //"Id": codeId,
                      };
                      await DatabaseMethods()
                          .addAccountDetails(
                              insertAccountInfoMap, idaccount.toString())
                          .then((value) {
                        // Si la operación se completó correctamente
                        idcontroller = '';
                        idbankcontroller = '';
                        namecontroller.text = '';
                        statuscontroller = '';
                        toastification.show(
                          // context: context, // optional if you use ToastificationWrapper
                          title: const Text(
                              'Registration Accounts has been successful!'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.success,
                        );
                      }).catchError((error) {
                        // Si ocurrió un error
                        toastification.show(
                          // context: context, // optional if you use ToastificationWrapper
                          title: const Text('An error occurred'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.error,
                        );
                      });

                      //cargar next id
                      getNextId().then((maxId) {
                        // Establece el valor del TextEditingController con el próximo ID
                        idcontroller = maxId.toString();
                      });
                      idedit = '';
                      fetchBanksData();
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
                      int idaccount = int.parse(idcontroller);
                      int idbank = int.parse(idbankcontroller);
                      //String codeId = randomAlphaNumeric(10);
                      Map<String, dynamic> updateAccountInfoMap = {
                        "idaccount": idaccount,
                        "idbank": idbank,
                        "nameaccount": namecontroller.text,
                        "status": statuscontroller
                        //"Id": codeId,
                      };
                      await DatabaseMethods()
                          .updateAccountDetails(
                              updateAccountInfoMap, idaccount.toString())
                          .then((value) {
                        // Si la operación se completó correctamente
                        idcontroller = '';
                        idbankcontroller = '';
                        namecontroller.text = '';
                        statuscontroller = '';
                        toastification.show(
                         // context: context, // optional if you use ToastificationWrapper
                          title:
                              const Text('Update account has been successful!'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.info,
                        );
                      }).catchError((error) {
                        // Si ocurrió un error
                        toastification.show(
                          // context: context, // optional if you use ToastificationWrapper
                          title: const Text('An error occurred'),
                          autoCloseDuration: const Duration(seconds: 3),
                          style: ToastificationStyle.flat,
                          type: ToastificationType.error,
                        );
                      });

                      getNextId();
                      idedit = '';
                      fetchBanksData();
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

            //  Container(
            //  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            // decoration: BoxDecoration(
            //  border: Border.all(
            //    color: const Color.fromARGB(255, 201, 198, 198),
            //  ),
            //  borderRadius: BorderRadius.circular(3),
            // ),
            //child: const Row(
            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // children: [
            //  SizedBox(width: 20),
            // Text(
            //    "ID",
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 14.0,
            //      color: Color.fromARGB(255, 92, 90, 90),
            //    ),
            //   ),
            //   SizedBox(width: 10),
            //  Expanded(
            //    child: Text(
            //     'Accounts Name',
            //    style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //      fontSize: 14.0,
            //      color: Color.fromARGB(255, 92, 90, 90),
            //    ), // Truncar el texto si es demasiado largo
            //    ),
            //  ),
            //   SizedBox(width: 10),
            //   Text(
            //    "Status",
            //    style: TextStyle(
            //    fontWeight: FontWeight.bold,
            //    fontSize: 14.0,
            //   color: Color.fromARGB(255, 92, 90, 90),
            //   ),
            //    ),
            //    SizedBox(width: 20),
            //   Text(
            //"Delete",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //      fontSize: 14.0,
            //       color: Color.fromARGB(255, 92, 90, 90),
            //     ),
            //    ),
            //    SizedBox(width: 15),
            //   ],
            //  ),
            //),

            Expanded(child: allaccountsDetails()),
          ],
        ),
      ),
    );
  }

  Future<int> getNextId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Accounts").get();
    int maxId = 0;
    for (var doc in querySnapshot.docs) {
      int id = doc["idaccount"] as int;
      if (id > maxId) {
        maxId = id;
      }
    }
    return maxId + 1;
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
          banksList.add(
              Bank(id: doc.id, name: doc['namebank'], status: doc['status']));
        }
      }
    } else {
      for (var doc in querySnapshot.docs) {
        banksList.add(
            Bank(id: doc.id, name: doc['namebank'], status: doc['status']));
      }
    }
    setState(() {
      _banks = banksList;
      if (_banks.isNotEmpty) {
        _selectedBank = _banks[0];
        if (idedit == '') {
          idbankcontroller = _banks[0].id.toString();
        }
      } else {
        _selectedBank = Bank(id: '0', name: 'BANKS', status: '0');
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
          allid: doc.id, allname: doc['namebank'], allstatus: doc['status']));
    }

    setState(() {
      _allbanks = allbanksList;
      if (_allbanks.isNotEmpty) {
        _selectedallBank = _allbanks[0];

        //idbankcontroller = _allbanks[0].allid.toString();
      } else {
        _selectedallBank =
            AllBank(allid: '0', allname: 'BANKS', allstatus: '0');
      }
    });
  }
}
