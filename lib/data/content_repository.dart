import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:test_rendering/models/content.dart';

class ContentRepository {
  Future<List<Content>> fetchContents() async {
    final String response =
        await rootBundle.loadString('assets/data/content.json');
    final List<dynamic> data = json.decode(response);

    return data.map((item) => Content.fromJson(item)).toList();
  }
}
