import 'package:flutter/material.dart';
import 'package:quiz_host/widgets/main_area.dart';
import 'package:quiz_host/widgets/sidebar.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cyber Security Quiz"),
      ),
      drawer: screenWidth <640 ? Drawer(
        child: Sidebar(),
      ):null,
      body: screenWidth<640? 
      Expanded(child: MainArea()):
      Row(
        children: [
          SizedBox(
            width: screenWidth*0.25,
            child: Sidebar(),
          ),
          Expanded(
            child: MainArea(),
          ),
        ],
      ),
    );
  }
}