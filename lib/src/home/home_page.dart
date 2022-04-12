import 'package:firework/src/controller/fireworks_controller.dart';
import 'package:flutter/material.dart';

import '../firework/firework.dart';
import '../stage/fireworks_stage.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = FireworksController([]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firework Test'),
        centerTitle: true,
      ),
      body: FireworksStage(
        controller: controller,
        child: Center(
          child: ElevatedButton(
            child: const Text('Fire'),
            onPressed: () {
              controller.add(Firework()..fire(), true);
            },
          ),
        ),
      ),
    );
  }
}
