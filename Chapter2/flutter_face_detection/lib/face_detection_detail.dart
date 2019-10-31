// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:async';
// import 'package:mlkit/mlkit.dart';

// class FaceDetectorDetail extends StatefulWidget {

//   final File _file;
//   FaceDetectorDetail(this._file);

//   @override
//   State<StatefulWidget> createState() {
//     return _FaceDetectorDetailState();
//   }
// }

// class _FaceDetectorDetailState extends State<FaceDetectorDetail> {

// //  List<Face> _currentFaceLabels = <Face>[];
// //  Stream sub;
// //  StreamSubscription<dynamic> subscription;

//   FirebaseVisionFaceDetector faceDetector = FirebaseVisionFaceDetector.instance;
//   List<VisionFace> _currentFaceLabels = <VisionFace>[];
//   Stream sub;
//   StreamSubscription<dynamic> subscription;

// //void analyse() {
// //  final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(widget._file.path);
// //  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
// //  final List<Face> faces = faceDetector.processImage(visionImage) as List<Face>;
// //
// //_currentFaceLabels = faces;
// //}

//   @override
//   void initState() {
//     super.initState();
//     sub = new Stream.empty();
//     subscription = sub.listen((_) => _getImageSize)..onDone(analyzeLabels);
//   }

//   void analyzeLabels() async {
//     try {
//       var currentLabels;
//       currentLabels = await faceDetector.detectFromPath(widget._file.path);
//       if (this.mounted) {
//         setState(() {
//           _currentFaceLabels = currentLabels;
//         });
//       }
//     } catch (e) {
//       print("MyEx: " + e.toString());
//     }
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     subscription?.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text("Face Detector"),
//         ),
//         body: Column(
//           children: <Widget>[
//             buildImage(context),
//             faceDetectList(_currentFaceLabels)
//           ],
//         ));
//   }

//   Widget buildImage(BuildContext context) {
//     return Expanded(
//       flex: 1,
//       child: Container(
//           decoration: BoxDecoration(color: Colors.black),
//           child: Center(
//             child: widget._file == null
//                 ? Text('No Image')
//                 : FutureBuilder<Size>(
//               future: _getImageSize(
//                   Image.file(widget._file, fit: BoxFit.fitWidth)),
//               builder:
//                   (BuildContext context, AsyncSnapshot<Size> snapshot) {
//                 if (snapshot.hasData) {
//                   return Container(
//                       foregroundDecoration: FaceDetectDecoration(
//                           _currentFaceLabels, snapshot.data),
//                       child:
//                       Image.file(widget._file, fit: BoxFit.fitWidth));
//                 } else {
//                   return CircularProgressIndicator();
//                 }
//               },
//             ),
//           )
//       ),
//     );
//   }


//   Widget _buildTextRow(text) {
//     return ListTile(
//       title: Text(
//         "$text",
//       ),
//       dense: true,
//     );
//   }

//   Widget faceDetectList<T>(List<T> labels) {
//     if (labels != null) {
//       if (labels.length == 0) {
//         return Expanded(
//           flex: 1,
//           child: Center(
//             child: Text('Nothing detected'),
//           ),
//         );
//       }
//       return Expanded(
//         flex: 1,
//         child: Container(
//           child: ListView.builder(
//               padding: const EdgeInsets.all(1.0),
//               itemCount: labels != null ? labels.length : 0,
//               itemBuilder: (context, i) {
//                 var text;
//                 final barcode = labels[i];
//                 VisionFace res = barcode as VisionFace;
//                 text = "Raw Value for face ${i}: Smiling Probablity: ${res.smilingProbability} with tracking id ${res.trackingID}";
//                 return _buildTextRow(text);
//               }),
//         ),
//       );
//     }
//   }


//   Future<Size> _getImageSize(Image image) {
//     Completer<Size> completer = Completer<Size>();
//     image.image.resolve(ImageConfiguration()).addListener(
//             (ImageInfo info, bool _) => completer.complete(
//             Size(info.image.width.toDouble(), info.image.height.toDouble())));
//     return completer.future;
//   }
// }

// class FaceDetectDecoration extends Decoration {
//   final Size _originalImageSize;
//   final List<VisionFace> _faces;
//   FaceDetectDecoration(List<VisionFace> faces, Size originalImageSize)
//       : _faces = faces,
//         _originalImageSize = originalImageSize;

//   @override
//   BoxPainter createBoxPainter([VoidCallback onChanged]) {
//     return _FaceDetectPainter(_faces, _originalImageSize);
//   }
// }

// class _FaceDetectPainter extends BoxPainter {
//   final List<VisionFace> _faces;
//   final Size _originalImageSize;
//   _FaceDetectPainter(faces, originalImageSize)
//       : _faces = faces,
//         _originalImageSize = originalImageSize;

//   @override
//   void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
//     final paint = Paint()
//       ..strokeWidth = 2.0
//       ..color = Colors.red
//       ..style = PaintingStyle.stroke;

//     final _heightRatio = _originalImageSize.height / configuration.size.height;
//     final _widthRatio = _originalImageSize.width / configuration.size.width;
//     for (var face in _faces) {
//       final _rect = Rect.fromLTRB(
//           offset.dx + face.rect.left / _widthRatio,
//           offset.dy + face.rect.top / _heightRatio,
//           offset.dx + face.rect.right / _widthRatio,
//           offset.dy + face.rect.bottom / _heightRatio);
//       canvas.drawRect(_rect, paint);
//     }
//     canvas.restore();
//   }
// }