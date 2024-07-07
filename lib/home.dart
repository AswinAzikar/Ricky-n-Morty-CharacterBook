import 'package:flutter/material.dart';
import 'package:new_app/presentation/constants/constColors.dart';

import 'data/models/character_model.dart';
import 'data/models/filter_options.dart';
import 'data/repository/character_repository.dart';
import 'presentation/widgets/filer_popup.dart';

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
  FilterOptions? filterOptions;

  @override
  void initState() {
    super.initState();
    fetchCharacters();
    fetchFilterOptions();
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
                icon: const Icon(Icons.filter_alt_rounded),
                onPressed: () {
                  if (filterOptions != null) {
                    _showFilterDialog();
                  }
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
          : filteredCharacters.isEmpty
              ? Center(
                  child: Text('No results found'),
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
                            ? AppColors.offPrimary
                            : AppColors.offSecondary,
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

  Future<void> fetchFilterOptions() async {
    try {
      final distinctStatusOptions =
          await _characterRepository.fetchDistinctStatusOptions();
      final distinctSpeciesOptions =
          await _characterRepository.fetchDistinctSpeciesOptions();
      final distinctGenderOptions =
          await _characterRepository.fetchDistinctGenderOptions();
      setState(() {
        filterOptions = FilterOptions(
          statusOptions: distinctStatusOptions,
          speciesOptions: distinctSpeciesOptions,
          genderOptions: distinctGenderOptions,
        );
      });
    } catch (e) {
      // Handle errors
      print('Error fetching filter options: $e');
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterPopup(
          filterOptions: filterOptions!,
          onFiltersSelected: (selectedFilters) {
            applyFilters(selectedFilters);
          },
        );
      },
    );
  }

  void applyFilters(Map<String, List<String>> selectedFilters) {
    setState(() {
      filteredCharacters = characters.where((character) {
        bool statusMatches = selectedFilters['status'] == null ||
            selectedFilters['status']!.contains(character.status);
        bool speciesMatches = selectedFilters['species'] == null ||
            selectedFilters['species']!.contains(character.species);
        bool genderMatches = selectedFilters['gender'] == null ||
            selectedFilters['gender']!.contains(character.gender);
        return statusMatches && speciesMatches && genderMatches;
      }).toList();
    });
  }
}
