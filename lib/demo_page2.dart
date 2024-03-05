import 'package:flutter/material.dart';
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
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isVideoComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/howtologin.mp4');
    _initializeVideoPlayerFuture = _controller.initialize();

    // Add a listener to check when the video playback is complete
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          isVideoComplete = true;
        });
      }
    });
    // _controller = VideoPlayerController.asset("assets/video_sample.mp4")
    //   ..initialize().then((_) {
    //     setState(() {});
    //   });
  }
  void playAgain() {

    _controller.seekTo(Duration.zero);
    _controller.play();

    isVideoComplete = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_controller);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Warna.latar,
        ),
        backgroundColor: Warna.latar,
        body: SafeArea(
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 9/16,
                      child: VideoPlayer(_controller),
                    ),
                    _controller.value.isPlaying
                        ? SizedBox()
                        : Center(
                      child: IconButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Warna.ungu)),
                          onPressed: (){
                            playAgain();
                            // setState(() {
                            //   isVideoComplete = false;
                            // });
                          }, icon: Icon(Icons.play_arrow,size: 100,color: Colors.white,)),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        floatingActionButton:
        isVideoComplete
            ? FloatingActionButton(
          backgroundColor: Warna.ungu,
          onPressed: ()async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
             prefs.setBool("firstTime", true);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=>LoginPage()),(route) => false,);
          },
          child: Icon(Icons.arrow_forward_ios,color: Colors.white,),
        )
            : FloatingActionButton(
          backgroundColor: Warna.ungu,
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
