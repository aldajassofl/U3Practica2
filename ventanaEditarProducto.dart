import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:papeleria_parelib/aplicacion.dart';
import 'package:papeleria_parelib/services.dart';
class subEditar extends StatefulWidget {
  const subEditar({super.key});

  @override
  State<subEditar> createState() => _subEditarState();
}

class _subEditarState extends State<subEditar> {
  var imagen = null;
  var subido = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar"),
        actions: [
          IconButton(onPressed: ()async {
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
                      SnackBar(content: Text("Producto Actualizado!")));
                });
                //Quitar Circular
                Navigator.pop(context);
                //Volver a pagina principal
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){return App();}));
                Navigator.push(context, MaterialPageRoute(builder: (builder){return subEditar();}));
                Navigator.pop(context);
              });
            }
            setState(() {
              subido=false;
            });
          }, icon: Icon(Icons.done)),
          SizedBox(width: 10,)
        ],
      ),
      body: editProduct(),
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

                        Navigator.pop(context);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){return App();}));
                        Navigator.push(context, MaterialPageRoute(builder: (builder){return subEditar();}));
                        Navigator.pop(context);
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
        /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  idRefer="";
                  nombreEdit.clear();
                  descEdit.clear();
                  existEdit.clear();
                  precioEdit.clear();
                  image_to_uploadEdit = null;
                  Navigator.pop(context);
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
                            SnackBar(content: Text("Producto Actualizado!")));
                      });
                      //Quitar Circular
                      Navigator.pop(context);
                      //Volver a pagina principal
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){return App();}));
                      Navigator.push(context, MaterialPageRoute(builder: (builder){return subEditar();}));
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
                    Text("Actualizar")
                  ],
                )),
          ],
        )*/
      ],
    );
  }
}
