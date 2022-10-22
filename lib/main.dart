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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(onPressed: (){}, icon: Icon(Icons.android_rounded))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            //width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(0.0),
            child: Image.network("https://preview.redd.it/q258o72ldq461.png?auto=webp&s=379018fc1ac6e77b566316bdce50d7bde723df1f",
              width: MediaQuery.of(context).size.shortestSide,
              height: MediaQuery.of(context).size.shortestSide ,
              fit: BoxFit.fitWidth
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.amber,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$_contador', style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          Container(
           padding: const EdgeInsets.all(20.0),
           color: Colors.amberAccent,
           alignment: Alignment.center,
           child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               mainAxisSize: MainAxisSize.max,
               children: <Widget>[
                 ElevatedButton(onPressed: _incrementarContador, child: const Icon(Icons.arrow_circle_up)),
                 ElevatedButton(onPressed: _decrementarContador, child: const Icon(Icons.arrow_circle_down)),
                 ElevatedButton(onPressed: _reiniciarContador, child: const Icon(Icons.restart_alt_rounded))
               ]
           ),
          )
        ],
      )
    );
  }
}

Widget cuerpo(){
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(image: NetworkImage("https://preview.redd.it/q258o72ldq461.png?auto=webp&s=379018fc1ac6e77b566316bdce50d7bde723df1f"))
    ),
  );
}