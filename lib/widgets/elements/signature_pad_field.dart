import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:activity/activity.dart';
import 'package:activity/widgets/elements/signature.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SignatureFieldWidget extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  SignatureFieldWidget(
      {super.key,
      required this.onElementCallback,
      required this.elementName,
      required this.valueFormResults,
      required this.customTheme});

  @override
  State<SignatureFieldWidget> createState() => _SignatureFieldWidgetState();
}

class _SignatureFieldWidgetState extends State<SignatureFieldWidget> {
  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  String imageInBase64 = '';
  String base64File = '';

  bool signed = false;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  exportImage() async {
    final Uint8List? data =
        await _controller.toPngBytes(height: 200, width: 200);
    if (data == null) {
      return;
    } else {
      List<int> fileInByte = data;
      String fileInBase64 = base64Encode(fileInByte);
      setState(() {
        imageInBase64 = fileInBase64;
      });
      callbackElement['value'] = fileInBase64;
      widget.onElementCallback(callbackElement);
      signed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    callbackElement = widget.valueFormResults[widget.elementName]!;

    if (callbackElement['type'] == 'signaturepad') {
      // printInfo(callbackElement['type']);
      return widget.valueFormResults[widget.elementName]!['visible']
          ? Container(
              margin: const EdgeInsets.only(top: 30),
              height: 400,
              child: imageInBase64 == ''
                  ? Stack(
                      children: [
                        Signature(
                          key: const Key('signature'),
                          controller: _controller,
                          height: 450,
                          backgroundColor: Colors.grey[300]!,
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          top: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _controller.clear();
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  exportImage();
                                },
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 400,
                      child: Image.memory(
                        base64.decode(imageInBase64),
                      ),
                    ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: base64File == ''
                  ? InkWell(
                      onTap: () async {
                        //upload file
                        String base64 = await getFile();
                      },
                      child: Container(
                        color: Colors.blue,
                        height: 40,
                        child: Center(
                          child: Text(
                            "Pick file",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 450,
                      child: Image.memory(
                        base64.decode(base64File),
                      ),
                    ),
            );
    } else if (callbackElement['type'] == 'file') {
      // printError(callbackElement['type']);
      return Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: InkWell(
          onTap: () async {
            //upload file
            String base64 = await getFile();
          },
          child: Container(
            color: Colors.blue,
            height: 40,
            child: Center(
              child: Text(
                "Pick file",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  String? path;

  String getBase64FormateFile(String path) {
    File file = File(path);
    // print('File is = ' + file.toString());
    List<int> fileInByte = file.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    setState(() {
      base64File = fileInBase64;
    });
    callbackElement['value'] = fileInBase64;
    widget.onElementCallback(callbackElement);
    signed = true;
    // printWarning(callbackElement['value']);
    return fileInBase64;
  }

  //upload file
  Future<String> getFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return "";
    path = result.files.single.path!;
    return getBase64FormateFile(path!);
  }
}
