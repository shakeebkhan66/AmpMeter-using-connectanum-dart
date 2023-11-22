import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'circle_painter_screen.dart';
import 'curved_wave_screen.dart';



class RipplesAnimation extends StatefulWidget {
  const RipplesAnimation({Key? key, this.size = 80.0, this.color,
     this.onPressed,  this.child,}) : super(key: key);
  final double size;
  final Color? color;
  final Widget? child;
  final VoidCallback? onPressed;
  @override
  _RipplesAnimationState createState() => _RipplesAnimationState();
}

class _RipplesAnimationState extends State<RipplesAnimation> with TickerProviderStateMixin {
  AnimationController? _controller;

  var helloName;
  var output;
  String? element;
  String? ampValue;
  double ampValueNew = 0.00;

  late Client client;
  late Session session;



  @override
  void initState() {
    super.initState();
    connect();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  // TODO Connect Method
  Future<void> connect() async {
    client = Client(
        realm: 'realm1',
        transport: WebSocketTransport(
          'ws://157.175.150.140:8081/ws',
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));

    session = await client
        .connect(
      options: ClientConnectOptions(
        reconnectCount: 10,
        reconnectTime: const Duration(milliseconds: 200),
      ),
    )
        .first;

    subscribeMethod();
  }

  // TODO Subscribe Method
  Future<void> subscribeMethod() async {
    final subscription = await session.subscribe("io.xconn.monitor.amp");
    print("Subs $subscription");
    subscription.eventStream!.listen((event) {
      print(event.arguments![0]);

      setState(() {
        helloName = event.arguments!;
        print("Hello Name ${helloName[0]}");
        print(helloName.runtimeType);

        for (String element in helloName) {
          if (element.length >= 10) { // Ensure the element is long enough to have characters at indices 6 to 9
            ampValue = extractAmpValue(element.substring(6, 10));
            print("Amp Value: $ampValue");
            if (ampValue != null) {
              ampValueNew = double.parse(ampValue!);
              print("Element $ampValueNew ");
              print(ampValueNew.runtimeType);
            }
          } else {
            print("Element is too short to extract the desired range");
          }
        }
        output = helloName.join(' ');
        print("New $output");
      });
    });
    await subscription.onRevoke.then((reason) =>
        print('The server has killed my subscription due to: $reason'));
  }

  String extractAmpValue(element) {
    print("String $element");
    List<String> parts = element.split(" ");
    String ampPart = parts.firstWhere((part) => part.contains("Amp:"), orElse: () => "Amp: 0.00");
    String ampValue = ampPart.split(":")[1].trim();
    print("Amp $ampValue");

    return element;
  }


  // TODO TO SHOW DATA IN CONTAINER
  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller!,
                curve: const CurveWave(),
              ),
            ),
            child: Text(output ?? "No data yet",  style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Element $ampValueNew ");
    return Scaffold(
      backgroundColor: ampValueNew == 0.00
          ? Colors.lightBlueAccent.shade100
          : ampValueNew >= 1.00 && ampValueNew < 2.00
          ? Colors.indigo.shade100
          : ampValueNew >= 2.00 && ampValueNew < 3.00
          ? Colors.green.shade100
          : ampValueNew >= 3.00 && ampValueNew < 4.00
          ? Colors.orangeAccent.shade100
          : ampValueNew >= 4.00 && ampValueNew < 5.00
          ? Colors.deepOrange.shade100
          : ampValueNew >= 5.00 ? Colors.red.shade100 : Colors.lightBlueAccent.shade100,
      body: Center(
        child: CustomPaint(
          painter: CirclePainter(
            _controller!,
            color: ampValueNew == 0.00
                ? Colors.lightBlueAccent
                : ampValueNew >= 1.00 && ampValueNew < 2.00
                ? Colors.indigo
                : ampValueNew >= 2.00 && ampValueNew < 3.00
                ? Colors.green
                : ampValueNew >= 3.00 && ampValueNew < 4.00
                ? Colors.orangeAccent
                : ampValueNew >= 4.00 && ampValueNew < 5.00
                ? Colors.deepOrange
                : ampValueNew >= 5.00 ? Colors.red : Colors.lightBlueAccent,
          ),
          child: SizedBox(
            width: widget.size * 4.125,
            height: widget.size * 4.125,
            child: _button(),
          ),
        ),
      ),
    );
  }
}


