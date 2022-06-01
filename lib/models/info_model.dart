class Info {
  String name;
  String alamat;
  String? photoProfile;
  Info({required this.name, required this.alamat, this.photoProfile});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
        name: json["name"],
        alamat: json["alamat"],
        photoProfile: json["photo_profile"]);
  }

  Map<String, dynamic> toJson() =>
      {"name": name, "alamat": alamat, "photo_profile": photoProfile};
}
