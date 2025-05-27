import 'dart:async';
import 'dart:io';
import 'package:advertising_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'models/tv_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TvViewModelsData modelsData = TvViewModelsData();
  Timer? timer;
  int currentImageIndex = 0;
  VideoPlayerController? _videoController;
  File? _tempVideoFile;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    timer?.cancel();
    _videoController?.dispose();
    _tempVideoFile?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (modelsData.imageDetailsDataList.isEmpty) {
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.hexagonDots(
            color: Colors.deepPurple,
            size: 50,
          ),
        ),
        floatingActionButton: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
          },
          onExit: (_) {
            setState(() => _isHovered = false);
          },
          child: AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: FloatingActionButton(
              onPressed: () {
                logOutBtnFn();
              },
              child: Icon(Icons.logout),
            ),
          ),
        ),
      );
    }

    final currentItem = modelsData.imageDetailsDataList[currentImageIndex];

    if (currentItem.type == MediaType.video &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return Scaffold(
        body: SizedBox(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
        ),
        floatingActionButton: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
          },
          onExit: (_) {
            setState(() => _isHovered = false);
          },
          child: AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: FloatingActionButton(
              onPressed: () {
                logOutBtnFn();
              },
              child: Icon(Icons.logout),
            ),
          ),
        ),
      );
    }
    if (currentItem.type == MediaType.image) {
      return Scaffold(
        body: RotatedBox(
          quarterTurns: 1,
          child: Scaffold(
            body: SizedBox.expand(
              child: Image.memory(
                currentItem.imageByte,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        floatingActionButton: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
          },
          onExit: (_) {
            setState(() => _isHovered = false);
          },
          child: AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: FloatingActionButton(
              onPressed: () {
                logOutBtnFn();
              },
              child: Icon(Icons.logout),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.hexagonDots(
          color: Colors.deepPurple,
          size: 50,
        ),
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
        },
        onExit: (_) {
          setState(() => _isHovered = false);
        },
        child: AnimatedOpacity(
          opacity: _isHovered ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: FloatingActionButton(
            onPressed: () {
              logOutBtnFn();
            },
            child: Icon(Icons.logout),
          ),
        ),
      ),
    );
  }

  Future<void> _startRotation() async {
    timer?.cancel();

    if (modelsData.imageDetailsDataList.isEmpty) return;

    final currentItem = modelsData.imageDetailsDataList[currentImageIndex];

    if (currentItem.type == MediaType.video) {
      _videoController?.dispose();
      print("ppoo...${currentItem.videoUrl}");
      _videoController = VideoPlayerController.networkUrl(currentItem.videoUrl)
           ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _videoController?.play();
          final duration = _videoController!.value.duration;
          timer = Timer(duration, () {
            if (!mounted) return;
            setState(() {
              currentImageIndex = (currentImageIndex + 1) % modelsData.imageDetailsDataList.length;
            });
            _startRotation();
          });
        });
    } else {
      final seconds = currentItem.duration.toInt();
      timer = Timer(Duration(seconds: seconds), () {
        if (!mounted) return;
        setState(() {
          currentImageIndex = (currentImageIndex + 1) % modelsData.imageDetailsDataList.length;
        });
        _startRotation();
      });
    }
  }

  Future<void> _run() async {
     await modelsData.fetchProductLineDetails();
    if (!mounted) return;
    setState(() {});
    _startRotation();
  }
  logOutBtnFn()async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.clear();
    setState(() {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogingForm()),
    );
  }
}
