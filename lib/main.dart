import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_2/provider/conversa_provider.dart';
import 'package:whatsapp_2/rotas.dart';
import 'package:whatsapp_2/telas/login.dart';
import 'package:whatsapp_2/uteis/paleta_cores.dart';
import 'package:provider/provider.dart';

final ThemeData temaPadrao = ThemeData(
  colorScheme: ColorScheme.light().copyWith(
    primary: PaletaCores.corPrimaria,
    secondary: PaletaCores.corDestaque
  ),
  primaryColor: PaletaCores.corPrimaria,
  accentColor: PaletaCores.corDestaque
);

void main() async {

  // final atalhos = WidgetsApp.defaultShortcuts;
  // atalhos[LogicalKeySet(LogicalKeyboardKey.space)] = ActivateIntent();

  runApp(ChangeNotifierProvider(
    create: (context) => ConversProvider(),
    child: MaterialApp(
      // shortcuts: atalhos,
      title: "Whatsapp Web",
      // home: Login(),
      theme: temaPadrao,
      initialRoute: "/",
      onGenerateRoute: Rotas.gerarRota,
      debugShowCheckedModeBanner: false,
    ),
  ));
}
