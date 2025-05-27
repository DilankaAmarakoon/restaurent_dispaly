import 'package:advertising_screen/home_screen.dart';
import 'package:advertising_screen/models/tv_view_model.dart';
import 'package:advertising_screen/reusableWidget/form_text_field.dart';
import 'package:advertising_screen/reusableWidget/showDialog.dart';
import 'package:advertising_screen/reusableWidget/tab_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

class LogingForm extends StatefulWidget {
  const LogingForm({super.key});

  @override
  State<LogingForm> createState() => _LogingFormState();
}

class _LogingFormState extends State<LogingForm> {
  TextEditingController url = TextEditingController();
  TextEditingController dbName = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController deviceId = TextEditingController();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();

  int uId = -1;

  TvViewModelsData modelData = TvViewModelsData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // Light background
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100, maxHeight: 600),
              child: IntrinsicHeight(
                child: Center(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.3,
                    constraints: const BoxConstraints(
                      maxWidth: 500, // Limit max width for readability
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 4,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      autofocus: true,
                      onKey: (RawKeyEvent event) {
                        if (event is RawKeyDownEvent) {
                          if (event.logicalKey ==
                              LogicalKeyboardKey.arrowDown) {
                            _handleArrowDown();
                          } else
                          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                            _handleArrowUp();
                          }
                        }
                      },
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/fgf.png', height: 100),
                            Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            FocusTraversalOrder(
                              order: NumericFocusOrder(1),
                              child: SizedBox(
                                height: 45,
                                child: FormTextField(
                                  focusNode: focusNode1,
                                  controller: url,
                                  lable: "Enter URL",
                                  type: FormTextFieldType.text,
                                ),
                              ),
                            ),
                            FocusTraversalOrder(
                              order: NumericFocusOrder(2),
                              child: SizedBox(
                                height: 45,
                                child: FormTextField(
                                  focusNode: focusNode2,
                                  controller: dbName,
                                  lable: "Enter Database",
                                  type: FormTextFieldType.text,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 45,
                              child: FormTextField(
                                focusNode: focusNode3,
                                controller: userName,
                                lable: "Enter Username",
                                type: FormTextFieldType.text,
                              ),
                            ),
                            SizedBox(
                              height: 45,
                              child: FormTextField(
                                focusNode: focusNode4,
                                controller: password,
                                lable: "Enter Password",
                                type: FormTextFieldType.password,
                              ),
                            ),
                            SizedBox(
                              height: 45,
                              child: FormTextField(
                                focusNode: focusNode5,
                                controller: deviceId,
                                lable: "Enter Device ID",
                                type: FormTextFieldType.text,
                              ),
                            ),
                            TapButton(
                              lable: "Sign In",
                              btnColor: const Color(0xFF6A1B9A),
                              fontSize: 18,
                              width: 50,
                              height: 40,
                              onPressed: () async {
                                if (await checkUserAuthenticationValidate()) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                    );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

    );
  }

  void _handleArrowDown() {
    if (focusNode1.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode2);
    } else if (focusNode2.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode3);
    }
  }

  void _handleArrowUp() {
    if (focusNode3.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode2);
    } else if (focusNode2.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }

  Future<int> fetchUserId(String url, String dbName, String userName,
      String password) async {
    try {
      final userId = await xml_rpc.call(
        Uri.parse('https://$url/xmlrpc/2/common'),
        'login',
        [dbName, userName, password],
      );
      print("vvbbnn..$userId");
      if (userId != false) {
        return userId;
      } else {
        return -1;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<bool> checkUserAuthenticationValidate() async {
    if (url.text
        .trim()
        .isEmpty || password.text
        .trim()
        .isEmpty || userName.text
        .trim()
        .isEmpty || dbName.text
        .trim()
        .isEmpty || deviceId.text
        .trim()
        .isEmpty) {
      ShowDialog(context,
          "Please ensure all required fields are completed before proceeding !");
      return false;
    }
    uId = await fetchUserId(
        url.text.trim(), dbName.text.trim(), userName.text.trim(),
        password.text.trim());
    if (uId != -1) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('uId', uId);
      await prefs.setString('url', url.text.trim());
      await prefs.setString('dbName', dbName.text.trim());
      await prefs.setString('password', password.text.trim());
      await prefs.setString('device_Id', deviceId.text.trim());

      List<dynamic> list = await modelData.productLineData(
          deviceId.text,
          url.text.trim(),
          dbName.text.trim(),
          password.text.trim(),
          uId,
          true
      );
      if (list.isEmpty) {
        ShowDialog(context,
            "No data found for the provided Device ID. Please verify the entered fields and try again !");
        return false;
      } else {
        return true;
      }
    } else {
      ShowDialog(context,
          "No data found for the provided Device ID. Please verify the entered fields and try again !");
      return false;
    }
  }
}
