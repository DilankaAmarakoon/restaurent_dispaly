import 'package:advertising_screen/firbase_notification.dart';
import 'package:advertising_screen/restart_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
      RestartWidget(child: MyApp())
  );
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

 class _MyAppState extends State<MyApp> {

  bool isLoggedIn = false;
  @override
  void initState() {
    _checkUserAlreadyLoggedOrNot();
    NotificationServices().initialize(
        context
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advertisement Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  isLoggedIn ? HomeScreen() : LogingForm(),
    );
  }

  void _checkUserAlreadyLoggedOrNot() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? id = pref.getInt("uId");
    if (id != null && id > 0) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }
 }

