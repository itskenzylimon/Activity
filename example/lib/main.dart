import 'package:example/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:activity/activity.dart';

import 'model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Task App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Activity(
        BaseController(),
        onActivityStateChanged: ()=>
            DateTime.now().microsecondsSinceEpoch.toString(),
        child: TaskView(
          activeController: BaseController(),
        ),
      ),
    );
  }
}

class TaskView extends ActiveView<BaseController> {
  const TaskView({super.key, required super.activeController});

  @override
  ActiveState<ActiveView<ActiveController>, BaseController> createActivity() =>
      _TaskViewState(activeController);
}

class _TaskViewState extends ActiveState<TaskView, BaseController> {
  _TaskViewState(super.activeController);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activeController.initCalculations();
  }

  // @override
  // void didChangeDependencies() {
  //   Activity.getActivity<BaseController>(context).totalTaskLevels();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'This is Activity',
      theme: ThemeData(
        primarySwatch: activeController.tasksLevel.value > 100 ? Colors.red : Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Activity App'),
        ),
        body: SafeArea(
            child: Column(
              children: [
                TextButton(
                    onPressed: () {
                      double width = context.size!.width;
                      double height = context.size!.height;
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Add User Task'),
                          content: SizedBox(
                              width: width,
                              height: height,
                              child: userTaskForm(activeController.globalKey)),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'OK');
                                if (activeController.userName.text.isNotEmpty &&
                                    activeController.userEmail.text.isNotEmpty &&
                                    activeController.taskName.text.isNotEmpty &&
                                    activeController.taskBody.text.isNotEmpty) {
                                  activeController.saveEntry();
                                }
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Add Task')),
                Container(
                  margin: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 10, left: 10),
                  child: Card(
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(activeController.tasks.length.toString()),
                              const Text(
                                'Total tasks',
                                style: TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                          const SizedBox(width: 50,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(activeController.tasksLevel.toString()),
                              const Text(
                                'Total task level : Max > 100',
                                style: TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ifRunning(
                    const CircularProgressIndicator(),
                    otherwise: Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: activeController.tasks.length,
                            itemBuilder: (context, i) {
                              ActiveModel<Task> taskModel =
                              activeController.tasks[i];
                              return ListTile(
                                title: Text(taskModel.value.name),
                                subtitle: Text(taskModel.value.body),
                                leading: IconButton(
                                    onPressed: () {
                                      activeController.userName.text = taskModel.value.user.name;
                                      activeController.userEmail.text = taskModel.value.user.email!;
                                      activeController.taskName.text = taskModel.value.name;
                                      activeController.taskBody.text = taskModel.value.body;
                                      activeController.taskLevel.text = taskModel.value.level.toString();

                                      showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Edit ${taskModel.value.name} Task'),
                                              content: SizedBox(
                                                  height: 600,
                                                  width: 600,
                                                  child: userTaskForm(activeController.globalKey)),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: ()
                                                  {
                                                    /**
                                                     * Clear fields and refresh Page
                                                     */
                                                    activeController.userName.clear();
                                                    activeController.userEmail.clear();
                                                    activeController.taskName.clear();
                                                    activeController.taskBody.clear();
                                                    activeController.taskLevel.clear();
                                            Navigator.pop(context, 'Cancel');
                                          },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if (activeController.userName.text.isNotEmpty &&
                                                        activeController.userEmail.text.isNotEmpty &&
                                                        activeController.taskName.text.isNotEmpty &&
                                                        activeController.taskLevel.text.isNotEmpty &&
                                                        activeController.taskBody.text.isNotEmpty) {
                                                      activeController.editUserTask(activeController.tasks[i], i);
                                                    }
                                                    Navigator.pop(context, 'Cancel');
                                                  },
                                                  child: const Text('SUBMIT'),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    icon: const Icon(Icons.edit)),
                                trailing: IconButton(
                                    onPressed: () {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: Text(taskModel.value.name),
                                          content: const Text(
                                              'Are you sure you want to delete this task.?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'OK');
                                                activeController.deleteUserTask(activeController.tasks[i]);
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.deepOrange,
                                    )),
                              );
                            },
                          ),
                        ))
                )
              ],
            )),
      ),
    );
  }

  Widget userTaskForm(GlobalKey globalKey) {
    return Form(
        key: globalKey,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: ListView(
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
                controller: activeController.userName,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter User Name';
                //   }
                //   return null;
                // },
              ),
              const Divider(
                height: 10,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Email',
                ),
                controller: activeController.userEmail,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter User Email';
                  }
                  return null;
                },
              ),
              const Divider(
                height: 10,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task Name',
                ),
                controller: activeController.taskName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Task Name';
                  }
                  return null;
                },
              ),
              const Divider(
                height: 10,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task Body',
                ),
                controller: activeController.taskBody,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Task Body';
                  }
                  return null;
                },
              ),
              const Divider(
                height: 10,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task Level',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[0-9]"),
                  )
                ],
                controller: activeController.taskLevel,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Task Level';
                  }
                  return null;
                },
              ),
              const Divider(
                height: 20,
              )
            ],
          ),
        ));
  }


}