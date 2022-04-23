import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_2/modelos/conversa.dart';
import 'package:whatsapp_2/modelos/mensagem.dart';
import 'package:whatsapp_2/modelos/usuario.dart';
import 'package:whatsapp_2/provider/conversa_provider.dart';
import 'package:whatsapp_2/uteis/paleta_cores.dart';

import 'package:provider/provider.dart';

class ListaMensagens extends StatefulWidget {

  final Usuario usuarioRemetente;
  final Usuario usuarioDestinatario;

  const ListaMensagens({
    Key? key,
    required this.usuarioRemetente,
    required this.usuarioDestinatario
  }) : super(key: key);

  @override
  State<ListaMensagens> createState() => _ListaMensagensState();
}

class _ListaMensagensState extends State<ListaMensagens> {

  TextEditingController _controllerMensagem = TextEditingController();
  ScrollController _scrollController = ScrollController();

  late Usuario _usuarioRemetente;
  late Usuario _usuarioDestinatario;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamController _streamController = StreamController<QuerySnapshot>
    .broadcast();
  late StreamSubscription _streamMensages;

  _enviarMensagens(){
    String textoMensagem = _controllerMensagem.text;
    
    String idUsuarioRemetente = _usuarioRemetente.idUsuario;
    if(textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem(
          idUsuarioRemetente,
          textoMensagem,
          Timestamp.now().toString());

      String idUsuarioDestinatario = _usuarioDestinatario.idUsuario;
      // salvando mensagem remetente
      _salvarMensagem(idUsuarioRemetente, idUsuarioDestinatario, mensagem);

      Conversa conversaRemetente = Conversa(
          _usuarioRemetente.idUsuario,
          _usuarioDestinatario.idUsuario,
          mensagem.texto,
          _usuarioDestinatario.nome,
          _usuarioDestinatario.email,
          _usuarioDestinatario.urlImagem
      );
      _salvarConversa(conversaRemetente);

      // salvar mensagem para destinatário
      _salvarMensagem(idUsuarioDestinatario, idUsuarioRemetente, mensagem);

      Conversa conversaDestinatario = Conversa(
          _usuarioDestinatario.idUsuario,
          _usuarioRemetente.idUsuario,
          mensagem.texto,
          _usuarioRemetente.nome,
          _usuarioRemetente.email,
          _usuarioRemetente.urlImagem
      );

      _salvarConversa(conversaDestinatario);

    }
  }

  _salvarMensagem(String idRemetente, String idDestintario, Mensagem mensagem){
    _firestore.collection("mensagens")
        .doc(idRemetente)
        .collection(idDestintario)
        .add(mensagem.toMap());

    _controllerMensagem.clear();
  }


  _salvarConversa(Conversa conversa){
    _firestore.collection("conversas")
        .doc(conversa.idRemetente)
        .collection("ultimas_mensagens")
        .doc(conversa.idDestinatario)
        .set(conversa.toMap());
}

  _recuperarDadosIniciais(){
    _usuarioRemetente = widget.usuarioRemetente;
    _usuarioDestinatario = widget.usuarioDestinatario;

    _adicionarListenerMensagens();
  }

  _atualizarListenerMensagens(){
    Usuario? usuarioDestinatario = context
        .watch<ConversProvider>().usuarioDestinatio;

    if(_usuarioDestinatario != null) {
      _usuarioDestinatario = _usuarioDestinatario;
      _recuperarDadosIniciais();
    }
  }

  _adicionarListenerMensagens(){
    final stream = _firestore.collection("mensagens")
        .doc(_usuarioRemetente.idUsuario)
        .collection(_usuarioDestinatario.idUsuario)
        .orderBy("data", descending: false)
        .snapshots();

    _streamMensages = stream.listen((event) {
      _streamController.add(event);
      Timer(
          Duration(seconds: 1),
              () {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamMensages.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosIniciais();
  }

  @override
  void didChangeDependencies() {
    _atualizarListenerMensagens();
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("imagens/bg.png"),
          fit: BoxFit.cover
        )
      ),
      child: Column(
        children: [
          StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                switch(snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text("Carregando contatos"),
                              CircularProgressIndicator()
                            ],
                          ),
                        )
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if(snapshot.hasError) {
                      return Center(
                        child: Text("Erro ao carregar os dados!"),
                      );
                    } else {
                      QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                      List<DocumentSnapshot> listaMensagens = querySnapshot.docs.toList();

                      return Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (context, indice) {
                                DocumentSnapshot item = listaMensagens[indice];

                                Alignment alinhamento = Alignment.bottomLeft;
                                Color cor = Colors.white;

                                if(_usuarioRemetente.idUsuario == item["idUsuario"]) {
                                  alinhamento = Alignment.bottomRight;
                                  cor = Color(0xffd2ffa5);
                                }
                                Size largura = MediaQuery.of(context).size * 0.8;
                                return Align(
                                  alignment: alinhamento,
                                  child: Container(
                                    constraints: BoxConstraints.loose(largura),
                                    decoration: BoxDecoration(
                                      color: cor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8)
                                      )
                                    ),
                                    padding: EdgeInsets.all(16),
                                    margin: EdgeInsets.all(6),
                                    child: Text(item["texto"]),
                                  ),
                                );
                              }
                          )
                      );
                    }
                }
              }
          ),

          Container(
            padding: EdgeInsets.all(8),
            color: PaletaCores.corFundoBarra,
            child: Row(
              children: [
                Expanded(child:
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_emoticon),
                        SizedBox(width: 4,),
                        Expanded(
                            child: TextField(
                              controller: _controllerMensagem,
                              decoration: InputDecoration(
                                hintText: "Digite uma mensagem",
                                border: InputBorder.none
                              ),
                            )
                        ),
                        Icon(Icons.attach_file),
                        Icon(Icons.camera_alt)
                      ],
                    ),
                  )
                ),

                FloatingActionButton(
                  backgroundColor: PaletaCores.corPrimaria,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: (){
                    _enviarMensagens();
                  },
                  mini: true,

                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
