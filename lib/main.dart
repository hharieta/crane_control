import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget{
  const MiApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Grúa Arduino Conection",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Inicio(title: 'Control Grúa'),
    );  // MaterialApp
  }
}

class Inicio extends StatefulWidget{
  const Inicio({super.key, required this.title});
  final String title;

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio>{
  // init bluetooth state is unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // get the instance of the bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // track the bluetooth connection with the remote device
  // nullable variable
  BluetoothConnection? connection;
  // to track whether the device is still connected
  // assertion operator ! for use the nullable expression as a condition
  bool get isConnected => connection != null && connection!.isConnected;

  // tracking the Bluetooth device connection state
  late int _deviceState;
  // some variables
  List<BluetoothDevice> _devicesList = [];
  late BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  bool isDisconnecting = false;

  @override
  void initState(){
    super.initState();

    // get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0;
    enableBluetooth();

    // listen for further state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        // for retrieving the paired devices list
        getPairedDevices();

      });
    });

    /* end initState */
  }

  @override
  void dispose() {
    // avoid memory leak and disconnect
    if (isConnected){
      isDisconnecting = true;
      connection?.dispose();
      connection = null;  // BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
    }

    super.dispose();
  }

  // request bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    // Retrieve the current state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }

    return false;
  }

  // force retrieveing and storing the paired devices
  Future<void> getPairedDevices() async {
    List<BluetoothState> devices = [];

    // get the list of paired devices
    try {
      devices = (await _bluetooth.getBondedDevices()).cast<BluetoothState>();
    } on PlatformException {
      print("Error");
    }

    // error to call setState unless mounted is true
    if (!mounted){
      return;
    }

    setState(() {
      _devicesList = devices.cast<BluetoothDevice>();
    });

  }

  @override
  Widget build(BuildContext context){
    _InicioState con = _InicioState();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          TextButton.icon(onPressed: () async {
            await getPairedDevices().then((_) => {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text("Bluetooth List"),
                content: const Text("Devices list refreshed"),
                actions: <Widget>[
                  TextButton(onPressed: (){
                    Navigator.of(ctx).pop();
                  }, child: const Text("OK"),
                  ),
                ],
              ))
            });
          },
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Cuerpo()
    );
  }

  Widget Cuerpo(){
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(image: NetworkImage("https://preview.redd.it/q258o72ldq461.png?auto=webp&s=379018fc1ac6e77b566316bdce50d7bde723df1f"),
              fit: BoxFit.cover
          )
      ),
      child: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: SwitchRow(),
            ),
            Container(
              height: 220,
              padding: const EdgeInsets.all(10.0),
              color: Colors.black,
              child: CountOut(),
            ),
            Container(
              //alignment: Alignment.bottomCenter,
              //height: 150,
              //color: Colors.blueAccent,
              child: CraneButtons(),
            )
          ],
        ),
      ),
    );
  }

  Widget SwitchRow(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Visibility(
            visible: _isButtonUnavailable && _bluetoothState == BluetoothState.STATE_BLE_ON,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.green,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:  <Widget>[
              const Expanded(
                child: Text('Enable Bluetooth',
                style: TextStyle(color: Colors.black,
                fontSize: 16,
                ),
              ),
              ),
              Switch(
                  value: _bluetoothState.isEnabled,
                  onChanged: (bool value){
                    future() async {
                      if (value){
                        // enable button
                        await FlutterBluetoothSerial.instance.requestEnable();
                      } else {
                        // disable button
                        await FlutterBluetoothSerial.instance.requestDisable();
                      }

                      // update the devices list
                      await getPairedDevices();
                      _isButtonUnavailable = false;

                      if(_connected){
                        //_disconnect(); ////CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
                      }
                    }

                    future().then((_) => {
                      setState((){})
                    });
                  })
            ],
          ),
        ),
      ],
    );
  }

  Widget dropDown(){
    return Stack(

    );
  }

  Widget CountOut(){
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: const <Widget>[
        Text(
           'Bluetooth@Crane > _contador', style: TextStyle(color: Colors.green, fontFamily: 'Inconsolata' , fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        )
      ],
    );
  }

  Widget CraneButtons(){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ElevatedButton(onPressed: ()=>{
            print("UP"),
            //_incrementarContador()
          }, child: const Icon(Icons.arrow_circle_up)),
          ElevatedButton(onPressed: ()=>{
            print("DOWN"),
            //_decrementarContador()
          }, child: const Icon(Icons.arrow_circle_down)),
          ElevatedButton(onPressed: ()=>{
            print("RESET"),
            //_reiniciarContador()
          }, child: const Icon(Icons.restart_alt_rounded))
        ]
    );
  }

  /*end Class _InicioState*/
}