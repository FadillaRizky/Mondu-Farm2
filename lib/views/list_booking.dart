import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mondu_farm/views/detail_nota.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListBooking extends StatefulWidget {
  const ListBooking({Key? key}) : super(key: key);

  @override
  State<ListBooking> createState() => _ListBookingState();
}

class _ListBookingState extends State<ListBooking> {
  String id_user = "";

  final FlutterTts flutterTts = FlutterTts();

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
    });
  }

  String formatteddate(String date) {
    var formatteddate = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return formatteddate;
  }

  iconKategori(String kategori) {
    switch (kategori) {
      case 'sapi':
        {
          return Image.asset("assets/icon_sapi.png",
              height: 50, alignment: Alignment.topLeft);
        }
      case 'kuda':
        {
          return Image.asset(
            "assets/icon_kuda.png",
            height: 50,
            alignment: Alignment.topLeft,
          );
        }
      case 'kerbau':
        {
          return Image.asset("assets/icon_kerbau.png",
              height: 50, alignment: Alignment.topLeft);
        }
      case 'kambing':
        {
          return Image.asset(
            "assets/icon_kambing.png",
            height: 50,
            alignment: Alignment.topLeft,
          );
        }
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  Future<String> getImageFromStorage(String pathName, String kategori) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("ternak")
        .child(kategori.toLowerCase())
        .child(pathName);

    return ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.latar,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Warna.latar,
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().child("booking").onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
            Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                (snapshot.data! as DatabaseEvent).snapshot.value
                    as Map<dynamic, dynamic>);
            List<Map<dynamic, dynamic>> dataList = [];
            data.forEach((key, value) {
              final currentData = Map<String, dynamic>.from(value);
              dataList.add({
                'id_user': currentData['id_user'],
                'nama': currentData['nama'],
                'no_telepon': currentData['no_telepon'],
                'kategori': currentData['kategori'],
                'url_gambar': currentData['url_gambar'],
                'tanggal_booking': currentData['tanggal_booking'],
                'id_nota': currentData['id_nota']
              });
            });
            List<Map<dynamic, dynamic>> filteredList =
                dataList.where((entry) => entry['id_user'] == id_user).toList();
            if (filteredList.isNotEmpty) {
              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FutureBuilder(
                                future: getImageFromStorage(
                                    filteredList[index]["url_gambar"]
                                        .toString(),
                                    filteredList[index]["kategori"].toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.network(
                                      snapshot.data!,
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, obj, stackTrace) {
                                        return Image.asset(
                                            "assets/placeholder.png");
                                      },
                                      // loadingBuilder: (context, child, loadingProgress) {
                                      //   return CircularProgressIndicator();
                                      // },
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset("assets/placeholder.png",width: double.infinity,
                                        height: 300,),
                                    );
                                  }
                                  return  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: double.infinity,
                                        height: 300,
                                        child: Center(child: CircularProgressIndicator(),),
                                      )
                                  );
                                })),
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment(0, 1),
                                colors: <Color>[
                                  Color(0x494949),
                                  Color(0xFF505050),
                                ], // Gradient from https://learnui.design/tools/gradient-generator.html
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          bottom: 15,
                          // right: 5,
                          child: Row(
                            children: [
                              Image.asset("assets/calendar.png", height: 30),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${formatteddate(filteredList[index]["tanggal_booking"].toString())}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            bottom: 15,
                            right: 15,
                            child: (filteredList[index]['id_nota'] == "null")
                                ?
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Warna.primary),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13)))),
                                    onPressed: () {
                                      playVoiceover(
                                          "na hurat mu talanga padoi");
                                    },
                                    child: Icon(
                                      Icons.sync,
                                      color: Colors.white,
                                    )
                                    )
                                : ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            Warna.primary),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        13)))),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (ctx) => DetailNota(
                                                    nama: filteredList[index]
                                                        ['nama'],
                                                    no_telepon:
                                                        filteredList[index]
                                                            ['no_telepon'],
                                                    idUser: id_user,
                                                    idNota: filteredList[index]
                                                        ['id_nota'],
                                                  )));
                                    },
                                    child: SizedBox(
                                        height: 30,
                                        child: Image.asset("assets/sticky-notes.png"))
                                    ))
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 100,
                        child: Lottie.asset("assets/lottie/empty.json")),
                    Text(
                      "Kosong",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }
          }
          if (snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 100,
                      child: Lottie.asset("assets/lottie/empty.json")),
                  Text(
                    "Kosong",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
