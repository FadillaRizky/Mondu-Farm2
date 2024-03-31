import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:mondu_farm/utils/custom_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_chat.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String idUser = "";

  Future<void> getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      idUser = pref.getString('id_user')!;
    });
  }

  Future<String> getImageFromStorage(String kategori,String pathName) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("ternak")
        .child(kategori.toLowerCase())
        .child(pathName);

    return ref.getDownloadURL();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.latar,
      ),
      backgroundColor: Warna.latar,
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("pesan")
              .child(idUser)
              // .child("-Nnm_V8tHL_EsqxSsCxd")  -Hanya Untuk Testing
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data!).snapshot.value != null) {
              // Variable data mempermudah memanggil data pada database
              Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                  (snapshot.data! as DatabaseEvent).snapshot.value
                      as Map<dynamic, dynamic>);

              List<Map<dynamic, dynamic>> dataList = [];
              data.forEach((key, value) {
                final currentData = Map<String, dynamic>.from(value);
                dataList.add({
                  'uid': key,
                  'data': currentData['data'],
                  'kategori': currentData['kategori'],
                  'last_chat_user': currentData['last_chat_user'],
                });
              });
              dataList.sort((a, b) {
                var aDate = DateTime.parse(a["last_chat_user"]);
                var bDate = DateTime.parse(b["last_chat_user"]);
                return aDate.compareTo(bDate);
              });
              return ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  Future<Map<dynamic, dynamic>>? dataTernak = FirebaseDatabase
                      .instance
                      .ref()
                      .child("ternak")
                      .child("${dataList[index]["kategori"]}")
                      .child("${dataList[index]["uid"]}")
                      .get()
                      .then((value) {
                    return value.value as Map<dynamic, dynamic>;
                  });
                  return FutureBuilder(
                    future: dataTernak,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              FutureBuilder(
                                future: getImageFromStorage(
                                    dataList[index]['kategori'],
                                  data['gambar_1'],),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        snapshot.data!,
                                        width: double.infinity,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
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
                                },
                              ),
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
                                  bottom: 20,
                                  right: 20,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailChat(
                                            idTernak: dataList[index]['uid'],
                                            kategori: dataList[index]
                                            ['kategori'],
                                            dataTernak: data,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                        width: 60,
                                        child: Image.asset(
                                            "assets/icon_chat2.png")),
                                  ))
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Stack(
                          children: [
                        ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            child: Center(child: CircularProgressIndicator(),),
                          )
                      ),
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
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }
            if (snapshot.hasData) {
              return  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 100,
                        child: Lottie.asset("assets/lottie/empty.json")),
                    Text("Kosong",style: TextStyle(color: Colors.white,fontSize: 18),),
                  ],
                ),
              );
            }
            return  Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
