import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> characters = [];
  List<dynamic> filteredCharacters = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    double scrnwdth = MediaQuery.of(context).size.width;
    double scrnht = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(scrnht * 0.09),
        child: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: 0.8 * scrnwdth,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      filterCharacters(value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: 'Search the character',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  fetchUser();
                },
              ),
            ],
          ),
        ),
      ),
      body: characters.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: filteredCharacters.length,
              itemBuilder: (ctx, index) {
                final character = filteredCharacters[index];
                final name = character['name'];
                final imageUrl = character['image'];
                final species = character['species'];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl),
                  ),
                  tileColor: index % 2 == 0
                      ? const Color.fromARGB(255, 210, 231, 249)
                      : const Color.fromARGB(255, 212, 235, 213),
                  title: Text(name),
                  subtitle: Text(species),
                );
              },
            ),
    );
  }

  void fetchUser() async {
    const String url = 'https://rickandmortyapi.com/api/character';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      setState(() {
        characters = json['results'];
        filteredCharacters = characters; // Initialize with all characters
      });
    } else {
      print('Failed to fetch characters: ${response.statusCode}');
    }
  }

  void filterCharacters(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCharacters = characters;
      });
    } else {
      setState(() {
        filteredCharacters = characters.where((character) {
          final name = character['name'].toString().toLowerCase();
          return name.contains(query);
        }).toList();
      });
    }
  }
}
