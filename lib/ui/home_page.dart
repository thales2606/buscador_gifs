import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  String _search;
  int _offset = 0;
  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search.isEmpty) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=UFxl3O55rfmdGA4qkcAcSknTVdfqrG0s&limit=20&rating=g");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=UFxl3O55rfmdGA4qkcAcSknTVdfqrG0s&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt");
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5,
                    ),
                  );
                default:
                  if (snapshot.hasError) return Container();
                  return _createGifTable(context, snapshot);
              }
            },
          ))
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data["data"][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
          );
        else
          return Container(
              child: GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  "Carregar mais...",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                )
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          ));
      },
    );
  }
}
