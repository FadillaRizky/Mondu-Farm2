import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mondu_farm/logic/booking.dart';
import 'package:mondu_farm/logic/change_profile.dart';
import 'package:mondu_farm/views/demo_page2.dart';
import 'package:mondu_farm/views/list_booking.dart';
import 'package:mondu_farm/views/list_kategori.dart';
import 'package:mondu_farm/views/chat_list.dart';
import 'package:mondu_farm/views/login_page.dart';
import 'package:mondu_farm/views/profile.dart';
import 'package:mondu_farm/utils/alerts.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/custom_extension.dart';
import 'package:mondu_farm/utils/voice_over.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? nama;
  String id_user = "";

  final FlutterTts flutterTts = FlutterTts();

  Future<String> getImageFromStorage(String pathName) {
    FirebaseStorage storage = FirebaseStorage.instance;
    print("idUser : $id_user");
    Reference ref = storage.ref().child("users").child(id_user).child(pathName);

    return ref.getDownloadURL();
  }

  String? url;

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isUserLoggedIn");
    await prefs.remove("id_user");
    await prefs.remove("nama");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=>LoginPage()), (route) => false);
  }

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }

  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id_user = pref.getString('id_user')!;
      nama = pref.getString('nama')!;
    });
    playVoiceover("maiwa pilih jenis mbada napa mbuham ");
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      insetPadding: EdgeInsets.all(10),
                                      backgroundColor: Colors.white,
                                      elevation: 1,
                                      child: Profile(
                                        id_user: id_user,
                                        url: url,
                                      )
                                      );
                                }).then((value) {
                              setState(() {
                                url = null;
                              });
                            });
                          },
                          child: StreamBuilder(
                            stream: FirebaseDatabase.instance
                                .ref()
                                .child('users')
                                .child(id_user)
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  (snapshot.data!).snapshot.value != null) {
                                Map<dynamic, dynamic> data =
                                    Map<dynamic, dynamic>.from(
                                        (snapshot.data! as DatabaseEvent)
                                            .snapshot
                                            .value as Map<dynamic, dynamic>);
                                print("cetak data : ${data["photo_url"]}");
                                // print("cetak snapshot : ${snapshot.data}");
                                return FutureBuilder(
                                    future: getImageFromStorage(
                                        data["photo_url"] ?? ""),
                                    builder: (context, snapshot) {
                                      if (data["photo_url"] == null ||
                                          data["photo_url"] == "null") {
                                        return Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        );
                                      }
                                      if (snapshot.hasData) {
                                        print(
                                            "photo from firebase : ${snapshot.data}");
                                        url = null;
                                        url = snapshot.data;
                                        return SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10000),
                                              child: Image.network(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                              )),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        print(
                                            "snapshot error : ${snapshot.error}");
                                        return Icon(
                                          Icons.person,
                                          color: Colors.green,
                                        );
                                      }

                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    });
                              }
                              if (snapshot.hasData) {
                                return Icon(
                                  Icons.person,
                                  color: Colors.red,
                                );
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          nama ?? "",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white24)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (ctx) => DemoPage2()));
                            },
                            icon: Icon(Icons.play_arrow,color: Colors.white,),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Alerts.showAlertYesNo(
                                url: "assets/lottie/logout.json",
                                onPressYes: () async {
                                  logout(context);
                                },
                                onPressNo: () {
                                  Navigator.pop(context);
                                },
                                context: context,
                              );
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                            )),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      "assets/logo_mondu.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 15, // Spacing between columns
                    mainAxisSpacing: 15, // Spacing between rows
                  ),
                  itemCount: 4,
                  // Number of items
                  itemBuilder: (context, index) {
                    // Return a container for each item
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => (index == 0)
                                    ? CategoryList(
                                        kategori: 'Sapi',
                                      )
                                    : (index == 1)
                                        ? CategoryList(
                                            kategori: "Kuda",
                                          )
                                        : (index == 2)
                                            ? CategoryList(
                                                kategori: "Kerbau",
                                              )
                                            : CategoryList(
                                                kategori: "Kambing",
                                              )));
                      },
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            "assets/category_${index}.jpg",
                            fit: BoxFit.cover,
                          )),
                    );
                  },
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                EdgeInsets.fromLTRB(18, 10, 18, 18)),
                            backgroundColor:
                                MaterialStateProperty.all(Warna.secondary)),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (ctx) => ChatList()));
                        },
                        icon: SizedBox(
                            width: 80,
                            child: Image.asset("assets/icon_chat2.png"))),
                    IconButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                EdgeInsets.fromLTRB(18, 10, 18, 18)),
                            backgroundColor:
                                MaterialStateProperty.all(Warna.secondary)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => ListBooking()));
                        },
                        icon: SizedBox(
                            width: 80,
                            child: Image.asset(
                              "assets/list.png",
                            ))),
                  ],
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
