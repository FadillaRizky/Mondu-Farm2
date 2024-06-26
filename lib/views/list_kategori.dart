import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mondu_farm/views/detail_ternak.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/custom_extension.dart';

class CategoryList extends StatefulWidget {
  final String kategori;

  const CategoryList({
    Key? key,
    required this.kategori,
  }) : super(key: key);

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  Map<dynamic, dynamic> dataTernak = {};
  List<dynamic> dataKey = [];

  final FlutterTts flutterTts = FlutterTts();

  Future<String> getImageFromStorage(String pathName) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("ternak")
        .child(widget.kategori.toLowerCase())
        .child(pathName);

    return ref.getDownloadURL();
  }

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }

  Future<void> getDataBooking() async {
    dataTernak = {};
    dataKey = [];
    await FirebaseDatabase.instance.ref().child('booking').get().then((value) {
      dataTernak = value.value as Map<dynamic, dynamic>;
      dataTernak.entries.forEach((element) {
        dataKey.add(element.value['id_ternak']);
      });
      setState(() {});
      playVoiceover(
          'maiwa pilih ${voiceKategori(widget.kategori.toLowerCase())} napa mbuham');
    });
  }

  voiceKategori(String ternak) {
    switch (ternak) {
      case 'sapi':
        return "hapi";
      case 'kuda':
        return "njara";
      case 'kerbau':
        return "karambo";
      case 'kambing':
        return "kamambi";
    }
  }

  @override
  void initState() {
    super.initState();
    getDataBooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.latar,
      ),
      backgroundColor: Warna.latar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/landscape_${widget.kategori.toLowerCase()}.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child("ternak")
                      .child(widget.kategori.toLowerCase())
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        (snapshot.data!).snapshot.value != null) {
                      Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                          (snapshot.data! as DatabaseEvent).snapshot.value
                              as Map<dynamic, dynamic>);
                      List<Map<dynamic, dynamic>> dataList = [];
                      data.removeWhere((key, value) {
                        return dataKey.contains(key);
                      });
                      print(data);
                      data.forEach((key, value) {
                        final currentData = Map<String, dynamic>.from(value);
                        dataList.add({
                          'key': key,
                          'gambar_1': currentData['gambar_1'],
                          'gambar_2': currentData['gambar_2'],
                          'gambar_3': currentData['gambar_3'],
                          'usia': currentData['usia'],
                          'tinggi': currentData['tinggi'],
                          'berat': currentData['berat'],
                          'harga': currentData['harga'],
                        });
                      });

                      if (dataList.length != 0) {
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 10, // Spacing between columns
                            mainAxisSpacing: 10, // Spacing between rows
                          ),
                          itemCount: dataList.length, // Number of items
                          itemBuilder: (context, index) {
                            return FutureBuilder(
                              // future: getImageFromStorage("9Fgr9tiyKt-PhotoProfile.png"),
                              future: getImageFromStorage(
                                  dataList[index]['gambar_1'].toString()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  print(snapshot.data!);
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) => DetailTernak(
                                                      // url1: snapshot.data!,
                                                      url1: dataList[index]
                                                              ['gambar_1']
                                                          .toString(),
                                                      url2: dataList[index]
                                                              ['gambar_2']
                                                          .toString(),
                                                      url3: dataList[index]
                                                              ['gambar_3']
                                                          .toString(),
                                                      kategori: widget.kategori
                                                          .toLowerCase(),
                                                      uid: dataList[index]
                                                          ['key'],
                                                    )));
                                      },
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  snapshot.data!,
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  fit: BoxFit.fill)),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0x494949),
                                                    Color(0xFF383838),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment(0, 1),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ));
                                }
                                if (snapshot.hasError) {
                                  return Text("Terjadi Kesalahan");
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          },
                        );
                      }
                    }
                    if (snapshot.hasData) {
                      return Center(
                          child: Text(
                        "Ternak Tidak Tersedia",
                      ));
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
