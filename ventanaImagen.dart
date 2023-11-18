import 'package:flutter/material.dart';
import 'package:papeleria_parelib/aplicacion.dart';

class subImagen extends StatefulWidget {
  const subImagen({super.key});

  @override
  State<subImagen> createState() => _subImagenState();
}

class _subImagenState extends State<subImagen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viendo Imagen"),
      ),
      body: verImagen(),
    );
  }
  Widget verImagen(){
    return ColoredBox(
      color: Colors.black,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: InteractiveViewer(
            child:
            Image.file(
              image_to_view!,
              height: MediaQuery.of(context).size.height,
            )
        )
      ),
    );
  }
}
