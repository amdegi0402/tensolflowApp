import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

var now = List();
var sub = List();

int temp;
var map2 = Map();
var map1 = Map();
typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget{
  final List<CameraDescription> cameras;

  final Callback setRecognitions;
  final String model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera>{
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState(){
    super.initState();
    if(widget.cameras == null || widget.cameras.length < 1){
      print("No cameras is found");
    }else{
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );
      controller.initialize().then((_){
        if(!mounted){
          return;
        }
        setState((){});

        controller.startImageStream((CameraImage img){
          if(!isDetecting){
            isDetecting = true;

            int startTime = DateTime.now().millisecondsSinceEpoch;

            Tflite.runModelOnFrame(
              bytesList: img.planes.map((plane){
                return plane.bytes;
              }).toList(),

              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 127.5, //127.5
              imageStd: 127.5,
              numResults: 3,
              rotation: 0,
              threshold:0.1
            ).then((recognitions){
              recognitions.map((res){

              });

              print(recognitions);

              int endTime = DateTime.now().millisecondsSinceEpoch;
              print("Detection took ${endTime - startTime}");

              widget.setRecognitions(recognitions, img.height, img.width);

              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    if(controller == null || !controller.value.isInitialized){
      return Container();
    }

    var tmp = MediaQuery.of(context).size;

    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;

    return Container(
      child: CameraPreview(controller),
      constraints: BoxConstraints(
        maxHeight: 500, //default 500
        maxWidth: screenW,
      ),
    );
  }
}
