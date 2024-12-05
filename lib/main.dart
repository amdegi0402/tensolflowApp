import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'home.dart';

// グローバル変数は最小限に抑え、定数として定義
const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';  // テスト用広告ID

/// プラットフォームに応じた広告ユニットIDを取得
String getAdUnitId() {
  if (Platform.isIOS) {
    return testBannerId;  // 本番環境では実際のiOS用広告IDに置き換え
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-6617363713596381/2880950371';
  }
  throw UnsupportedError('Unsupported platform');
}

future<void> main() async {
  // Flutterバインディングの初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp();

  // モバイル広告SDKの初期化
  await MobileAds.instance.initialize();

  // 利用可能なカメラの取得
  List<CameraDescription> cameras;
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('カメラの初期化エラー: ${e.code}\nエラーメッセージ: ${e.message}');
    return;
  }

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '画像認識アプリ',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: MyHomePage(cameras: cameras),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MyHomePage({super.key, required this.cameras});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: getAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('広告の読み込みに失敗: ${error.message}');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // メインコンテンツ
          HomePage(widget.cameras),
          
          // 広告表示
          if (_isAdLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
