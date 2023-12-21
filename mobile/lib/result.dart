import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  final String translatedText;

  const ResultScreen({Key? key, required this.translatedText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Translated Text: $translatedText',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Open the website when the link is tapped
                // ignore: deprecated_member_use
                launch('https://www.povarenok.ru/recipes/find');
              },
              child: const Text(
                'Visit our website',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
