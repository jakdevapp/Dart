import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tace_nowait/pages/profileform.dart';

class PhotoDraw extends StatefulWidget {
  final File selectedFile;
  PhotoDraw(this.selectedFile);

  @override
  _PhotoDrawState createState() => _PhotoDrawState();
}

class _PhotoDrawState extends State<PhotoDraw> {
  GlobalKey signatureKey = GlobalKey();
  File drawFile;

  static final Color color = Colors.red;
  static final double strokeWidth = 5.0;
  static final double lineWidths = 5.0;
  List points = [Point(color, lineWidths, [])];
  int curFrame = 0;
  bool isClear = false;
  SignaturePainter signaturePainter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    signaturePainter = SignaturePainter(
        points: points,
        strokeColor: color,
        strokeWidth: strokeWidth,
        isClear: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Signature Photo'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                reset();
                return showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Reset drawing',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).primaryColor,
                              letterSpacing: 1.1),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              }),
          IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () async {
                drawFile = await renderSavePhotoFile();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileForm(
                          File(widget.selectedFile.path), drawFile)),
                );
                print(widget.selectedFile.path);
                print(drawFile.path);
              })
        ],
      ),
      body: RepaintBoundary(
        key: signatureKey,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(image: FileImage(widget.selectedFile))),
          child: StatefulBuilder(builder: (context, state) {
            return CustomPaint(
              child: GestureDetector(
                onPanStart: (details) {
                  // before painting, set color & strokeWidth.
                  isClear = false;
                  points[curFrame].color = color;
                  points[curFrame].strokeWidth = strokeWidth;
                },
                onPanUpdate: (details) {
                  RenderBox referenceBox = context.findRenderObject();
                  Offset localPosition =
                      referenceBox.globalToLocal(details.globalPosition);
                  state(() {
                    points[curFrame].points.add(localPosition);
                  });
                },
                onPanEnd: (details) {
                  // preparing for next line painting.
                  points.add(Point(color, strokeWidth, []));
                  curFrame++;
                },
              ),
              painter: SignaturePainter(
                points: points,
                strokeColor: color,
                strokeWidth: strokeWidth,
                isClear: isClear,
              ),
            );
          }),
        ),
      ),
    );
  }

  void reset() {
    isClear = true;
    curFrame = 0;
    points.clear();
    points.add(Point(color, strokeWidth, []));
  }

  renderSavePhotoFile() async {
    //------- STEP 1 : RENDER PICTURE -------
    File file;
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    try {
      signaturePainter.paint(canvas, Size.infinite);
      ui.Picture p = recorder.endRecording();
      ui.Image image = await p.toImage(
          MediaQuery.of(context).size.width.toInt(),
          MediaQuery.of(context).size.height.toInt());

      RenderRepaintBoundary boundary =
          signatureKey.currentContext.findRenderObject();
      ui.Image image2 = await boundary.toImage();

      setState(() {
        image = image2;
      });

      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      //------- STEP 2 : SAVE RENDER PICTURE FILE -------
      var directory = await getExternalStorageDirectory();
      String path = directory.path;

      file = File("$path/${formattedDateTimeSignature()}.png");
      await file.writeAsBytes(byteData.buffer.asUint8List()).then((onValue) {});
    } catch (exception) {
      print(canvas.hashCode);
      print("Exception Thrown $exception");

      Fluttertoast.showToast(
          msg: "Something went wrong, try resubmitting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.blueGrey.shade500,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {});
    }
    return file;
  }

  String formattedDateTimeSignature() {
    DateTime dateTime = DateTime.now();
    final DateFormat df = DateFormat("ddMMyyyy_HHmmss");
    String dtFormat = df.format(dateTime);
    String dateTimeString = 'drawphoto_' + dtFormat;
    return dateTimeString;
  }
}

class Point {
  Color color;
  List points;
  double strokeWidth = 5.0;

  Point(this.color, this.strokeWidth, this.points);
}

class SignaturePainter extends CustomPainter {
  final double strokeWidth;
  final Color strokeColor;
  final bool isClear;
  final List points;
  Paint _linePaint;

  SignaturePainter({
    @required this.points,
    @required this.strokeColor,
    @required this.strokeWidth,
    this.isClear = true,
  }) {
    _linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
  }

  void paint(Canvas canvas, Size size) {
    if (isClear || points == null || points.length == 0) {
      return;
    }
    for (int i = 0; i < points.length; i++) {
      _linePaint..color = points[i].color;
      _linePaint..strokeWidth = points[i].strokeWidth;
      List curPoints = points[i].points;
      if (curPoints == null || curPoints.length == 0) {
        break;
      }
      for (int i = 0; i < curPoints.length - 1; i++) {
        if (curPoints[i] != null && curPoints[i + 1] != null)
          canvas.drawLine(curPoints[i], curPoints[i + 1], _linePaint);
      }
    }
  }

  bool shouldRepaint(SignaturePainter other) => true;
}
