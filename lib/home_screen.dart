import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var helloName;
  var output;
  String? element;
  String? ampValue;
  double ampValueNew = 0.00;

  late Client client;
  late Session session;


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


  @override
  void initState() {
    super.initState();
    connect();
  }


  @override
  Widget build(BuildContext context) {
    print("Element $ampValueNew ");
    // Future.delayed(const Duration(seconds: 5), () {
    //   setState(() {
    //     ampValueNew++;
    //   });
    // });
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            width: 250,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
            decoration: BoxDecoration(
              color: ampValueNew == 0.00
                  ? Colors.lightBlueAccent
                  : ampValueNew >= 1.00 && ampValueNew < 2.00
                  ? Colors.indigo
                  : ampValueNew >= 2.00 && ampValueNew < 3.00
                  ? Colors.orangeAccent
                  : ampValueNew >= 3.00 && ampValueNew < 4.00
                  ? Colors.orangeAccent
                  : ampValueNew >= 4.00 && ampValueNew < 5.00
                  ? Colors.deepOrange
                  : ampValueNew >= 5.00 ? Colors.red : Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(200),
            ),
            child: Text(
              output ?? "No data yet",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}