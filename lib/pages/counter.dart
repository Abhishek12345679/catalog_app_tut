// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc Counter'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text('Counter')),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;

  const CounterState(
    this.value,
  );
}

class CounterStateValid extends CounterState {
  // here the value passed to CounterStateValid gets passed on to CounterState via the  'super()', the super key calls the superclass
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;
  const CounterStateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent({
    required this.value,
  });
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent({required super.value});
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent({required super.value});
}

//BLoC (Business Logic Component)

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    //
  }
}
