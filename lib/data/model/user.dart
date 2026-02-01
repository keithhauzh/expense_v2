class User {
	final String? uid;
	final String? email;
  final String? username;

  User({
		this.uid,
		this.email,
		this.username
  });

  User copy({
    String? uid,
		String? email,
    String? username,
  }){
    return User(
      uid: uid ?? this.uid,
			email: email ?? this.uid,
      username: username ?? this.username,
    );
  }

  Map<String, dynamic> toMap() {
    return {
			"uid": uid,
			"email": email,
      "username": username
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
			uid: map["uid"] ?? "",
			email: map["email"] ?? "",
      username: map["username"] ?? ""
    );
  }

  @override
  String toString() {
    return "Category($uid, $email, $username)";
  }
}
