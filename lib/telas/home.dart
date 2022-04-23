import 'package:flutter/material.dart';
import 'package:whatsapp_2/telas/home_mobile.dart';
import 'package:whatsapp_2/telas/home_web.dart';
import 'package:whatsapp_2/uteis/responsivo.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsivo(
      mobile: HomeMobile(),
      tablet: HomeWeb(),
      web: HomeWeb(),
    );
  }
}
