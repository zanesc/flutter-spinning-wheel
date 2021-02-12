import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';

void main() {
  //SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Color(0xffB0F9D2),
              child: InkWell(
                  child: Center(child: Text('B A S I C')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Basic()),
                    );
                  }),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xffDDC3FF),
              child: InkWell(
                  child: Center(child: Text('R O U L E T T E')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Roulette()),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationButton({String text, Function onPressedFn}) {
    return FlatButton(
      color: Color.fromRGBO(255, 255, 255, 0.3),
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      onPressed: onPressedFn,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }
}

class Basic extends StatelessWidget {
  final StreamController _dividerController = StreamController<int>();

  dispose() {
    _dividerController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xffB0F9D2), elevation: 0.0),
      backgroundColor: Color(0xffB0F9D2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinningWheel(
              backPanel: Image.asset('assets/images/wheel-6-300.png'),
              width: 310,
              height: 310,
              initialSpinAngle: _generateRandomAngle(),
              spinResistance: 0.2,
              dividers: 6,
              onUpdate: _dividerController.add,
              onEnd: _dividerController.add,
              labels: List.generate(
                6,
                (index) => Text(
                  "Items $index",
                  style: TextStyle(shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                    ),
                  ]),
                ),
              ),
            ),
            StreamBuilder(
              stream: _dividerController.stream,
              builder: (context, snapshot) => snapshot.hasData ? BasicScore(snapshot.data) : Container(),
            )
          ],
        ),
      ),
    );
  }

  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
}

class BasicScore extends StatelessWidget {
  final int selected;

  final Map<int, String> labels = {
    1: 'Purple',
    2: 'Magenta',
    3: 'Red',
    4: 'Dark Orange',
    5: 'Light Orange',
    6: 'Yellow',
  };

  BasicScore(this.selected);

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected]}', style: TextStyle(fontStyle: FontStyle.italic));
  }
}

class Roulette extends StatefulWidget {
  @override
  _RouletteState createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> {
  final StreamController<int> _dividerController = StreamController<int>();

  final _wheelNotifier = StreamController<double>();

  double _resistance = 0.001;

  dispose() {
    _dividerController.close();
    _wheelNotifier.close();
    super.dispose();
  }

  Widget _spanLine(int dev, Widget back) {
    return Stack(
      children: <Widget>[
        back,
        Container(
          width: 310,
          height: 310,
          child: CustomPaint(
            painter: Lines(dev, 3),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xffDDC3FF), elevation: 0.0),
      backgroundColor: Color(0xffDDC3FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinningWheel(
              backPanel: _spanLine(8, Image.asset('assets/images/roulette-8-300.png')),
              width: 310,
              height: 310,
              //initialSpinAngle: 0,//pi / 8, //_generateRandomAngle(),
              // initialSpinAngle: pi / 8, //_generateRandomAngle(),
               initialSpinAngle: _generateRandomAngle(),
              spinResistance: _resistance,
              canInteractWhileSpinning: false,
              canDragginWheel: true,
              dividers: 8,
              onUpdate: (index ){
                print( "onupdaet $index" );
                _dividerController.add(index);
                },
              onEnd: _dividerController.add,
              frontPanel: Container(
                  width: 40,
                  height: 40,
                  transform: Matrix4.translationValues(135, 135, 0),
                  child: Image.asset('assets/images/roulette-center-300.png')),
              shouldStartOrStop: _wheelNotifier.stream,
              labels: List.generate(
                8,
                (index) => Container(
                  // transform: Matrix4(1, 0, 0,
                  // -0.009, 0, 1, 0, 0.000, 0, 0, 1, 0, 0, 0, 0, 1),
                  child: Text(
                    "Items ${index + 1}",
                    style: TextStyle(shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            StreamBuilder(
                stream: _dividerController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (currentIndex == snapshot.data) {
                      _wheelNotifier.sink.add(0);
                    }
                    return RouletteScore(snapshot.data);
                  } else {
                    return Container();
                  }
                }),
            SizedBox(height: 30),
            new RaisedButton(
              child: new Text("Start"),
              onPressed: () {
                currentIndex = -1;
                _wheelNotifier.sink.add(5000);
              },
              //onPressed: () => _wheelNotifier.sink.add(_generateRandomVelocity()),
            ),
            new RaisedButton(
              child: new Text("Stop"),
              onPressed: () {
                //_resistance = 0.8;
                //_wheelNotifier.sink.add(100);
                //if( _dividerController.stream. )
                currentIndex = 2;
                //StepState.editing
                //setState(() {});
              },
              //onPressed: () => _wheelNotifier.sink.add(_generateRandomVelocity()),
            )
          ],
        ),
      ),
    );
  }

  int currentIndex = 0;

  double _generateRandomVelocity() => (Random().nextDouble() * 6000) + 2000;

  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
}

class RouletteScore extends StatelessWidget {
  final int selected;

  final Map<int, String> labels = {
    1: '1000\$',
    2: '400\$',
    3: '800\$',
    4: '7000\$',
    5: '5000\$',
    6: '300\$',
    7: '2000\$',
    8: '100\$',
  };

  RouletteScore(this.selected);

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected]}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 24.0));
  }
}

class Lines extends CustomPainter {
 final int divider;
  final double lineWidth;

  Paint _paint;
  Lines(this.divider, this.lineWidth);

  void _makePaint(Rect rect) {
    final shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
      Color.fromRGBO(190, 139, 69, 1),
      Color.fromRGBO(205, 167, 119, 1),
      Color.fromRGBO(232, 211, 175, 1),
      Color.fromRGBO(205, 167, 119, 1),
      Color.fromRGBO(190, 139, 69, 1),
    ]).createShader(rect);
    _paint = Paint()..shader = shader;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final halfWidth = lineWidth / 2;
    final halfW = size.width / 2;

    Rect rect = Rect.fromLTWH(-halfW, -halfWidth, size.width, 2 * halfWidth);
    // path.addArc(rect, 0, 2 * pi);
    // path.close();
    if (_paint == null) {
      _makePaint(rect);
    }

    //canvas.drawPath(path, paint);
    canvas.translate(size.width / 2, size.height / 2);
    //canvas.rotate(-pi / 2 + (pi / divider)); //- pi/2+ (2*pi/divider/2) //中間右邊邊線 簡化
    canvas.rotate(-pi / 2 ); //- pi/2+ (2*pi/divider/2) //中間右邊邊線 簡化

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawArc(rect, 0, 2 * pi, true, _paint);
    var lineCount = (divider).round();
    canvas.restore();

    for (var i = 0; i < lineCount; ++i) {
      canvas.save();
      canvas.rotate(2 * pi / lineCount * (i + 1));
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawArc(rect, 0, 2 * pi, true, _paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter painter) {
    return ((painter as Lines)?.divider ?? 0) != divider;
  }
}
