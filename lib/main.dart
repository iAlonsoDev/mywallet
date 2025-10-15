import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mywallet/firebase_options.dart';
import 'package:mywallet/pages/home.dart'; // Asegúrate de importar tu página Home aquí

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyWallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}
