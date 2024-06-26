import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/utils/loading/loading_screen_controller.dart';

class LoadingScreen {
  LoadingScreenController? _controller;

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textStreamController = StreamController<String>();
    textStreamController.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(50),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      StreamBuilder(
                        stream: textStreamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        textStreamController.close();
        overlay.remove();
      },
      updated: (text) {
        textStreamController.add(text);
        return true;
      },
    );
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (_controller?.updated(text) ?? false) {
      return;
    }
    _controller = showOverlay(context: context, text: text);
  }

  static final LoadingScreen _instance = LoadingScreen._privateConstructor();
  LoadingScreen._privateConstructor();
  factory LoadingScreen() => _instance;
}
