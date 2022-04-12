import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

import '../firework/firework.dart';

class FireworksController extends ValueNotifier<FireworksValue> {
  FireworksController([List<Firework>? list])
      : super(list == null ? FireworksValue.empty : FireworksValue(list));

  List<Firework> get list => value;
  set list(List<Firework> newList) {
    value = value.copyWith(list: newList);
  }

  void fire(int id) {
    for (final firework in value) {
      firework.fire();
    }
  }

  void fireAll() {
    for (final firework in value) {
      firework.fire();
    }
  }

  void add(Firework newFirework, [bool removeWhenComplete = false]) {
    if (removeWhenComplete) {
      newFirework.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          value = FireworksValue([...value]..remove(newFirework..dispose()));
        }
      });
    }
    final list = [...value, newFirework];
    value = FireworksValue(list);
  }

  void clear() {
    value = const FireworksValue();
  }
}

@immutable
class FireworksValue extends DelegatingList<Firework> with ListMixin<Firework> {
  const FireworksValue([
    List<Firework> list = const [],
  ]) : super(list);

  static const FireworksValue empty = FireworksValue();

  FireworksValue copyWith({
    List<Firework>? list,
  }) {
    return FireworksValue(list ?? this);
  }
}
