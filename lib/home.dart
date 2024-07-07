// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:new_app/data/models/character_model.dart';
import 'package:new_app/data/repository/character_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CharacterRepository _characterRepository = CharacterRepository();
  List<Character> characters = [];
  List<Character> filteredCharacters = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCharacters();
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
                icon: const Icon(Icons.filter_list),
                onPressed: fetchCharacters,
              ),
            ],
          ),
        ),
      ),
      body: characters.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : filteredCharacters.isEmpty
              ? Center(
                  child: Text('This person does not exist'),
                )
              : RefreshIndicator(
                  onRefresh: fetchCharacters,
                  child: ListView.builder(
                    itemCount: filteredCharacters.length,
                    itemBuilder: (ctx, index) {
                      final character = filteredCharacters[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(character.imageUrl),
                        ),
                        tileColor: index % 2 == 0
                            ? const Color.fromARGB(255, 210, 231, 249)
                            : const Color.fromARGB(255, 212, 235, 213),
                        title: Text(character.name),
                        subtitle: Text(character.species),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> fetchCharacters() async {
    try {
      final fetchedCharacters = await _characterRepository.fetchCharacters();
      setState(() {
        characters = fetchedCharacters;
        filterCharacters(_searchController.text.toLowerCase());
      });
    } catch (e) {
      // Handle errors
      print('Error fetching characters: $e');
    }
  }

  void filterCharacters(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCharacters = characters;
      } else {
        filteredCharacters = characters.where((character) {
          final name = character.name.toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }
}
