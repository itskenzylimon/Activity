import 'dart:developer';
import 'dart:typed_data';

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

  // Future<void> exportImage(BuildContext context) async {
  //   if (_controller.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         key: Key('snackbarPNG'),
  //         content: Text('No content'),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final Uint8List? data =
  //   await _controller.toPngBytes(height: 1000, width: 1000);
  //   if (data == null) {
  //     return;
  //   }
  //
  //   if (!mounted) return;
  //
  //   await push(
  //     context,
  //     Scaffold(
  //       appBar: AppBar(
  //         title: const Text('PNG Image'),
  //       ),
  //       body: Center(
  //         child: Container(
  //           color: Colors.grey[300],
  //           child: Image.memory(data),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Future<void> exportSVG(BuildContext context) async {
  //   if (_controller.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         key: Key('snackbarSVG'),
  //         content: Text('No content'),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final SvgPicture data = _controller.toSVG()!;
  //
  //   if (!mounted) return;
  //
  //   await push(
  //     context,
  //     Scaffold(
  //       appBar: AppBar(
  //         title: const Text('SVG Image'),
  //       ),
  //       body: Center(
  //         child: Container(
  //           color: Colors.grey[300],
  //           child: data,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Demo'),
      ),
      body: ListView(
        children: <Widget>[
          //SIGNATURE CANVAS
          Signature(
            key: const Key('signature'),
            controller: _controller,
            height: 450,
            backgroundColor: Colors.grey[300]!,
          ),
          //OK AND CLEAR BUTTONS
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                key: const Key('exportPNG'),
                icon: const Icon(Icons.image),
                color: Colors.blue,
                onPressed: () {},
                // => exportImage(context),
                tooltip: 'Export Image',
              ),
              IconButton(
                key: const Key('exportSVG'),
                icon: const Icon(Icons.share),
                color: Colors.blue,
                onPressed: () {},
                //exportSVG(context),
                tooltip: 'Export SVG',
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.undo());
                },
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.redo());
                },
                tooltip: 'Redo',
              ),
              //CLEAR CANVAS
              IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.clear());
                },
                tooltip: 'Clear',
              ),
            ],
          ),
        ),
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