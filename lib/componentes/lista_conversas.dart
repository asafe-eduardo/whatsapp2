import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_2/modelos/conversa.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_2/provider/conversa_provider.dart';

import '../modelos/usuario.dart';
import '../uteis/responsivo.dart';

class ListaConversas extends StatefulWidget {
  const ListaConversas({Key? key}) : super(key: key);

  @override
  State<ListaConversas> createState() => _ListaConversasState();
}

class _ListaConversasState extends State<ListaConversas> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  late Usuario _usuarioRemetente;
  StreamController _streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamConversas;

  _adicionarListenerConversas(){
    final stream = _firestore
        .collection("conversas")
        .doc(_usuarioRemetente.idUsuario)
        .collection("ultimas_mensagens")
        .snapshots();

    _streamConversas = stream.listen((event) {
      _streamController.add(event);
    });
  }

  _recuperarDadosIniciais(){
    User? usuarioLogado = _auth.currentUser;
    if(usuarioLogado != null) {
      String idUsuario = usuarioLogado.uid;
      String? nome = usuarioLogado.displayName ?? "";
      String? email = usuarioLogado.email ?? "";
      String? urlImagem = usuarioLogado.photoURL ?? "";

      _usuarioRemetente = Usuario(
          idUsuario,
          nome,
          email,
          urlImagem: urlImagem
      );
    }

    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    _streamConversas.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {

    final bool isMobile = Responsivo.isMobile(context);

    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Column(
                children: [
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar os dados!"),
                );             }
              else {

                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                List<DocumentSnapshot> listaConversas = querySnapshot.docs.toList();

                return ListView.separated(
                    separatorBuilder: (context, indice){
                      return Divider(
                        color: Colors.grey,
                        thickness: 0.2,
                      );
                    },
                    itemCount: listaConversas.length,
                    itemBuilder: (context, indice){
                      DocumentSnapshot conversa = listaConversas[indice];

                      String emailDestinatario = conversa["emailDestinatario"];
                      String idDestinatario = conversa["idDestintario"];
                      String urlImagemDestinatario = conversa["urlImagemDestinatario"];
                      String nomeDestinatario = conversa["nomeDestinatario"];
                      String ultimaMensagem = conversa["ultimaMensagem"];

                      Usuario usuario = Usuario(
                          idDestinatario,
                          nomeDestinatario,
                          emailDestinatario,
                          urlImagem: urlImagemDestinatario
                      );

                      return ListTile(
                        onTap: (){
                          if(isMobile){
                            Navigator.pushReplacementNamed(context, "/mensagens", arguments: usuario);
                          } else {
                            context.read<ConversProvider>().usuarioDestinatio = usuario;
                          }
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(
                              usuario.urlImagem
                          ),
                        ),
                        title: Text(
                          usuario.nome,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        subtitle: Text(
                          ultimaMensagem,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        contentPadding: EdgeInsets.all(8),
                      );
                    }
                );
              }
          }
        }
    );
  }
}
