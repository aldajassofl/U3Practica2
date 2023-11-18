import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papeleria_parelib/services.dart';
import 'package:papeleria_parelib/ventanaAgregarProducto.dart';
import 'package:papeleria_parelib/ventanaEditarProducto.dart';
import 'package:papeleria_parelib/ventanaImagen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

String titulo = "";
int index = 0;

var nombreEdit = TextEditingController();
var descEdit = TextEditingController();
var existEdit = TextEditingController();
var precioEdit = TextEditingController();
var URLEdit = "";
File? image_to_uploadEdit;
var idRefer = "";
File? image_to_view;

class _AppState extends State<App> {
  int _index = 0;

  File? imagen_to_upload;
  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  final existencias = TextEditingController();
  final precio = TextEditingController();
  var imagen = null;
  var subido = false;
  String busqueda="";
  String busquedaLista ="";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
      appBar: AppBar(
        title: Text("PARELIB"),
        bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory),child: Text("Inventario"),),
              Tab(icon: Icon(Icons.checklist),child: Text("Comprar"),),
            ]
        ),
      ),
      body: TabBarView(
          children: [
        showProducts(),
        showListaCompras()
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (builder){return subAgregar();}));
          },
          child: Icon(Icons.add)),
    ));
  }
  Widget showProducts() {
    return Column(
      children: [
        Container(
          color: Colors.black12,
          child: TextField(
            decoration: InputDecoration(suffixIcon: Icon(Icons.search)),
            onChanged: (text){
              setState(() {
                busqueda = text;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: FutureBuilder(future: DB.showAll(busqueda), builder: (context,listaJSON){
            if(listaJSON.hasData){
              return ListView.builder(
                  itemCount: listaJSON.data?.length,
                  itemBuilder: (context,i){
                    Color aviso = Colors.transparent;
                    if(listaJSON.data?[i]['existencias']==0){
                      Color sinStock = Colors.red;
                      aviso = sinStock;
                    }
                    if(listaJSON.data?[i]['existencias']<10){
                      Color pocasExistencias = Colors.orangeAccent;
                      aviso = pocasExistencias;
                    }
                    if(listaJSON.data?[i]['existencias']>10){
                      Color existenciasSuficientes = Colors.lightGreen;
                      aviso = existenciasSuficientes;
                    }
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      decoration: ShapeDecoration(shape: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.solid),borderRadius: BorderRadius.zero),color: Colors.black54),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${listaJSON.data?[i]['nombre']}\n",
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    )),
                                ElevatedButton(
                                    onPressed: () async {
                                      idRefer = "${listaJSON.data?[i]['id']}";
                                      nombreEdit.text = "${listaJSON.data?[i]['nombre']}";
                                      descEdit.text =
                                      "${listaJSON.data?[i]['descripcion']}";
                                      precioEdit.text =
                                      "${listaJSON.data?[i]['precio']}";
                                      existEdit.text =
                                      "${listaJSON.data?[i]['existencias']}";
                                      URLEdit = "${listaJSON.data?[i]['imagen']}";
                                      final imagenEdit = await DB.getImageXFileByUrl("${listaJSON.data?[i]['imagen']}");
                                      setState(() {
                                        image_to_uploadEdit = File(imagenEdit!.path);
                                      });
                                      Navigator.push(context, MaterialPageRoute(builder: (builder){return subEditar();}));

                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.more_horiz),
                                        Text("Editar"),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: ()async{
                                  final imagenVer = await DB.getImageXFileByUrl("${listaJSON.data?[i]['imagen']}");
                                  setState(() {
                                    image_to_view = File(imagenVer!.path);
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (builder){return subImagen();}));
                                },
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black),),
                                child: Image.network(
                                    "${listaJSON.data?[i]['imagen']}",
                                      height: 300
                                )),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: ShapeDecoration(shape: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),color: Colors.black12),
                            child: Column(
                              children: [
                                Text(
                                  "Descripción: ${listaJSON.data?[i]['descripcion']}\n\n"
                                      "Precio unitario: \$${listaJSON.data?[i]['precio']}\n",
                                  style: TextStyle(fontSize: 20,),
                                ),
                                Text("Existencias: ${listaJSON.data?[i]['existencias']}\n",style: TextStyle(fontSize:20,color: aviso),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
        ),
      ],
    );
  }

  Widget showListaCompras() {
    return Column(
      children: [
        Container(
          color: Colors.black12,
          child: TextField(
            decoration: InputDecoration(suffixIcon: Icon(Icons.search)),
            onChanged: (text){
              setState(() {
                busquedaLista = text;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: FutureBuilder(future: DB.showListaCompras(busquedaLista), builder: (context,listaJSON){
            if(listaJSON.hasData){
              return ListView.builder(
                  itemCount: listaJSON.data?.length,
                  itemBuilder: (context,i){
                    Color aviso = Colors.transparent;
                    if(listaJSON.data?[i]['existencias']==0){
                      Color sinStock = Colors.red;
                      aviso = sinStock;
                    }
                    if(listaJSON.data?[i]['existencias']<10){
                      Color pocasExistencias = Colors.orangeAccent;
                      aviso = pocasExistencias;
                    }
                    if(listaJSON.data?[i]['existencias']>10){
                      Color existenciasSuficientes = Colors.lightGreen;
                      aviso = existenciasSuficientes;
                    }
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      decoration: ShapeDecoration(shape: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.solid),borderRadius: BorderRadius.zero),color: Colors.black54),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${listaJSON.data?[i]['nombre']}\n",
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    )),
                                ElevatedButton(
                                    onPressed: () async {
                                      idRefer = "${listaJSON.data?[i]['id']}";
                                      nombreEdit.text = "${listaJSON.data?[i]['nombre']}";
                                      descEdit.text =
                                      "${listaJSON.data?[i]['descripcion']}";
                                      precioEdit.text =
                                      "${listaJSON.data?[i]['precio']}";
                                      existEdit.text =
                                      "${listaJSON.data?[i]['existencias']}";
                                      URLEdit = "${listaJSON.data?[i]['imagen']}";
                                      final imagenEdit = await DB.getImageXFileByUrl("${listaJSON.data?[i]['imagen']}");
                                      setState(() {
                                        image_to_uploadEdit = File(imagenEdit!.path);
                                      });
                                      Navigator.push(context, MaterialPageRoute(builder: (builder){return subEditar();}));

                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.more_horiz),
                                        Text("Editar"),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: ()async{
                                  final imagenVer = await DB.getImageXFileByUrl("${listaJSON.data?[i]['imagen']}");
                                  setState(() {
                                    image_to_view = File(imagenVer!.path);
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (builder){return subImagen();}));
                                },
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black),),
                                child: Image.network(
                                    "${listaJSON.data?[i]['imagen']}",
                                    height: 300
                                )),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: ShapeDecoration(shape: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),color: Colors.black12),
                            child: Column(
                              children: [
                                Text(
                                  "Descripción: ${listaJSON.data?[i]['descripcion']}\n\n"
                                      "Precio unitario: \$${listaJSON.data?[i]['precio']}\n",
                                  style: TextStyle(fontSize: 20,),
                                ),
                                Text("Existencias: ${listaJSON.data?[i]['existencias']}\n",style: TextStyle(fontSize:20,color: aviso),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
        ),
      ],
    );
  }
}
//ListTile
/* ListTile(
                      title: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: ShapeDecoration(
                                shape: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10))),color: Colors.black12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${listaJSON.data?[i]['nombre']}\n",
                                    style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold)),
                                ElevatedButton(
                                    onPressed: () async {
                                      idRefer = "${listaJSON.data?[i]['id']}";
                                      nombreEdit.text = "${listaJSON.data?[i]['nombre']}";
                                      descEdit.text =
                                      "${listaJSON.data?[i]['descripcion']}";
                                      precioEdit.text =
                                      "${listaJSON.data?[i]['precio']}";
                                      existEdit.text =
                                      "${listaJSON.data?[i]['existencias']}";
                                      URLEdit = "${listaJSON.data?[i]['imagen']}";
                                      final imagenEdit = await DB.getImageXFileByUrl("${listaJSON.data?[i]['imagen']}");
                                      setState(() {
                                        image_to_uploadEdit = File(imagenEdit!.path);
                                      });
                                      Navigator.push(context, MaterialPageRoute(builder: (builder){return subEditar();}));

                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.more_horiz),
                                        Text("Editar"),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: ()async{
                                  final imagenVer = await DB.getImageXFileByUrl("${listaJSON.data?[i]['imagen']}");
                                  setState(() {
                                    image_to_view = File(imagenVer!.path);
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (builder){return subImagen();}));
                                },
                                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.black),),
                                child: Image.network(
                                  "${listaJSON.data?[i]['imagen']}",
                                  height: 300,
                                )),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: ShapeDecoration(shape: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),color: Colors.black12),
                            child: Column(
                              children: [
                                Text(
                                  "Descripción: ${listaJSON.data?[i]['descripcion']}\n\n"
                                      "Precio unitario: \$${listaJSON.data?[i]['precio']}\n",
                                  style: TextStyle(fontSize: 20,),
                                ),
                                Text("Existencias: ${listaJSON.data?[i]['existencias']}\n",style: TextStyle(fontSize:20,color: aviso),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )*/
//Control de existencias
/*
* showDialog(
                              context: context,
                              builder: (builder) {
                                final existencias = TextEditingController();
                                existencias.text =
                                    "${listaJSON.data?[i]['existencias']}";
                                return AlertDialog(
                                  title: Text(
                                      "Existencias de ${listaJSON.data?[i]['nombre']}"),
                                  actions: [
                                    TextFormField(
                                      controller: existencias,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        final intNumber = int.tryParse(value!);
                                        if (intNumber != null &&
                                            intNumber >= 0) {
                                          return null;
                                        }
                                        return 'Ingrese el numero';
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              int tempExist = int.parse(
                                                  "${existencias.text}");
                                              if (tempExist > 0) tempExist--;
                                              setState(() {
                                                existencias.text =
                                                    "${tempExist}";
                                              });
                                            },
                                            child:
                                                Icon(Icons.exposure_minus_1)),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                            onPressed: () {
                                              int tempExist = int.parse(
                                                  "${existencias.text}");
                                              tempExist++;
                                              setState(() {
                                                existencias.text =
                                                    "${tempExist}";
                                              });
                                            },
                                            child: Icon(Icons.plus_one)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              existencias.clear();
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancelar")),
                                        SizedBox(width: 10),
                                        TextButton(
                                            onPressed: () {
                                              var tempJSON = {
                                                'id':
                                                    "${listaJSON.data?[i]['id']}",
                                                'nombre':
                                                    "${listaJSON.data?[i]['nombre']}",
                                                'descripcion':
                                                    "${listaJSON.data?[i]['descripcion']}",
                                                'existencias':
                                                    "${existencias.text}",
                                                'precio':
                                                    "${listaJSON.data?[i]['precio']}",
                                                'imagen':
                                                    "${listaJSON.data?[i]['imagen']}",
                                              };
                                              DB.update(tempJSON).then((value) {
                                                existencias.clear();
                                                Navigator.pop(context);
                                                setState(() {
                                                  index = 0;
                                                });
                                              });
                                            },
                                            child: Text("Aceptar"))
                                      ],
                                    ) //CONTROL DE EXISTENCIAS
                                  ],
                                ); //CONTROL DE EXISTENCIAS
                              });
* */
