import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5 ),
    // Band(id: '2', name: 'Queen', votes: 1 ),
    // Band(id: '3', name: 'Héroes del Silencio', votes: 2 ),
    // Band(id: '4', name: 'Bon Jovi', votes: 5 ),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen:false);
    socketService.socket.on('active-bands', _handleActiveBands);     

    
    super.initState();
  }

//-------------_handleActiveBands-----------------------------
  _handleActiveBands( dynamic payload){
    this.bands = (payload as List)
        .map((band) => Band.fromMap(
            band)) //este es mi factory constructor esto ha creado un iterable
        .toList(); //lo pasamos a lista
    setState(() {}); //actualizamos nuestra pantalla
  }
//-------------------------------------------------------------

  @override
  void dispose() {
     final socketService = Provider.of<SocketService>(context, listen:false);
    socketService.socket.off('active-bands');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle( color: Colors.black87 ) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus==ServerStatus.Online ?
            Icon(Icons.check_circle, color: Colors.blue[300]):
            Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            //flex: 2,
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTile( bands[i] )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon( Icons.add ),       
        elevation: 1,        
      ),
   );
  }

  Widget _bandTile( Band band ) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle( color: Colors.white) ),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2) ),
          backgroundColor: Colors.blue[100],
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20) ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
          //print(band.name);
        },
      ),
    );
  }

  addNewBand() {

    final textController = new TextEditingController();    
    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
        context: context,
        builder: ( context )=> AlertDialog(
            title: Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text )
              )
            ],
          )        
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList( textController.text )
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );

  }  

  void addBandToList( String name ) {
  
    if ( name.length > 1 ) {
      // Podemos agregar
      // this.bands.add( new Band(id: DateTime.now().toString(), name: name, votes: 0 ) );
      // setState(() {});
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }


  
  Widget _showGraph(){
    Map<String, double> dataMap = new Map();
    //"Flutter": 5,
    bands.forEach((ban){
      dataMap.putIfAbsent(ban.name, () => ban.votes.toDouble());
    });    
    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];
    if (dataMap.isEmpty){
      return SizedBox(
        width: double.infinity,
        height: 300,
      ); 
    }else{
    return Container(
      width: double.infinity,
      height: 300,
      child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 20,
          //centerText: "HYBRID",
          legendOptions: LegendOptions(
            //showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            //legendShape: _BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            //showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        )
    ); 

    } //else

  }

 

}