import 'package:flutter/material.dart';
import '../models/songModel.dart';
import '../apis/MySongs_Logic.dart';

class MusicRemovePage extends StatefulWidget {
  const MusicRemovePage({super.key});

  @override
  _MusicRemovePageState createState() => _MusicRemovePageState();
}

class _MusicRemovePageState extends State<MusicRemovePage> {
  String _selectedOption = 'Song'; // Default selection
  TextEditingController searchController = TextEditingController();
  List<String> _allItems = []; // List to hold all items
  List<String> _items = []; // List to hold songs, albums, or artists
  List<String> songs = [];
  List<String> albums = [];
  List<String> artists = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _fetchAlbums();
    _fetchArtists();
  }

  void _fetchSongs() async {
    try {
      List<Song> songObjects = await SongService().fetchSongs();
      List<String> fetchedSongNames = songObjects.map((song) => song.songName).toList();
      setState(() {
        songs = fetchedSongNames;
        _loadItems(); // Load initial data with fetched song names
      });
    } catch (e) {
      print('Error fetching songs: $e');
    }
  }

  void _fetchAlbums() async {
    try {
      List<Song> songObjects = await SongService().fetchSongs();
      List<String> fetchedAlbumNames = songObjects.map((song) => song.albumName).toList();
      setState(() {
        albums = fetchedAlbumNames;
        _loadItems(); // Load initial data with fetched song names
      });
    } catch (e) {
      print('Error fetching albums: $e');
    }
  }

  void _fetchArtists() async {
    try {
      List<Song> songObjects = await SongService().fetchSongs();
      List<String> fetchedArtistNames = songObjects.map((song) => song.mainArtistName).toList();
      setState(() {
        artists = fetchedArtistNames;
        _loadItems(); // Load initial data with fetched song names
      });
    } catch (e) {
      print('Error fetching artists: $e');
    }
  }

  void _loadItems() {
    if (_selectedOption == 'Song') {
      _allItems = songs;
    } else if (_selectedOption == 'Album') {
      _allItems = albums;
    } else if (_selectedOption == 'Artist') {
      _allItems = artists;
    }
    _items = List.from(_allItems);
    setState(() {}); // Trigger UI update
  }

  void _filterItems(String searchText) {
    if (searchText.isEmpty) {
      _items =
          List.from(_allItems); // Display all items if search text is empty
    } else {
      _items = _allItems
          .where(
              (item) => item.toLowerCase().contains(searchText.toLowerCase()))
          .toList(); // Filter items based on search text
    }
    setState(() {}); // Update UI
  }

  void _clearSearch() {
    searchController.clear();
    _filterItems('');
  }

  void _removeItem(String item) {
    setState(() {
      _allItems.remove(item);
      _items.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF171717),
        elevation: 0.0,
        toolbarHeight: 60.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 35),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/logo_white.png',
          height: 55,
          width: 55,
        ),
      ),
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  <String>['Song', 'Album', 'Artist'].map((String option) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedOption = option;
                      _loadItems();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption == option
                        ? Colors.green
                        : Colors.grey[800],
                    side: BorderSide(
                      color: _selectedOption == option
                          ? Colors.white
                          : Colors
                              .green, // Border color changes based on selection
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    option.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'Search...', // Using hintText instead of labelText
                  hintStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                        color: Colors.green, width: 3.0), // Blue frame
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                        color: Colors.green, width: 3.0), // Blue frame
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                        color: Colors.white, width: 3.0), // Blue frame
                  ),
                  suffixIcon: const Icon(Icons.search, color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                onChanged: (String value) {
                  _filterItems(value);
                },
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18) // Increased font size
                        ),
                    onTap: () => _showConfirmationDialog(_items[index]),
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal',
              style: TextStyle(color: Colors.green)),
          content: Text('Are you sure you want to remove "$item"?',
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          backgroundColor: Colors.grey[800],
          actions: <Widget>[
            TextButton(
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 20.0)),
                onPressed: () {
                  Navigator.of(context).pop();
                  //_clearSearch();
                }),
            TextButton(
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red, fontSize: 20.0)),
              onPressed: () {
                _removeItem(item); // Remove the item
                Navigator.of(context).pop();
                _clearSearch();
              },
            ),
          ],
        );
      },
    );
  }
}
