import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:mondu_farm/views/home.dart';
import 'package:mondu_farm/utils/color.dart';

class Success extends StatelessWidget {
   Success({Key? key}) : super(key: key);
  final FlutterTts flutterTts = FlutterTts();

  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);

    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    playVoiceover("napa pesanmu talanga proses ndanya");
    return Scaffold(
      backgroundColor: Warna.latar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie/success.json"),
            SizedBox(height: 20,),
            IconButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Warna.secondary)),
                padding: EdgeInsets.all(20),
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => Home()));
                }, icon: Icon(Icons.home,color: Colors.white,size: 70,))
          ],
        ),
      ),
    );
  }
}
