import 'package:flutter/material.dart';
class AnotherScreen extends StatefulWidget {
  const AnotherScreen({super.key});

  @override
  State<AnotherScreen> createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Another Screen'),
      ),

      body:const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Another Screen')
        ],
      ),
    );
  }
}
