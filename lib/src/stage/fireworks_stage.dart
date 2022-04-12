import 'package:flutter/material.dart';

import '../controller/fireworks_controller.dart';

class FireworksStage extends StatefulWidget {
  const FireworksStage({
    Key? key,
    this.child,
    this.controller,
  }) : super(key: key);

  final Widget? child;
  final FireworksController? controller;

  @override
  State<FireworksStage> createState() => _FireworksStageState();
}

class _FireworksStageState extends State<FireworksStage>
    with TickerProviderStateMixin {
  late final FireworksController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? FireworksController();
    for (final firework in _controller.list) {
      firework.ticker = this;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<FireworksValue>(
          valueListenable: _controller,
          builder: (context, fireworks, child) {
            for (final firework in fireworks) {
              firework.ticker = this;
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                child ?? const SizedBox.shrink(),
                for (final firework in [...fireworks])
                  ...firework.widgets(constraints.maxWidth),
              ],
            );
          },
          child: widget.child,
        );
      },
    );
  }
}
