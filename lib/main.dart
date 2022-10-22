import 'package:flutter/material.dart';

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

  int _contador = 0;

  void _incrementarContador(){
    setState(() {
      _contador++;
    });
  }
  void _decrementarContador(){
    setState(() {
      if (_contador > 0) _contador--;
    });
  }
  void _reiniciarContador(){
    setState(() {
      _contador = 0;
    });
  }

  @override
  Widget build(BuildContext context){
    _InicioState con = _InicioState();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(onPressed: (){}, icon: const Icon(Icons.android_rounded))
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


  Widget CountOut(){
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
           'Bluetooth@Crane > $_contador', style: const TextStyle(color: Colors.green, fontFamily: 'Inconsolata' , fontSize: 16, fontWeight: FontWeight.bold),
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
            _incrementarContador()
          }, child: const Icon(Icons.arrow_circle_up)),
          ElevatedButton(onPressed: ()=>{
            print("DOWN"),
            _decrementarContador()
          }, child: const Icon(Icons.arrow_circle_down)),
          ElevatedButton(onPressed: ()=>{
            print("RESET"),
            _reiniciarContador()
          }, child: const Icon(Icons.restart_alt_rounded))
        ]
    );
  }
}