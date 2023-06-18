import 'dart:async';

import 'package:example/task_view.dart';
import 'package:flutter/material.dart';
import 'package:example/task_controller.dart';
import 'package:activity/activity.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
        const Duration(seconds: 3),
        () => Nav.to(
              context,
              () => Activity(
                TaskController(),
                developerMode: true,
                onActivityStateChanged: () => DateTime.now().microsecondsSinceEpoch.toString(),
                child: TaskView(activeController: TaskController()),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(
        child: SizedBox(
          child: Center(
              child: Text("Splash Screen",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
            ),
        ),
      ),
    );
  }
}
