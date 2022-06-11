// ignore_for_file: unused_local_variable, avoid_print

import 'package:http/http.dart' as http;
import 'package:lapak/models/cart_model.dart';
import 'package:lapak/models/diskon_model.dart';
import 'package:lapak/models/kategori_model.dart';
import 'package:lapak/models/list_chat_model.dart';
import 'package:lapak/models/notif_model.dart';
import 'package:lapak/models/pesanan_model.dart';
import 'package:lapak/models/profile_model.dart';
import 'package:lapak/models/rekomendasi_model.dart';
import 'package:lapak/models/search_model.dart';
import 'package:lapak/models/store_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "https://lapak-backend-uas.herokuapp.com";
Map<String, String> headers = {
  "Content-Type": "application/json",
  "Authorization": ""
};

class ApiService {

  Future getDiskon(String order) async {
    Uri url = Uri.parse("$baseUrl/barang/diskon-30?orderBy=$order");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return diskonFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }
  Future getNotification() async {
    Uri url = Uri.parse("$baseUrl/checkout/notif");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return notificationFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }
  Future getListChat() async {
    Uri url = Uri.parse("$baseUrl/chat/list-chat");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return listChatFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }

  Future getPesanan() async {
    Uri url = Uri.parse("$baseUrl/checkout/get");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return pesananFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }

  Future getStoreInfo(int id) async {
    Uri url = Uri.parse("$baseUrl/store/info/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return storeFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }

  Future getCart() async {
    Uri url = Uri.parse("$baseUrl/cart/get");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return cartFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }

  Future getProfileChat(int id) async {
    Uri url = Uri.parse("$baseUrl/user/profile-chat/$id");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return profileFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }

  Future getProfile() async {
    Uri url = Uri.parse("$baseUrl/user/profile");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return profileFromJson(res.body);
    } else {
      print(res.statusCode);
    }
  }

  Future search(String item, String orderBy) async {
    Uri url = Uri.parse("$baseUrl/barang/search?item=$item&orderBy=$orderBy");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return searchFromJson(res.body);
    } else {
      print(res.statusCode);
      return print("gagal");
    }
  }

  Future getKategori(String cat, String order) async {
    Uri url = Uri.parse("$baseUrl/barang/kategori?cat=$cat&orderBy=$order");
    SharedPreferences storage = await SharedPreferences.getInstance();
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return kategoriFromJson(res.body);
    } else {
      print(res.statusCode);
      return print("gagal");
    }
  }

  Future getRekomendasi() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    Uri url = Uri.parse("$baseUrl/barang/rekomendasi");
    headers["Authorization"] = "Bearer ${storage.getString("token")}";
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      return rekomendasiFromJson(res.body);
    } else {
      print(res.statusCode);
      print(res.body);
    }
  }
}
