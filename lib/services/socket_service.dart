import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  // cuando tiene que refrescar o redibujar un widget en particular. Notificar a todos los que trabajen con el socketService
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  // Getter de la propiedad serverStatus
  // De esta manera controlamos la manera en como va a cambiar el valor
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => _socket;

  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // conexion
    _socket = IO.io('http://localhost:3000/', {
      // web sockets
      'transports': ['websocket'],
      'autoConnect': true,
    });

    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.online;
      notifyListeners();
    });

    // socket.on('event', (data) => print(data));
    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    // , callback que se a ejecutar cuando recibamos el nuevo mensaje
    // socket.on('nuevo-mensaje', (payload) {
    //   print('Nuevo mensaje');
    //   print('Nombre: ${payload['nombre']}');
    //   print('Mensaje: ${payload['mensaje']}');
    // });
    this._socket.on('emitir-mensaje', (payload) {
      // client.broadcast.emit('nuevo-mensaje', payload);
      _socket.emit('emitir-mensaje', payload);
    });
  }
}
