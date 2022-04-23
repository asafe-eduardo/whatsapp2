import 'package:flutter/cupertino.dart';
import 'package:whatsapp_2/modelos/usuario.dart';

class ConversProvider with ChangeNotifier {
    Usuario? _usuarioDestinatio;

    Usuario? get usuarioDestinatio => _usuarioDestinatio;

    set usuarioDestinatio(Usuario? value) {
      _usuarioDestinatio = value;
      notifyListeners();
    }
}