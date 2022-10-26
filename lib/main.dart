import 'package:flutter/foundation.dart';
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
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  bool isDisconnecting = false;

  // gradient color
  final Shader linearGradient = const LinearGradient(
    begin: Alignment.topRight, end: Alignment.bottomLeft,
      colors: <Color>[
        Colors.red, Colors.orange, Colors.orangeAccent, Colors.greenAccent,
        Colors.green, Colors.lightBlueAccent, Colors.indigoAccent,
        Colors.indigo, Colors.purple
      ],
  ).createShader(
      const Rect.fromLTWH(0.0, 0.0, 100.0, 70.0)
  );

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
      connection = null;
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
    List<BluetoothDevice> devices = [];

    // get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      show("@Error. No bluetooth devices");
    }

    // error to call setState unless mounted is true
    if (!mounted){
      return;
    }

    setState(() {
      _devicesList = devices;
    });

  }

  @override
  Widget build(BuildContext context){
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Refresh', style:
            TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
            ),
          ),
        ],
      ),
      body: body4Scaffold()
    );
  }

  Widget body4Scaffold(){
    return Container(
      decoration: const BoxDecoration(
          /*gradient: LinearGradient(
            begin: Alignment.bottomLeft, end: Alignment.topRight,
            colors: <Color>[
              Colors.blue, Colors.lightBlueAccent
            ],
          ),*/
        image: DecorationImage(image: AssetImage("assets/images/w1.png"))
      ),
      child: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: switchEnableDisable(),
            ),
            Container(
              child: stackDevicesShow(),
            ),
            /*Container(
              height: 220,
              padding: const EdgeInsets.all(10.0),
              color: Colors.black,
              child: CountOut(),
            ),*/
            Container(
              //alignment: Alignment.bottomCenter,
              //height: 150,
              //color: Colors.blueAccent,
              child: CraneButtons(),
            ),
            Container(
              child: openSettings(),
            )
          ],
        ),
      ),
    );
  }

  Widget switchEnableDisable(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Visibility(
            visible: _isButtonUnavailable && _bluetoothState == BluetoothState.STATE_BLE_ON,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            )),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:  <Widget>[
              const Expanded(
                child: Text('Enable Bluetooth',
                style: TextStyle(color: Colors.black,
                fontSize: 16, fontWeight: FontWeight.bold
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
                        _disconnect();
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

  Widget stackDevicesShow(){
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            const Text('PAIRED DEVICES',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: Colors.black,
                  //foreground: Paint() ..shader = linearGradient
              ),
              textAlign: TextAlign.justify,
            ),
            Padding(padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Device',
                    style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  DropdownButton(items: _getDeviceItems(),
                      onChanged: (value) => setState(() => _device = value),
                    value: _devicesList.isNotEmpty ? _device : null,
                  ),
                  ElevatedButton(onPressed: _isButtonUnavailable ? null
                      : _connected ? _disconnect : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect'),
                  )
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _deviceState == 0 ? Colors.red : _deviceState == 1
                        ? Colors.orangeAccent : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                elevation: _deviceState == 0 ? 4: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text("DEVICE 1", style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500, color: _deviceState == 0 ? Colors.blueGrey :
                          _deviceState == 1 ? Colors.orangeAccent : Colors.black
                      ),))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget openSettings(){
    return Padding(padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton.icon(onPressed: () {
              FlutterBluetoothSerial.instance.openSettings();
              },
              icon: const Icon(Icons.warning_rounded, color: Colors.blueGrey),
              label: const Text('Bluetooth Settings', style:
                TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget CraneButtons(){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ElevatedButton(onPressed: ()=>{
            print("UP"),
          }, child: const Icon(Icons.arrow_circle_up)),
          ElevatedButton(onPressed: ()=>{
            print("DOWN"),
          }, child: const Icon(Icons.arrow_circle_down)),
          ElevatedButton(onPressed: ()=>{
            print("RESET"),
          }, child: const Icon(Icons.restart_alt_rounded))
        ]
    );
  }

  // Method to list devices bluetooth to shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems(){
    List<DropdownMenuItem<BluetoothDevice>> items = [];

    if (_devicesList.isEmpty){
      items.add(const DropdownMenuItem(child: Text('NONE'),
      ));
    } else {
      for (var device in _devicesList) {
        items.add(DropdownMenuItem(value: device,child: Text('$device.name'),
        ));
      }
    }

    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });

    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected){
        await BluetoothConnection.toAddress(_device?.address).then((conn) {
          show('Connected to the device');
          connection = conn;

          setState(() {
            _connected = true;
          });

          connection?.input?.listen(null).onDone(() {
            if (isDisconnecting){
              show('Disconnecting locally!');
            } else {
              show('Disconnectig remotely!');
            }
            if (mounted){
              setState(() {});
            }

          });

        }).catchError((error){
          show('Cannot connect, exception ocurred: $error');
        });

        show('Device connected');

        setState(() {
          _isButtonUnavailable = false;
        });
      }
    }
  }

  // Method to disconnect to bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection?.close();
    show('Device Disconnected');
    // operator ! is a null check target
    if(!connection!.isConnected){
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }


  // Method to show a Snackbar,
  // taking message as the text
  Future show(
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) async {
    //await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: duration,
      ),
    );
  }


  /*end Class _InicioState*/
}