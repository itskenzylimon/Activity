import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'dart:typed_data';

import 'package:activity/activity.dart';
import 'package:activity/core/forms/signature.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignatureView extends StatefulWidget {
  const SignatureView({Key? key}) : super(key: key);

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.blue,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => log('Value changed'));
  }

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

   exportImage() async {
    final Uint8List? data =
    await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    } else {
      convertToBase64(data);
    }
    if (!mounted) return;
  }

  convertToBase64(var image) async {
    List<int> fileInByte = image.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Signature(
            key: const Key('signature'),
            controller: _controller,
            height: 450,
            backgroundColor: Colors.grey[300]!,
          ),
          Positioned(
            right: 20,
            top: 5,
            child: IconButton(
              onPressed: () {
                _controller.clear();
              },
              icon: Icon(
                Icons.clear,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future push(context, widget) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return widget;
      },
    ),
  );
}
