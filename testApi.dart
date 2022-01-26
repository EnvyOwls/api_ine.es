import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget{

  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp>{

  Future<List<Data>>? _dataINE;

  Future<List<Data>> _getData() async{

    List<Data>? datos = [];

    final url = Uri.parse('https://servicios.ine.es/wstempus/js/ES/VALORES_VARIABLE/706?page=1');
    final response = await http.get(url);

    if(response.statusCode == 200){
      String data = utf8.decode(response.bodyBytes);
      final jsonData = json.decode(data);//jsonDecode(data);

      for(var migrante in jsonData){
        datos.add(
            Data(migrante['Nombre'])
        );
      }
    }
    else{
      print("hay error :(!");
    }

    return datos;
  }

  void initState(){
    super.initState();
    _dataINE = _getData();
  }

  var size;
  Widget build(BuildContext context){


    return MaterialApp(
        title: 'test API ine.es',

        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Datos INE España', style: TextStyle(color: Colors.black12),),
            backgroundColor: Color.fromARGB(200, 153, 234, 218),
          ),

          body: FutureBuilder(
            future: _dataINE,
            builder: (context, snapshot) {
              size = MediaQuery.of(context).size.width;
              if(snapshot.hasData){
                return Container(
                  child: Table(
                    children: _listNacionalidad(snapshot.data),
                    border: TableBorder.all(color: Colors.indigo),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(color: Colors.teal,),
              );
            },
          ),
        )
    );
  }

  List<TableRow> _listNacionalidad(data){

    List<TableRow> nacionalidad = [];
    List<Data2> datos = procesar(data);
    for(var pais in datos){
      nacionalidad.add(
          TableRow(children: [Text(pais.nacionalidad, textAlign: TextAlign.center,), Text('${pais.cantidad}')])
      );
    }


    return nacionalidad;
  }

  List<Data2> procesar(List<Data> data){

    List<Data2> retorno = [];
    List<Data> temp = data;

    var first;
    int total = 0;
    for(var item in temp){
      first = item.nacionalidad;
      total = count(first, temp);
      retorno.add(Data2(first, total));
      //print('${first},${total}');
      temp.removeWhere((item) => item.nacionalidad == first);
    }
    return retorno;
  }

  int count(String dato, List<Data> datos){
    int cantidad = 0;
    for (var i in datos){
      if(dato == i.nacionalidad){
        cantidad++;
      }
    }

    return cantidad;
  }
}

class Data{
  String nacionalidad;

  Data(this.nacionalidad);
}

class Data2{
  String nacionalidad;
  int cantidad;

  Data2(this.nacionalidad,this.cantidad);
}
