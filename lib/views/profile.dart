import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mondu_farm/views/home.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/custom_extension.dart';

class Profile extends StatefulWidget {
  final String id_user;
  final String? url;

  const Profile({Key? key, required this.id_user, this.url}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ImagePicker imageProfile = ImagePicker();
  File? file;
  Uint8List webImage = Uint8List(8);


  getImage1() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      file = File(image!.path);
    });
  }

  insertData() async {
    try {
      if (file != null) {
        var metadata = SettableMetadata(
          contentType: "image/jpeg",
        );
        String imageName = "${generateRandomString(10)}-${DateTime.now()}.png";
        var imagefile = FirebaseStorage.instance
            .ref()
            .child("users")
            .child(widget.id_user)
            .child(imageName);

        EasyLoading.show(status: 'Tunggu...');
        FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(widget.id_user)
            .update({
          "photo_url": imageName,
        }).then((value) {
          imagefile.putFile(file!).whenComplete(() {
            EasyLoading.showSuccess('Upload Success..',
                dismissOnTap: true, duration: const Duration(seconds: 2));
            Navigator.pop(context);
            return;
          });
        });


      }
    } on Exception catch (e) {
      EasyLoading.showError('Error : ${e}',
          dismissOnTap: true, duration: Duration(seconds: 3));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                getImage1();
              });
            },
            child: SizedBox(
              height: 250,
              width: 250,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: Container(
                    color: Colors.black12,
                    child: file != null
                        ? Image.file(
                      file!,
                      fit: BoxFit.cover,
                    )
                        : widget.url != null
                        ? Image.network(
                      widget.url!,
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.white,
                    ),
                  )
              ),
            ),

          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              gradient: LinearGradient(colors: [
                Warna.latar,
                Warna.primary,
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () {
                  if (file != null) {
                    insertData();
                  }
                },
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                )),
          ),
        ],
      ),
    );
  }
}
