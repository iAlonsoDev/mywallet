import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mywallet/service/database.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:random_string/random_string.dart';
import 'package:toastification/toastification.dart';

class Banks extends StatefulWidget {
  const Banks({super.key});

  @override
  State<Banks> createState() => _BanksState();
}

class _BanksState extends State<Banks> {
  //para mandar los textbox
  TextEditingController namecontroller = TextEditingController();

  String _selectedStatus = 'ACTIVE'; // Valor inicial por defecto
  String idcontroller = '';
  String statuscontroller = '';

  //para traer la data
  // ignore: non_constant_identifier_names
  Stream? BanksStream;

  getontheload() async {
    BanksStream = await DatabaseMethods().getBankDetails();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();

    //load
    _selectedStatus = 'ACTIVE';
    statuscontroller = '1';

    //cargar next id
    getNextId().then((maxId) {
      // Establece el valor del TextEditingController con el próximo ID
      idcontroller = maxId.toString();
    });
  }

//para traer la data
  Widget allBanksDetails() {
    return StreamBuilder(
      stream: BanksStream,
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
                        idcontroller = ds["idbank"].toString();
                        namecontroller.text = ds["namebank"];
                        statuscontroller = ds["status"].toString();
                        setState(() {
                          _selectedStatus = ds["status"] == '1'
                              ? 'ACTIVE'
                              : 'DISABLE'; // Actualizar el valor seleccionado del DropdownButton
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30.0),
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ds["idbank"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Color.fromARGB(255, 92, 90, 90),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    ds["namebank"],
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
                                  // ignore: prefer_interpolation_to_compose_strings
                                  ds["status"],
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 92, 90, 90),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 75),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Delete!"),
                                          content: const Text(
                                              "Are you sure to delete this bank?"),
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
                                                    .deleteBankDetails(
                                                        ds["idbank"]
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
                                                      "Bank has been deleted successfully"),
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
                                Text(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  (ds["status"] == "1" ? "ACTIVE" : "DISABLED"),
                                  style: TextStyle(
                                    color: ds["status"] == "1"
                                        ? const Color.fromARGB(255, 55, 196, 60)
                                        : const Color.fromARGB(
                                            255, 238, 56, 43),
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(width: 50),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  "",
                                  style: TextStyle(
                                    fontSize: 2,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(width: 50),
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
              "    Banks",
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
                    hintText: "Bank Name"),
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
                      int idbank = int.parse(idcontroller);
                      //String codeId = randomAlphaNumeric(10);
                      Map<String, dynamic> insertBankInfoMap = {
                        "idbank": idbank, //idcontroller.text,
                        "namebank": namecontroller.text,
                        "status": statuscontroller,
                        //"Id": codeId,
                      };
                      await DatabaseMethods()
                          .addBankDetails(insertBankInfoMap, idbank.toString())
                          .then((value) {
                        // Si la operación se completó correctamente
                        idcontroller = '';
                        namecontroller.text = '';
                        statuscontroller = '';
                        toastification.show(
                          // context: context, // optional if you use ToastificationWrapper
                          title: const Text(
                              'Registration bank has been successful!'),
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
                      int idbank = int.parse(idcontroller);
                      //String codeId = randomAlphaNumeric(10);
                      Map<String, dynamic> updateBankInfoMap = {
                        "idbank": idbank,
                        "namebank": namecontroller.text,
                        "status": statuscontroller,
                        //"Id": codeId,
                      };
                      await DatabaseMethods()
                          .updateBankDetails(
                              updateBankInfoMap, idbank.toString())
                          .then((value) {
                        // Si la operación se completó correctamente
                        idcontroller = '';
                        namecontroller.text = '';
                        statuscontroller = '';
                        toastification.show(
                          // context: context, // optional if you use ToastificationWrapper
                          title: const Text('Update bank has been successful!'),
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

                      getNextId().then((maxId) {
                        // Establece el valor del TextEditingController con el próximo ID
                        idcontroller = maxId.toString();
                      });
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

            // Container(
            //  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            //  decoration: BoxDecoration(
            //    border: Border.all(
            //      color: const Color.fromARGB(255, 201, 198, 198),
            //    ),
            //   borderRadius: BorderRadius.circular(3),
            // ),
            // child: const Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //    children: [
            //     SizedBox(width: 20),
            //     Text(
            //       "ID",
            //       style: TextStyle(
            //        fontWeight: FontWeight.bold,
            //        fontSize: 14.0,
            //        color: Color.fromARGB(255, 92, 90, 90),
            //      ),
            //   ),
            //     SizedBox(width: 10),
            //   Expanded(
            //     child: Text(
            //        'Bank Name',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 14.0,
            //          color: Color.fromARGB(255, 92, 90, 90),
            //       ), // Truncar el texto si es demasiado largo
            //     ),
            //   ),
            //   SizedBox(width: 10),
            //   Text(
            //     "Status",
            //     style: TextStyle(
            //      fontWeight: FontWeight.bold,
            //      fontSize: 14.0,
            //       color: Color.fromARGB(255, 92, 90, 90),
            //     ),
            //   ),
            //   SizedBox(width: 50),
            //   Text(
            //     "Delete",
            //    style: TextStyle(
            //      fontWeight: FontWeight.bold,
            //      fontSize: 14.0,
            //      color: Color.fromARGB(255, 92, 90, 90),
            //      ),
            //   ),
            //    SizedBox(width: 15),
            //   ],
            //  ),
            // ),

            Expanded(child: allBanksDetails()),
          ],
        ),
      ),
    );
  }

  Future<int> getNextId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Banks").get();
    int maxId = 0;
    for (var doc in querySnapshot.docs) {
      int id = doc["idbank"] as int;
      if (id > maxId) {
        maxId = id;
      }
    }
    return maxId + 1;
  }
}
