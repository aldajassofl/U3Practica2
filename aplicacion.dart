import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papeleria_parelib/services.dart';

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

class _AppState extends State<App> {
  File? imagen_to_upload;
  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  final existencias = TextEditingController();
  final precio = TextEditingController();
  var imagen = null;
  var subido = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("PARELIB ${titulo}"),
            bottom: TabBar(tabs: [
              Tab(
                icon: Icon(Icons.storefront),
                text: "Avisos",
              ),
              Tab(
                icon: Icon(Icons.inventory),
                text: "Control Inventario",
              ),
            ]),
          ),
          body: TabBarView(children: [verAvisos(), productControl()]),
        ));
  }
  Widget verAvisos(){
    return FutureBuilder(future: DB.showAll(), builder: (context,listaJSON){
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
              return ListTile(
                minLeadingWidth: 0,
                shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          Text(""
                              "${listaJSON.data?[i]['nombre']}\n",
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
                                setState(() {
                                  index = 2;
                                });
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.edit),
                                  Text("Editar"),
                                ],
                              ))
                        ],
                      ),
                    ),
                    Container(
                      decoration:ShapeDecoration(shape: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(0))),color: Colors.black),
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        "${listaJSON.data?[i]['imagen']}",
                        height: 300,
                      ),
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
                onTap: (){
                  showDialog(
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
                                ElevatedButton(
                                    onPressed: () {
                                      existencias.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Column(
                                      children: [
                                        Icon(Icons.cancel_outlined),
                                        Text("Cancelar"),
                                      ],
                                    )),
                                SizedBox(width: 10),
                                ElevatedButton(
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
                                    child: Column(
                                      children: [
                                        Icon(Icons.done),
                                        Text("Aceptar"),
                                      ],
                                    ))
                              ],
                            ) //CONTROL DE EXISTENCIAS
                          ],
                        ); //CONTROL DE EXISTENCIAS
                      });
                },
              );
            });
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }
  Widget dinamico() {
    switch (index) {
      case 0:
        {
          return showProducts();
        }
      case 1:
        {
          return addProduct();
        }
      case 2:
        {
          return editProduct();
        }
      default:
        {
          return Center();
        }
    }
  }

  Widget showProducts() {
    return FutureBuilder(
        future: DB.showAll(),
        builder: (context, listaJSON) {
          if (listaJSON.hasData) {
            return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: listaJSON.data?.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    minLeadingWidth: 0,
                    shape: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
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
                              Text(""
                                  "${listaJSON.data?[i]['nombre']}\n",
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

                                    setState(() {
                                      index = 2;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Icon(Icons.edit),
                                      Text("Editar"),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        Container(
                        decoration:ShapeDecoration(shape: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(0))),color: Colors.black),
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            "${listaJSON.data?[i]['imagen']}",
                            height: 300,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: ShapeDecoration(shape: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),color: Colors.black12),
                          child: Text(
                            "Descripción: ${listaJSON.data?[i]['descripcion']}\n"
                                "Existencias: ${listaJSON.data?[i]['existencias']}\n"
                                "Precio unitario: \$${listaJSON.data?[i]['precio']}\n",
                            style: TextStyle(fontSize: 20,),
                          ),
                        ),

                      ],
                    ),
                    onTap: (){
                      showDialog(
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
                                    ElevatedButton(
                                        onPressed: () {
                                          existencias.clear();
                                          Navigator.pop(context);
                                        },
                                        child: Column(
                                          children: [
                                            Icon(Icons.cancel_outlined),
                                            Text("Cancelar"),
                                          ],
                                        )),
                                    SizedBox(width: 10),
                                    ElevatedButton(
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
                                        child: Column(
                                          children: [
                                            Icon(Icons.done),
                                            Text("Aceptar"),
                                          ],
                                        ))
                                  ],
                                ) //CONTROL DE EXISTENCIAS
                              ],
                            ); //CONTROL DE EXISTENCIAS
                          });
                    },
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget productControl() {
    return Scaffold(
        body: dinamico(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory), label: "Productos"),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Agregar"),
            if(idRefer!="")BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Editar"),
          ],
          currentIndex: index,
          onTap: (i) {
            setState(() {
              index = i;
            });
          },
        ));
  }

  Widget addProduct() {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(30),
      children: [
        Text(
          "Agregar Nuevo Producto",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        TextFormField(
            controller: nombre,
            decoration: InputDecoration(labelText: "Nombre"),
            validator: (String? val) {
              if (val!.isEmpty) {
                return 'Agregue el nombre del producto';
              }
              return null;
            }),
        TextFormField(
            controller: descripcion,
            decoration: InputDecoration(labelText: "Descripción"),
            validator: (String? val) {
              if (val!.isEmpty) {
                return 'Agregue una descripción';
              }
              return null;
            }),
        TextFormField(
          controller: existencias,
          decoration: InputDecoration(labelText: "Existencias"),
          keyboardType: TextInputType.number,
          validator: (value) {
            final intNumber = int.tryParse(value!);
            if (intNumber != null && intNumber >= 0) {
              return null;
            }
            return 'Ingrese el numero';
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        TextFormField(
          controller: precio,
          decoration: InputDecoration(labelText: "Precio unitario"),
          keyboardType: TextInputType.number,
          validator: (value) {
            final doubleNumber = double.tryParse(value!);
            if (doubleNumber != null && doubleNumber >= 0) {
              if (RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value!)) {
                return null;
              } else {
                return 'Ingrese un número con hasta 2 decimales';
              }
            }
            return 'Ingrese un número válido';
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () async {
                  final imagen = await DB.getImage();
                  setState(() {
                    imagen_to_upload = File(imagen!.path);
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.image),
                    Text("Galería"),
                  ],
                )),
            ElevatedButton(
                onPressed: () async {
                  final imagen = await DB.takePhoto();
                  setState(() {
                    imagen_to_upload = File(imagen!.path);
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.camera_alt),
                    Text("Cámara"),
                  ],
                )),
          ],
        ),
        imagen_to_upload != null
            ? Image.file(imagen_to_upload!)
            : Container(
                margin: EdgeInsets.all(10),
                height: 200,
                color: Colors.lightBlueAccent,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    index = 0;
                  });
                  nombre.clear();
                  descripcion.clear();
                  existencias.clear();
                  precio.clear();
                  imagen_to_upload = null;
                  subido = true;
                },
                child: Column(
                  children: [
                    Icon(Icons.cancel_outlined),
                    Text("Cancelar"),
                  ],
                )),
            ElevatedButton(
                onPressed: () async {
                  if (imagen_to_upload == null ||
                      nombre.text == "" ||
                      descripcion.text == "" ||
                      existencias.text == "" ||
                      precio.text == "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(duration: Duration(milliseconds: 1000),content: Text("Rellene los campos faltantes!")));
                    return;
                  }
                  if (subido == false) {
                    showDialog(
                      barrierDismissible: false,
                        context: context,
                        builder: (builder) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        });
                    final idImagen = "${DB.generateID()}";
                    imagen = await DB.uploadImage(imagen_to_upload!,idImagen).then((value) async {
                      var tempJSON = {
                        'nombre': nombre.text,
                        'descripcion': descripcion.text,
                        'existencias':int.parse(existencias.text),
                        'precio': double.parse(precio.text),
                        'imagen': "${value}"
                      };
                      await DB.insert(tempJSON).then((value) {
                        nombre.clear();
                        descripcion.clear();
                        existencias.clear();
                        precio.clear();
                        imagen_to_upload = null;
                        setState(() {
                          subido = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Producto Insertado!")));
                      });
                      Navigator.pop(context);
                      setState(() {
                        index = 0;
                      });
                    });
                  }
                  setState(() {
                    subido=false;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.done),
                    Text("Agregar"),
                  ],
                )),
          ],
        )
      ],
    );
  }

  Widget editProduct() {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(30),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Editando Producto",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(onPressed: (){
              showDialog(context: context, builder: (builder){
                return AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text("¿Eliminar?"),
                    Icon(Icons.delete_forever)
                  ],),
                  content: Text("El producto se eliminará para siempre."),
                  actions: [
                    ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: Column(
                      children: [
                        Icon(Icons.cancel_outlined),
                        Text("Cancelar")
                      ],
                    )),
                    ElevatedButton(onPressed: () async{
                      Navigator.pop(context);
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (builder) {
                            return WillPopScope(
                              onWillPop: () async => false,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          });
                      await DB.delete(idRefer).then((value) async{
                        await DB.deleteImageFromStorage(URLEdit).then((value){
                          idRefer="";
                          nombreEdit.clear();
                          descEdit.clear();
                          existEdit.clear();
                          precioEdit.clear();
                          image_to_uploadEdit = null;
                        });
                        Navigator.pop(context);
                        setState(() {
                          index = 0;
                        });
                      });

                    }, child: Column(
                      children: [
                        Icon(Icons.delete_forever),
                        Text("Eliminar")
                      ],
                    ))
                  ],
                );
              });
            }, child: Column(
              children: [
                Icon(Icons.delete_forever),
                Text("Borrar")
              ],
            ))
          ],
        ),
        TextFormField(
            enabled: (idRefer == "") ? false : true,
            controller: nombreEdit,
            decoration: InputDecoration(labelText: "Nombre"),
            validator: (String? val) {
              if (val!.isEmpty) {
                return 'Agregue el nombre del producto';
              }
              return null;
            }),
        TextFormField(
            enabled: (idRefer == "") ? false : true,
            controller: descEdit,
            decoration: InputDecoration(labelText: "Descripción"),
            validator: (String? val) {
              if (val!.isEmpty) {
                return 'Agregue una descripción';
              }
              return null;
            }),
        TextFormField(
          enabled: (idRefer == "") ? false : true,
          controller: existEdit,
          decoration: InputDecoration(labelText: "Existencias"),
          keyboardType: TextInputType.number,
          validator: (value) {
            final intNumber = int.tryParse(value!);
            if (intNumber != null && intNumber >= 0) {
              return null;
            }
            return 'Ingrese el numero';
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        TextFormField(
          enabled: (idRefer == "") ? false : true,
          controller: precioEdit,
          decoration: InputDecoration(labelText: "Precio unitario"),
          keyboardType: TextInputType.number,
          validator: (value) {
            final doubleNumber = double.tryParse(value!);
            if (doubleNumber != null && doubleNumber >= 0) {
              if (RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value!)) {
                return null;
              } else {
                return 'Ingrese un número con hasta 2 decimales';
              }
            }
            return 'Ingrese un número válido';
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () async {
                  if (idRefer != "") {
                    final imagen = await DB.getImage();
                    setState(() {
                      image_to_uploadEdit = File(imagen!.path);
                    });
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 500),content: Text("No hay producto relacionado!")));
                  }
                },
                child: Column(children: [
                  Icon(Icons.image),
                  Text("Galería")
                ],)),
            ElevatedButton(
                onPressed: () async {
                  if (idRefer != "") {
                    final imagen = await DB.takePhoto();
                    setState(() {
                      image_to_uploadEdit = File(imagen!.path);
                    });
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 500),content: Text("No hay producto relacionado!")));
                  }
                },
                child: Column(
                  children: [
                    Icon(Icons.camera_alt),
                    Text("Camara")
                  ],
                )),
          ],
        ),
        image_to_uploadEdit != null
            ? Image.file(image_to_uploadEdit!)
            : Container(
                margin: EdgeInsets.all(10),
                height: 200,
                color: Colors.lightBlueAccent,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    index = 0;
                  });
                  idRefer="";
                  nombreEdit.clear();
                  descEdit.clear();
                  existEdit.clear();
                  precioEdit.clear();
                  image_to_uploadEdit = null;
                },
                child: Column(
                  children: [
                    Icon(Icons.cancel_outlined),
                    Text("Cancelar")
                  ],
                )),
            ElevatedButton(
                onPressed: () async {
                  if(idRefer==""){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(duration: Duration(milliseconds: 500),content: Text("No hay un producto seleccionado!")));
                    return;
                  }
                  if (image_to_uploadEdit == null ||
                      nombreEdit.text == "" ||
                      descEdit.text == "" ||
                      existEdit.text == "" ||
                      precioEdit.text == "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(duration: Duration(milliseconds: 500),content: Text("Rellene los campos faltantes!")));
                    return;
                  }
                  if (subido == false) {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (builder) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        });
                    imagen =
                    await DB.uploadImage(image_to_uploadEdit!,DB.getIdImage(URLEdit)).then((value) async {
                      var tempJSON = {
                        'id': idRefer,
                        'nombre': nombreEdit.text,
                        'descripcion': descEdit.text,
                        'existencias': int.parse(existEdit.text),
                        'precio': double.parse(precioEdit.text),
                        'imagen': "${value}"
                      };
                      await DB.update(tempJSON).then((value) {
                        idRefer="";
                        nombreEdit.clear();
                        descEdit.clear();
                        existEdit.clear();
                        precioEdit.clear();
                        image_to_uploadEdit = null;
                        setState(() {
                          subido = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Producto Insertado!")));
                      });
                      Navigator.pop(context);
                      setState(() {
                        index = 0;
                      });
                    });
                  }
                  setState(() {
                    subido=false;
                  });
                },
                child: Column(
                  children: [
                    Icon(Icons.done),
                    Text("Actualizar")
                  ],
                )),
          ],
        )
      ],
    );
  }
}
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
