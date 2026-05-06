import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Duki', votes: 1),
    // Band(id: '3', name: 'Natanael Cano', votes: 2),
    // Band(id: '4', name: 'Mac Miller', votes: 4),
  ];

  @override
  void initState() {
    // false -> no necesitamos modificar nada
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  void _handleActiveBands(dynamic payload) {
    //  mapear para tener las propiedades que necesitamos
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    // redibujar el widget completo cuando se reciba un bands
    setState(() {});
  }

  /// para destruir el home. Evitar estar escuchando informacion cuando no lo necesita
  @override
  void dispose() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socket = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 15,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socket.serverStatus == ServerStatus.online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => bandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget bandTile(Band band) {
    //false -> no necesitamos que se redibuje si algo cambia

    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      // key -> Identificador unico
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print(direction);
        print(band.id);
        // emitir -> delete-band
        // {'id': band.id}
        socketService.emit('delete-band', {'id': band.id});
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete band', style: TextStyle(color: Colors.white)),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          // enviar id al backend para incrementar el valor +1
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('new Band name:'),
            content: TextField(controller: textController),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                child: Text('add'),
                // manera condicional
                onPressed: () => addBandToList(textController.text),
              ),
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('new Band name:'),
          content: CupertinoTextField(controller: textController),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String bandName) {
    print(bandName);
    if (bandName.length > 1) {
      // agregar
      // this.bands.add(
      //   Band(id: DateTime.now().toString(), name: bandName, votes: 0),
      // );
      // setState(() {});
      // emitir el evento -> 'add-band'
      // {name:name}
      // provider en false
      // socketService.socket.emit('vote-band', {'id': band.id});
      final socket = Provider.of<SocketService>(context, listen: false);

      socket.emit('add-band', {'name': bandName});

      // setState(() {});
    }
    Navigator.pop(context);
  }
}
