import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

typedef _ControllerCompleter = Completer<AnimationController?>;

class Firework
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  Firework({
    this.radius = 100,
    double? height,
    this.duration = const Duration(seconds: 2),
  }) : height = height ?? (_random100.abs() * 4) + 100;

  final double radius;
  final double height;
  final Duration duration;
  _ControllerCompleter _controller = _ControllerCompleter()..complete();
  AnimationController? _controllerValue;
  Completer<void> _fire = Completer<void>()..complete();
  double _maxWidth = 0;
  Offset _bottomLeftOffset = Offset.zero;

  void fire() async {
    if (_fire.isCompleted) {
      _fire = Completer<void>();
      await awaitController();
      _bottomLeftOffset = _newBottomLeftOffset;
      _controllerValue!.reset();
      _controllerValue!.forward();
      _fire.complete();
    }
  }

  Future<AnimationController> awaitController() async {
    if (_controllerValue == null) {
      if (_controller.isCompleted && ((await _controller.future) == null)) {
        _controller = Completer<AnimationController>();
      }
      await _controller.future;
    }
    return _controllerValue!;
  }

  set ticker(TickerProvider provider) {
    if (_controllerValue != null) return;
    if (_controller.isCompleted) _controller = Completer<AnimationController>();
    _controllerValue = AnimationController(
      vsync: provider,
      duration: duration,
    );
    _controller.complete(_controllerValue);
    notifyListeners();
    _controllerValue!.addListener(notifyListeners);
    _controllerValue!.addStatusListener(notifyStatusListeners);
  }

  @override
  void dispose() {
    _controllerValue?.dispose();
    super.dispose();
  }

  static const _voidWidget = SizedBox.shrink();
  static final _random = Random();

  static double get _oneNegatOrPosit =>
      ((_random.nextInt(2) % 2) == 0) ? -1 : 1;
  static double get _random100 =>
      (_random.nextInt(10000) / 100 + 1) * _oneNegatOrPosit;

  Animation<Offset> get _fireworkTrail => Tween<Offset>(
        begin: Offset.zero,
        end: _offset,
      ).animate(CurvedAnimation(
        parent: _controllerValue!,
        curve: const Interval(
          0,
          0.55,
          curve: Curves.decelerate,
        ),
      ));

  Animation<Size> get _fireworkTrailSize => TweenSequence<Size>([
        TweenSequenceItem<Size>(
          tween: Tween<Size>(
            begin: const Size(10, 0),
            end: const Size(10, 50),
          ),
          weight: 20,
        ),
        TweenSequenceItem<Size>(
          tween: Tween<Size>(
            begin: const Size(10, 50),
            end: const Size(10, 50),
          ),
          weight: 60,
        ),
        TweenSequenceItem<Size>(
          tween: Tween<Size>(
            begin: const Size(10, 50),
            end: const Size(10, 0),
          ),
          weight: 20,
        ),
      ]).animate(CurvedAnimation(
        parent: _controllerValue!,
        curve: const Interval(
          0,
          0.55,
          curve: Curves.easeOut,
        ),
      ));

  List<Animation<Offset>> get _fireworkParticles => [
        for (int i = 0, max = _random100.toInt().abs() + 100; i < max; i++)
          Tween<Offset>(
            begin: Offset.zero,
            end: _circleOffset(),
          ).animate(CurvedAnimation(
            parent: _controllerValue!,
            curve: const Interval(
              0.45,
              1,
              curve: Curves.decelerate,
            ),
          )),
      ];

  Animation<double> get _particlesFade => Tween<double>(
        begin: 1,
        end: 0,
      ).animate(CurvedAnimation(
        parent: _controllerValue!,
        curve: const Interval(
          0.8,
          1,
          curve: Curves.decelerate,
        ),
      ));

  Offset _circleOffset() {
    final value = radius / 100;
    final _offset = Offset(_random100 * value, _random100 * value);
    if (_offset.distance < radius) {
      return _offset;
    } else {
      return _circleOffset();
    }
  }

  late final Offset _offset = Offset(0, height);

  Offset get _newBottomLeftOffset {
    final percentage = (_random100.abs() / 100);
    return Offset(_maxWidth * percentage, 0);
  }

  List<Widget> widgets(double maxWidth) {
    _maxWidth = maxWidth;
    return [
      AnimatedBuilder(
        animation: _fireworkTrail,
        builder: (context, child) {
          if ((_fireworkTrail.status != AnimationStatus.completed) &&
              (_fireworkTrail.status != AnimationStatus.dismissed)) {
            return Positioned(
              bottom: _fireworkTrail.value.dy,
              left: _bottomLeftOffset.dx + _fireworkTrail.value.dx,
              child: child!,
            );
          } else {
            return _voidWidget;
          }
        },
        child: AnimatedBuilder(
          animation: _fireworkTrailSize,
          builder: (context, _) {
            return SizedBox.fromSize(
              size: _fireworkTrailSize.value,
              child: Container(
                color: Colors.yellow,
              ),
            );
          },
        ),
      ),
      for (final particle in _fireworkParticles)
        AnimatedBuilder(
          animation: particle,
          builder: (context, child) {
            if ((particle.status != AnimationStatus.completed) &&
                (particle.status != AnimationStatus.dismissed) &&
                (particle.value != Offset.zero)) {
              return Positioned(
                bottom: _offset.dy + particle.value.dy,
                left: _bottomLeftOffset.dx + _offset.dx + particle.value.dx,
                child: child!,
              );
            } else {
              return _voidWidget;
            }
          },
          child: AnimatedBuilder(
            animation: _particlesFade,
            builder: (context, child) {
              return Opacity(
                opacity: _particlesFade.value,
                child: child!,
              );
            },
            child: SizedBox.square(
              dimension: 10,
              child: Container(
                color: Colors.blue,
              ),
            ),
          ),
        ),
    ];
  }
}
