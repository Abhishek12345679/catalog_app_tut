// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  late final TextEditingController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bloc Counter'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          builder: (context, state) {
            final invalidValue =
                (state is CounterStateInvalid) ? state.invalidValue : '';

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    state.value.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 40,
                    ),
                  ),
                  Visibility(
                    visible: state is CounterStateInvalid,
                    child: Text("Invalid Input: $invalidValue"),
                  ),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<CounterBloc>().add(
                                DecrementEvent(
                                  value: _controller.text,
                                ),
                              );
                        },
                        icon: const Icon(
                          Icons.remove,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<CounterBloc>().add(
                                IncrementEvent(
                                  value: _controller.text,
                                ),
                              );
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
          listener: (context, state) {
            _controller.clear();
          },
        ),
      ),
    );
  }
}

// super state
@immutable
abstract class CounterState {
  final int value;

  const CounterState(
    this.value,
  );
}

//sub states
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

// * abstract classes are like interfaces (however all classes can be used as interfaces, only thing that differentiates abstract classes from classes is that abstract classes cannot be instantiated)

// super event
@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent({
    required this.value,
  });
}

// events
class IncrementEvent extends CounterEvent {
  const IncrementEvent({required super.value});
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent({required super.value});
}

//BLoC (Business Logic Component)

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(_incrementNumber);
    on<DecrementEvent>(_decrementNumber);
  }
  void _incrementNumber(event, emit) {
    final value = int.tryParse(event.value);
    if (value == null) {
      emit(
        CounterStateInvalid(
          invalidValue: event.value,
          previousValue: state.value,
        ),
      );
    } else {
      emit(
        CounterStateValid(state.value + value),
      );
    }
  }

  void _decrementNumber(event, emit) {
    final value = int.tryParse(event.value);
    if (value == null) {
      emit(
        CounterStateInvalid(
          invalidValue: event.value,
          previousValue: state.value,
        ),
      );
    } else {
      emit(
        CounterStateValid(state.value - value),
      );
    }
  }
}
