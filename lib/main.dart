import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:counter_mmkv/counter_interaction.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path_provider_foundation/path_provider_foundation.dart';

const String counterIterationKey = 'counter_interactions';
const String appGroupId = 'group.com.josecollazzi.counter_mmkv_g';

@pragma("vm:entry-point")
Future<void> interactiveCallback(Uri? data) async {
  WidgetsFlutterBinding.ensureInitialized();

  final rootDir = await initializeMMKV();
  await HomeWidget.setAppGroupId(appGroupId);
  if (data?.host == 'increment_counter' || true) {
    debugPrint("increment_counter");
    var mmkv = await getMMKV();
    final jsonString = mmkv.decodeString(counterIterationKey);
    List<CounterInteraction> interactions = [];

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      interactions = jsonList.map((item) => CounterInteraction.fromJson(item)).toList();
    }

    int counterValue = 0;
    if (interactions.isNotEmpty) {
      counterValue = interactions.last.counterValue + 1;
    }

    final newCounterInteraction = CounterInteraction(
        counterValue: counterValue,
        interactionButtonLocation: PartOfTheApp.androidKotlinHomeWidget,
        persistedLogicLocation: PartOfTheApp.flutterCode);

    List<CounterInteraction> newList = [...interactions, newCounterInteraction];

    final counterSerialised = json.encode(newList.map((item) => item.toJson()).toList());
    mmkv.encodeString(counterIterationKey, counterSerialised);

    await updateWidget();
    // update main activity
    final sendPort = IsolateNameServer.lookupPortByName('background_isolate');
    sendPort?.send('update_widget');
  }
}

Future<MMKV> getMMKV() async {
    return MMKV("counter_storage",
        rootDir: (Platform.isIOS)? await pathDir(): null,
        mode: MMKVMode.MULTI_PROCESS_MODE);
}


Future<void> updateWidget() async {
  if (Platform.isIOS) {
    await HomeWidget.updateWidget(
        name: "CounterWidget",
        iOSName: "CounterWidget"
    );
  } else if (Platform.isAndroid) {
    await HomeWidget.updateWidget(
        qualifiedAndroidName: 'com.josecollazzi.counter_mmkv.CounterAppWidget',
    );
  }
}

Future<String?>  pathDir() async {
  final PathProviderFoundation provider = PathProviderFoundation();

  final sharedDirectory = await provider.getContainerPath(
    appGroupIdentifier: appGroupId,
  );

  return  sharedDirectory ?? "";
}


Future<String?> initializeMMKV() async {
  try {
    final groupDir = await MMKV.initialize(groupDir: await pathDir(),);

    print('MMKV initialized successfully. Shared directory: $groupDir');
    return groupDir;
  } catch (e) {
    print('Error initializing MMKV: $e');
    return null;
  }

}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final rootDir = await initializeMMKV();
  print('MMKV for flutter with rootDir = $rootDir');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CounterInteraction> _counter = [];
  late MMKV mmkv;

  Future<void> initialize() async {
    mmkv = await getMMKV();
    _loadCounterInteractions();
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'background_isolate');

    receivePort.listen((message) {
      if (message == 'update_widget') {
        _loadCounterInteractions();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
    HomeWidget.registerInteractivityCallback(interactiveCallback);
    initialize();
  }

  void _loadCounterInteractions() {
    final jsonString = mmkv.decodeString(counterIterationKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _counter = jsonList.map((item) => CounterInteraction.fromJson(item)).toList();
      setState(() {

      });
    }
  }


  void _saveCounterInteractions(List<CounterInteraction> interactions) async {
    final jsonString = json.encode(interactions.map((item) => item.toJson()).toList());
    mmkv.encodeString(counterIterationKey, jsonString);

    // Add a small delay to ensure sync completes
    await Future.delayed(const Duration(milliseconds: 100));

    await updateWidget();
  }

  void _incrementCounter() {
    int counterValue = 0;
    if (_counter.isNotEmpty) {
        counterValue = _counter.last.counterValue + 1;
    }

    final newCounterInteraction = CounterInteraction(
        counterValue: counterValue,
        interactionButtonLocation: PartOfTheApp.flutterCode,
        persistedLogicLocation: PartOfTheApp.flutterCode);

    List<CounterInteraction> newList = [..._counter, newCounterInteraction];
    _saveCounterInteractions(newList);

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = newList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              (_counter.isNotEmpty)? _counter.last.counterValue.toString():'',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              (_counter.isNotEmpty)? "Interaction Button Location: ${_counter.last.interactionButtonLocation.name}":'',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              (_counter.isNotEmpty)? "Persisting Logic Location: ${_counter.last.persistedLogicLocation.name}":'',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
