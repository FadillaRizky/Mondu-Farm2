import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mondu_farm/demo_page.dart';
import 'package:mondu_farm/login_page.dart';
import 'package:mondu_farm/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class DemoPage2 extends StatefulWidget {
  const DemoPage2({Key? key}) : super(key: key);

  @override
  State<DemoPage2> createState() => _DemoPage2State();
}

class _DemoPage2State extends State<DemoPage2> {
  // late VideoPlayerController _controller;
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;
  late VideoPlayerController _controller4;
  late VideoPlayerController _controller5;
  late List<VideoPlayerController> videoController = [
    _controller1,
    _controller2,
    _controller3,
    _controller4,
    _controller5
  ];

  late Future<void> _initializeVideoPlayerFuture1;
  late Future<void> _initializeVideoPlayerFuture2;
  late Future<void> _initializeVideoPlayerFuture3;
  late Future<void> _initializeVideoPlayerFuture4;
  late Future<void> _initializeVideoPlayerFuture5;
  late List<Future<void>> initVideo = [
    _initializeVideoPlayerFuture1,
    _initializeVideoPlayerFuture2,
    _initializeVideoPlayerFuture3,
    _initializeVideoPlayerFuture4,
    _initializeVideoPlayerFuture5
  ];

  List<String> url = [
    "assets/tutorial_cek_ternak.mp4",
    "assets/tutorial_booking.mp4",
    "assets/tutorial_negosiasi.mp4",
    "assets/tutorial_nota_belum_terbit.mp4",
    "assets/tutorial_nota_terbit.mp4",
  ];
  bool isVideoComplete = false;

  final FlutterTts flutterTts = FlutterTts();
  Future<void> playVoiceover(String text) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _controller1 = VideoPlayerController.asset('assets/tutorial_cek_ternak.mp4');
    _controller2 = VideoPlayerController.asset('assets/tutorial_booking.mp4');
    _controller3 = VideoPlayerController.asset('assets/tutorial_negosiasi.mp4');
    _controller4 = VideoPlayerController.asset('assets/tutorial_nota_belum_terbit.mp4');
    _controller5 = VideoPlayerController.asset('assets/tutorial_nota_terbit.mp4');
    _initializeVideoPlayerFuture1 = _controller1.initialize();
    _initializeVideoPlayerFuture2 = _controller2.initialize();
    _initializeVideoPlayerFuture3 = _controller3.initialize();
    _initializeVideoPlayerFuture4 = _controller4.initialize();
    _initializeVideoPlayerFuture5 = _controller5.initialize();
    playVoiceover(" Itaya ye nda video tutorial  cara patangar mbada dang kei mbada");

    // _controller1.addListener(() {
    //   if (_controller1.value.position == _controller1.value.duration) {
    //     setState(() {
    //       isVideoComplete = true;
    //     });
    //   }
    // });

    // _controller = VideoPlayerController.asset("assets/video_sample.mp4")
    //   ..initialize().then((_) {
    //     setState(() {});
    //   });
  }

  // void playAgain() {
  //   _controller1.seekTo(Duration.zero);
  //   _controller1.play();
  //
  //   isVideoComplete = false;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    // print(_controller1);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black38,
        ),
        backgroundColor: Colors.black38,
        body: SafeArea(
          child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 15, // Spacing between columns
                    mainAxisSpacing: 15, // Spacing between rows
                  ),
                  itemCount: 5,
                  // Number of items
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: initVideo[index],
                      builder: (context,snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 100,
                                  child: AspectRatio(
                                    aspectRatio: 9 / 16,
                                    child: VideoPlayer(videoController[index]),
                                  ),
                                ),
                              ),
                              // _controller1.value.isPlaying
                              //     ? SizedBox()
                              //     :
                              Center(
                                child: IconButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty.all(
                                            Warna.ungu)
                                    ),
                                    onPressed: () {
                                      // playAgain();
                                      // setState(() {
                                      //   isVideoComplete = false;
                                      // });
                                      Navigator.push(context, MaterialPageRoute(builder: (ctx)=>DemoPage(url: url[index])));
                                    },
                                    icon: Icon(
                                      Icons.play_arrow,
                                      size: 50,
                                      color: Colors.white,
                                    )),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }});
                  },
                )
        ),
        // floatingActionButton: isVideoComplete
        //     ? FloatingActionButton(
        //         backgroundColor: Warna.ungu,
        //         onPressed: () async {
        //           SharedPreferences prefs =
        //               await SharedPreferences.getInstance();
        //           prefs.setBool("firstTime", true);
        //           Navigator.pushAndRemoveUntil(
        //             context,
        //             MaterialPageRoute(builder: (ctx) => LoginPage()),
        //             (route) => false,
        //           );
        //         },
        //         child: Icon(
        //           Icons.arrow_forward_ios,
        //           color: Colors.white,
        //         ),
        //       )
        //     : FloatingActionButton(
        //         backgroundColor: Warna.ungu,
        //         onPressed: () {
        //           setState(() {
        //             _controller.value.isPlaying
        //                 ? _controller.pause()
        //                 : _controller.play();
        //           });
        //         },
        //         child: Icon(
        //           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //           color: Colors.white,
        //         ),
        //       )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
  }
}
