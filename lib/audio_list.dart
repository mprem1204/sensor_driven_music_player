import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loop_audio.dart';

class AudioListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio List'),
        backgroundColor: Color(0xFF0C44A3),
        elevation: 4,
        centerTitle: true,
      ),
      body: AudioList(),
    );
  }
}

class AudioList extends StatefulWidget {
  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  List<Map<String, dynamic>> sounds = [];

  @override
  void initState() {
    super.initState();
    fetchSounds();
  }

  Future<void> fetchSounds() async {   // Http Call to fetch all the data from freesound.org
    final apiUrl =
        'https://freesound.org/apiv2/search/text/?query=beat&token=ZO8Ny9tMBLKCQw3DOAIhYD8glC9IUTkh8gnDGuQW';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> fetchedSounds = data['results'];

        setState(() {
          sounds = List<Map<String, dynamic>>.from(fetchedSounds.map((sound) {
            return {
              'name': sound['name'],
              'id': sound['id'],
            };
          }));
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        return Card(
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              title: Text(
                sounds[index]['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              subtitle: Row(
                children: <Widget>[
                  Text('ID: ${sounds[index]['id']}',
                      style: TextStyle(fontSize: 10))
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right, size: 15.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoopAudio(
                      songName: sounds[index]['name'].split(' ').first,
                      songId: sounds[index]['id'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
