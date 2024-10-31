class UserModel {
  final String username, id;

  UserModel({required this.username, required this.id});

  UserModel.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        id = json['id'];
}
