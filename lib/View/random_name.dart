import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math show Random;

const List<String> names = [
  "Rez",
  "Frank",
  "John",
  "Jeffry",
  "Angela",
];

// cubit class for managing state
class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);

  void pickRandomName() => emit(names.getRandomElement());
}

// extension for select random number
extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

class RandomName extends StatefulWidget {
  const RandomName({super.key});

  @override
  State<RandomName> createState() => _RandomNameState();
}

class _RandomNameState extends State<RandomName> {
  late final NamesCubit cubit;

  @override
  void initState() {
    cubit = NamesCubit();
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Random Name With Cubit"),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<String?>(
          /// Really Important Part
          /// We pass the Current cubit class stream to StreamBuilder Widget to know about Current State Stream
          stream: cubit.stream,

          ///
          builder: ((context, snapshot) {
            final Widget button = TextButton(
                onPressed: () => cubit.pickRandomName(),
                child: const Text("Pick a Random Number"));

            Widget text(String msg) => Text(
              msg,
              style: const TextStyle(fontSize: 20),
            );
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text("None"),
                    button,
                  ],
                );

              case ConnectionState.waiting:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text("Waiting..."),
                    button,
                  ],
                );

              case ConnectionState.active:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text(cubit.state ?? ""),
                    button,
                  ],
                );

              case ConnectionState.done:
                return const SizedBox();
            }
          }),
        ),
      ),
    );
  }
}