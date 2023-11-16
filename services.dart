import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

var baseRemota = FirebaseFirestore.instance;
var fireStorage = FirebaseStorage.instance;

class DB {
  static Future deleteImageFromStorage(String URL) async{
    final String path = URL.split("?")[0];
    final String fileName = path.split("%2F").last;
    final Reference refe = fireStorage.ref().child("productos").child(fileName);
    return await refe.delete();
  }
  static Future<XFile> getImageXFileByUrl(String url) async {
    var file = await DefaultCacheManager().getSingleFile(url);
    XFile result = await XFile(file.path);
    return result;
  }
  static String generateID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  static String getIdImage(String URL){
    final String path = URL.split("?")[0];
    final String fileName = path.split("%2F").last;
    final String id = fileName.split(".")[0];
    return id;
  }
  static Future<String?> uploadImage(File image,String id) async {
    final String nameFile = image.path.split("/").last;
    final String imageType = image.path.split(".").last;
    final String uploadNameFile = "${id}.${imageType}";
    final Reference refe = fireStorage.ref().child("productos").child(uploadNameFile);
    final UploadTask uploadTask = refe.putFile(image);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
    final String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  static Future<XFile?> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery,imageQuality: 10);
    return image;
  }

  static Future<XFile?> takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 10);
    return image;
  }

  static Future insert(Map<String, dynamic> persona) async {
    return await baseRemota.collection("producto").add(persona);
  }

  static Future<List> showAll() async {
    List temp = [];
    var query = await baseRemota.collection("producto").get();
    query.docs.forEach((element) {
      Map<String, dynamic> dato = element.data();
      dato.addAll({'id': element.id});
      temp.add(dato);
    });
    return temp;
  }

  static Future delete(String id) async {
    return await baseRemota.collection("producto").doc(id).delete();
  }

  static Future update(Map<String, dynamic> producto) async {
    //Se recupera desde la consulta
    String id = producto['id'];
    producto.remove('id');
    return await baseRemota.collection("producto").doc(id).update(producto);
  }
}
