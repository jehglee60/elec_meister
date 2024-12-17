import 'dart:convert';
<<<<<<< HEAD
import 'package:flutter/services.dart';
=======
import 'package:flutter/services.dart' show rootBundle;
>>>>>>> ea3f20d43a1173665ae99c2c07cc4b9090628888
import 'package:test_rendering/models/content.dart';

class ContentRepository {
  Future<List<Content>> fetchContents() async {
    final String response =
        await rootBundle.loadString('assets/data/content.json');
    final List<dynamic> data = json.decode(response);
<<<<<<< HEAD
    return data.map((json) => Content.fromJson(json)).toList();
=======

    return data.map((item) => Content.fromJson(item)).toList();
>>>>>>> ea3f20d43a1173665ae99c2c07cc4b9090628888
  }
}
