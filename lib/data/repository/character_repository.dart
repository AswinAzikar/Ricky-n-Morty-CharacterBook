// lib/data/repositories/character_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

class CharacterRepository {
  Future<List<Character>> fetchCharacters() async {
    const String url = 'https://rickandmortyapi.com/api/character';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      final List<dynamic> results = json['results'];
      return results.map((characterJson) {
        return Character(
          name: characterJson['name'],
          imageUrl: characterJson['image'],
          species: characterJson['species'],
          status: characterJson['status'],
          gender: characterJson['gender'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch characters');
    }
  }
}
