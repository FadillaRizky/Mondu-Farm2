import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import "package:http/http.dart" as http;
import 'package:mondu_farm/utils/custom_extension.dart';

class Chat {

  static Future<Uint8List> convertBlobUrlToUint8List(String blobUrl) async {
    var response = await http.get(Uri.parse(blobUrl));
    if (response.statusCode == 200) {
      Uint8List uint8list = Uint8List.fromList(response.bodyBytes);
      return uint8list;
    } else {
      throw Exception('Failed to fetch data from Blob URL');
    }
  }
  ///Logic untuk kirim voicenote ke Firebase
  static Future<void> InsertChat(String filePath, int durasi, String idUser, String idTernak,String kategori,BuildContext context) async {
    var metadata = SettableMetadata(
      contentType: "audio/mp3",
    );
    String fileName = "${generateRandomString(10)}-${DateTime.now()}.mp3";
    var fileStorage = FirebaseStorage.instance.ref().child("audio").child(fileName);
    var dbRef = FirebaseDatabase.instance.ref().child("pesan").child(idUser).child(idTernak);

    await dbRef.update({
      "last_chat_user": DateTime.now().toString(),
      "kategori": kategori.toLowerCase(),
    }).then((value) async {
      if (!kIsWeb) {
        await fileStorage.putFile(File(filePath), metadata).whenComplete(() async {
          String linkPath = await fileStorage.getDownloadURL();
          Map<String, dynamic> data = {
            "pesan": linkPath,
            "pesan_dari": "user",
            "durasi": durasi,
            "type": "voice",
            "tanggal": DateTime.now().toString(),
          };
          await dbRef.child("data").push().set(data).whenComplete(() {
            EasyLoading.dismiss();
          });
        });
      } else {
        fileStorage.putData(await convertBlobUrlToUint8List(filePath), metadata).then((p0) async {
          String linkPath = await fileStorage.getDownloadURL();
          Map<String, dynamic> data = {
            "pesan": linkPath,
            "pesan_dari": "user",
            "durasi": durasi,
            "type": "voice",
            "tanggal": DateTime.now().toString(),
          };
          await dbRef.child("data").push().set(data).whenComplete(() {
            EasyLoading.dismiss();
          });
        });
      }
    });
  }
}
