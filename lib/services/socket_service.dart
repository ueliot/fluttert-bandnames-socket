import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService  with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;   //asigno _socket a esta etiqueta 
  IO.Socket get socket => this._socket;  //getter para _socket
  ServerStatus get serverStatus => this._serverStatus; 
  //serverStatus tambien está expuesto a fuera de la clase con su getter serverStatus
  
  SocketService(){    //constructor que llama al metodo _initConfig - void)
    this._initConfig();
  }
  void _initConfig(){
     
    this._socket = IO.io('http://192.168.1.34:3000', {    // creo el objeto _socket Ip del server  
      'transports' : ['websocket'],
      'autoconnect' : true,
    });

    this._socket.onConnect((_) {    //objeto llamando al metodo onConnect
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();    
    });

    this._socket.onDisconnect((_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
     });

    //esto lo debo usar desde fuera de la clase pero para probar la comunicacion es ok
    // this._socket.on('nuevo-mensaje', (payload){  //
    //     print('nuevo-mensaje: $payload');
    //     print("Nombre: "+ payload['nombre']);
    //     print("MSJ: " + payload['mensaje']);
    //     //print("MSJ2: " + payload['mensaje2']);    //si llega otra key? que se hace
    //     print(payload.containsKey('mensaje2') ? payload['mensaje2']: 'no hay mensaje2');
    //   });


    //si ya no quisiera seguir escuchando ese tag 'nuevo-mensaje' usamos:
    //socket.off('nuevo-mensaje');


  }
}