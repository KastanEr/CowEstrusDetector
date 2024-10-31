import 'package:estrus_detector/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  State<MyRegisterPage> createState() => _MyRegisterPageState();
}

class _MyRegisterPageState extends State<MyRegisterPage> {
  final idTextEditingController = TextEditingController();
  final pwTextEditingController = TextEditingController();
  final pwCheckTextEditingController = TextEditingController();

  @override
  void dispose() {
    idTextEditingController.dispose();
    pwTextEditingController.dispose();
    pwCheckTextEditingController.dispose();
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

  Future<void> register(
      BuildContext context, String username, String password) async {
    await ApiService.createUser(username, password)
        ? showPopUp(context, "회원가입에 성공했습니다.", true)
        : showPopUp(context, "이미 존재하는 ID입니다.\n다른 ID를 사용해주세요.", false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xffd6d6d6),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: Text(
                  "회원가입",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 50,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    "회원가입에 사용할 아이디와 비밀번호를 입력해주세요",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
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
                child: TextField(
                  controller: pwCheckTextEditingController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "비밀번호 확인"),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    String id = idTextEditingController.text;
                    String password = pwTextEditingController.text;
                    String passwordCheck = pwCheckTextEditingController.text;

                    (id == '' || password == '' || passwordCheck == '')
                        ? showPopUp(context, "아이디, 비밀번호 칸을\n모두 채워주세요.", false)
                        : ((password == passwordCheck)
                            ? register(context, id, password)
                            : showPopUp(
                                context, "비밀번호가 불일치합니다.\n다시 확인해주세요.", false));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    "가입하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
