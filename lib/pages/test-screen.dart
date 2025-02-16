import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // Ensures scrolling
          ),
          child: Column(
            children: [
              // Row containing Flex 1 and Flex 2
              Container(
                height: 500, // Adjust as needed
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.red,
                        child: Center(child: Text("Flex 1")),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Colors.green,
                        child: Center(child: Text("Flex 2")),
                      ),
                    ),
                  ],
                ),
              ),
              // Flex 3 positioned below both Flex 1 and Flex 2
              Container(
                height: 500, // Adjust to make scroll effect more visible
                child: Container(
                  color: Colors.blue,
                  child: Center(child: Text("Flex 3")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}