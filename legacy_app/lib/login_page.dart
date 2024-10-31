import 'package:estrus_detector/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {

  final idTextEditingController = TextEditingController();
  final pwTextEditingController = TextEditingController();

  @override
  void dispose() {
    idTextEditingController.dispose();
    pwTextEditingController.dispose();
    super.dispose();
  }

  void showPopUp(BuildContext context, String msg, bool success) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  msg,
                  style: TextStyle(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: () {
                      success ? context.go('/') : context.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> login(BuildContext context, String username, String password) async {
    String token = await ApiService.getLoginToken(username, password);
    token!=''? context.go('/home', extra: token) : showPopUp(context, "로그인에 실패하였습니다.\n비밀번호를 확인해주세요.", false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xffd6d6d6),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: Text(
                  "소 승가 알리미",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 50,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: idTextEditingController,
                  decoration: InputDecoration(labelText: "아이디"),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: pwTextEditingController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "비밀번호"),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String id = idTextEditingController.text;
                        String password = pwTextEditingController.text;
                        (id == '' || password == '')
                            ? showPopUp(
                            context, "아이디, 비밀번호를 입력해주세요.", false)
                            : (await ApiService.existUser(id)
                            ? login(context, id, password)
                            : showPopUp(context,
                            "존재하지 않는 아이디입니다.\n회원가입을 해주세요.", false));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "로그인",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "회원가입",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
