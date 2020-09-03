/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //理由はわからないがこれを入れないとエラーになる

  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<MyApp> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }
}
*/

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home.dart';
import 'package:firebase_admob/firebase_admob.dart';
//import 'package:flutter/services.dart'; // 追加
//import 'package:admob_flutter/admob_flutter.dart';



String admob01 = BannerAd.testAdUnitId; //テスト用。本当はここに広告ユニットIDを設定
List<CameraDescription> cameras;

String getAppId() {
  if (Platform.isIOS) {
    return admob01;
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-6617363713596381/2880950371';
  }
  return null;
}


Future<Null> main() async{
  WidgetsFlutterBinding.ensureInitialized(); //理由はわからないがこれを入れないとエラーになる

  try{
    cameras = await availableCameras(); //使用可能なカメラリスト取得
  } on CameraException catch (e){
    print('Error: $e.code\n Error Message: $e.message');
  }
  //Admob.initialize(getAppId());
  runApp( MyApp());
}

class MyApp extends StatelessWidget{
  
   //admob広告表示のための初期設定
  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      '登山',
      'キャンプ',
      'ハイキング'
    ],
    contentUrl: 'http://自分のHPサイトURL',
    childDirected: false,
    testDevices: <String>[], 
  );
  BannerAd myBanner = BannerAd(
    adUnitId: admob01, //バナー広告のユニットID
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
  @override
  Widget build(BuildContext context){
    //admobのバナー広告表示
    myBanner
      ..load()
      ..show(
        anchorOffset: 0.0,
        anchorType: AnchorType.bottom,
      );
  
    return MaterialApp(
      title: 'カメラを対象に合わせてください',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(cameras),
    ); 
  }
}