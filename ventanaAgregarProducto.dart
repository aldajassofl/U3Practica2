import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papeleria_parelib/aplicacion.dart';
import 'package:papeleria_parelib/services.dart';

class subAgregar extends StatefulWidget {
  const subAgregar({super.key});

  @override
  State<subAgregar> createState() => _subAgregarState();
}

class _subAgregarState extends State<subAgregar> {
  File? imagen_to_upload;
  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  final existencias = TextEditingController();
  final precio = TextEditingController();
  var imagen = null;
  var subido = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Producto"),
        actions: [
          IconButton(onPressed: ()async {
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
                //Quitar circular
                Navigator.pop(context);
                //Volver a pagina principal
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){return App();}));
                Navigator.push(context, MaterialPageRoute(builder: (builder){return subAgregar();}));
                Navigator.pop(context);
              });
            }
            setState(() {
              subido=false;
            });
          }, icon: Icon(Icons.done))
        ],
      ),
      body: addProduct(),
    );
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
        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
                      //Quitar circular
                      Navigator.pop(context);
                      //Volver a pagina principal
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){return App();}));
                      Navigator.push(context, MaterialPageRoute(builder: (builder){return subAgregar();}));
                      Navigator.pop(context);
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
        )*/
      ],
    );
  }
}

