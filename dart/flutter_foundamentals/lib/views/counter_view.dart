import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocCounterView extends StatefulWidget {
  const BlocCounterView({super.key});

  @override
  State<BlocCounterView> createState() => _BlocCounterViewState();
}

class _BlocCounterViewState extends State<BlocCounterView> {
  late final TextEditingController _numberController;

  @override
  void initState() {
    _numberController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CounterBloc(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Bloc counter"),
          ),
          body: BlocConsumer<CounterBloc, CounterState>(
            listener: (context, state) {
              _numberController.clear();
            },
            builder: (context, state) {
              final invalidValue = (state is CounterStateInvalidNumber)
                  ? state.invalidValue
                  : "";
              return Column(
                children: [
                  Text("Current value: ${state.value}"),
                  Visibility(
                    visible: state is CounterStateInvalidNumber,
                    child: Text("Invalid input: $invalidValue"),
                  ),
                  TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      hintText: "Enter a number",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          context
                              .read<CounterBloc>()
                              .add(DecrementEvent(_numberController.text));
                        },
                        child: const Text("-"),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<CounterBloc>()
                              .add(IncrementEvent(_numberController.text));
                        },
                        child: const Text("+"),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ));
  }
}

@immutable
abstract class CounterState {
  final int value;

  const CounterState({required this.value});
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value: value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;
  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(value: previousValue);
}

// events
@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent({required this.value});
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value: value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value: value);
}

// blocs
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final number = int.tryParse(event.value);

      if (number == null) {
        emit(CounterStateInvalidNumber(
          invalidValue: event.value,
          previousValue: state.value,
        ));
        return;
      }

      emit(CounterStateValid(state.value + number));
    });
    on<DecrementEvent>((event, emit) {
      final number = int.tryParse(event.value);

      if (number == null) {
        emit(CounterStateInvalidNumber(
          invalidValue: event.value,
          previousValue: state.value,
        ));
        return;
      }

      emit(CounterStateValid(state.value - number));
    });
  }
}
