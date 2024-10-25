import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  State<MyRegisterPage> createState() => _MyRegisterPageState();
}

class User<T> {
  final T id;
  final T pw;

  User(this.id, this.pw);
}

class _MyRegisterPageState extends State<MyRegisterPage> {
  List<User<String>> db = []; //임시 DB 역할
  String id = '';
  String password = '';

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

  void register(BuildContext context) {
    db.add(User(id, password)); //db에 저장
    showPopUp(context, "회원가입에 성공했습니다.", true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Text(
                  "회원가입에 사용할 아이디와 비밀번호를 입력해주세요",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
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
                child: ElevatedButton(
                  onPressed: () {
                    id = idTextEditingController.text;
                    password = pwTextEditingController.text;

                    (id == '' || password == '')
                        ? showPopUp(
                            context, "회원가입에 실패했습니다.\n아이디나 비밀번호를 입력해주세요.", false)
                        : register(context);
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
