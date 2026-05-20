import 'dart:math' as math;

import 'package:flutter/material.dart';

class ValueNotifierList<T> extends ValueNotifier<List<T>> {
  ValueNotifierList([List<T>? initial]) : super(List.unmodifiable(initial ?? []));

  // Add single or multiple items
  void add(T item) => value = [...value, item];
  void addAll(Iterable<T> items) => value = [...value, ...items];

  // Insert operations
  void insert(int index, T item) {
    final newList = [...value]..insert(index, item);
    value = newList;
  }

  void insertAll(int index, Iterable<T> items) {
    final newList = [...value]..insertAll(index, items);
    value = newList;
  }

  // Update element by index
  void updateAt(int index, T item) {
    final newList = [...value];
    newList[index] = item;
    value = newList;
  }

  // Remove operations
  bool remove(T item) {
    final newList = [...value];
    final removed = newList.remove(item);
    if (removed) value = newList;
    return removed;
  }

  T removeAt(int index) {
    final newList = [...value];
    final removed = newList.removeAt(index);
    value = newList;
    return removed;
  }

  T removeLast() {
    final newList = [...value];
    final removed = newList.removeLast();
    value = newList;
    return removed;
  }

  void removeWhere(bool Function(T) test) {
    value = value.where((e) => !test(e)).toList();
  }

  void removeRange(int start, int end) {
    final newList = [...value]..removeRange(start, end);
    value = newList;
  }

  // Replace range and fill
  void replaceRange(int start, int end, Iterable<T> replacement) {
    final newList = [...value]..replaceRange(start, end, replacement);
    value = newList;
  }

  void fillRange(int start, int end, T fill) {
    final newList = [...value]..fillRange(start, end, fill);
    value = newList;
  }

  void sort([int Function(T a, T b)? compare]) {
    final newList = [...value]..sort(compare);
    value = newList;
  }

  void shuffle([math.Random? random]) {
    final newList = [...value]..shuffle(random);
    value = newList;
  }

  // Utility methods
  void clear() => value = [];

  int indexOf(T item, [int start = 0]) => value.indexOf(item, start);

  int lastIndexOf(T item, [int? start]) => value.lastIndexOf(item, start);

  bool contains(T item) => value.contains(item);

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  int get length => value.length;

  T get first => value.first;

  T get last => value.last;

  T get single => value.single;

  Iterable<T> where(bool Function(T) test) => value.where(test);

  Iterable<R> map<R>(R Function(T) transform) => value.map(transform);

  R fold<R>(R initialValue, R Function(R, T) combine) => value.fold(initialValue, combine);
}

class ValueNotifierMap<K, V> extends ValueNotifier<Map<K, V>> {
  ValueNotifierMap([Map<K, V>? initial]) : super(Map.unmodifiable(initial ?? <K, V>{}));

  // Core mutation methods
  void operator []=(K key, V val) => value = Map<K, V>.from(value)..[key] = val;

  V? operator [](Object? key) => value[key];

  void addAll(Map<K, V> other) => value = Map<K, V>.from(value)..addAll(other);

  void clear() => value = {};

  V? remove(K key) {
    final current = Map<K, V>.from(value);
    final removedValue = current.remove(key);
    value = Map.unmodifiable(current);
    return removedValue;
  }

  V putIfAbsent(K key, V Function() ifAbsent) {
    final newMap = Map<K, V>.from(value);
    final v = newMap.putIfAbsent(key, ifAbsent);
    value = Map.unmodifiable(newMap);
    return v;
  }

  V update(K key, V Function(V) update, {V Function()? ifAbsent}) {
    final newMap = Map<K, V>.from(value);
    final v = newMap.update(key, update, ifAbsent: ifAbsent);
    value = Map.unmodifiable(newMap);
    return v;
  }

  void updateAll(V Function(K, V) update) {
    final newMap = Map<K, V>.from(value);
    newMap.updateAll(update);
    value = Map.unmodifiable(newMap);
  }

  void removeWhere(bool Function(K, V) test) {
    final newMap = Map<K, V>.from(value);
    newMap.removeWhere(test);
    value = Map.unmodifiable(newMap);
  }

  void addEntries(Iterable<MapEntry<K, V>> entries) {
    value = Map<K, V>.from(value)..addEntries(entries);
  }

  Map<RK, RV> map<RK, RV>(MapEntry<RK, RV> Function(K, V) transform) {
    return value.map(transform);
  }

  // Utility getters
  bool containsKey(K key) => value.containsKey(key);

  bool containsValue(V val) => value.containsValue(val);

  Iterable<K> get keys => value.keys;

  Iterable<V> get values => value.values;

  Iterable<MapEntry<K, V>> get entries => value.entries;

  int get length => value.length;

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  @override
  String toString() => value.toString();
}
