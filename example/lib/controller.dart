import 'package:activity/activity.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';

class BaseController extends ActiveController {

  GlobalKey globalKey = GlobalKey<FormState>();

  ActiveModel<Task> activeTaskModel = ActiveModel(Task(
      name: 'Test Task',
      body: 'Complete this amazing package',
      level: 100,
      user: User(
          name: 'Kenzy Limon',
          email: 'itskenzylimon@gmail.com')));

  ActiveList<ActiveModel<Task>> tasks = ActiveList.empty();

  TextEditingController userName = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController taskName = TextEditingController();
  TextEditingController taskBody = TextEditingController();
  TextEditingController taskLevel = TextEditingController();


  Memory memory = Memory.memory;
  getMemoryData() async {
    // print(memory.isDataEmpty);
    memory.upsertMemory('tasks', tasks);
    // print(memory.isDataEmpty);
    // ActiveList<ActiveModel<Task>> memoryTasks = memory.readMemory('tasks');
    // print('{{{{{ ${memoryTasks.length}');
  }

  Future<void> initCalculations() async {
    totalTaskLevels();
  }

  Future<void> saveEntry() async {

    tasks.add(ActiveModel(Task(
        name: taskName.text,
        body: taskBody.text,
        level: int.parse(taskLevel.text),
        user: User(
            name: userName.text,
            email: userEmail.text)), typeName: '${tasks.length + 1}'));

    /**
     * Call initCalculations() to Update our UI
     */
    initCalculations();
    getMemoryData();

    /**
     * Clear fields and refresh Page
     */
    userName.clear();
    userEmail.clear();
    taskName.clear();
    taskBody.clear();
    taskLevel.clear();

    /**
     * No need for setState, Activity handles it for you
     */
    // setState(() {
    //   initCalculations();
    // });
  }

  Future<void> deleteUserTask(ActiveModel<Task> task) async {

    tasks.remove(task);

    /**
     * Call initCalculations() to Update our UI
     */
    initCalculations();

    /**
     * No need for setState, Activity handles it for you
     */
    // setState(() {
    //   initCalculations();
    // });
  }

  Future<void> editUserTask(ActiveModel<Task> task, int index) async {

    // ActiveModel(Task(
    //     name: taskName.text,
    //     body: taskBody.text,
    //     level: int.parse(taskLevel.text),
    //     user: User(
    //         name: userName.text,
    //         email: userEmail.text)), typeName: task.typeName);

    // List<ActiveModel<Task>> newTasks = tasks.value;
    // newTasks[index] = ActiveModel(Task(
    //     name: taskName.text,
    //     body: taskBody.text,
    //     level: int.parse(taskLevel.text),
    //     user: User(
    //         name: userName.text,
    //         email: userEmail.text)), typeName: taskName.text);
    // tasks.set(newTasks);

    task.value.body = taskBody.text;
    task.value.level = int.parse(taskLevel.text);
    task.value.body = taskBody.text;
    task.value.user = User(
        name: userName.text,
        email: userEmail.text);
    //
    // tasks.value[index] = task;

    tasks.removeAt(index);
    tasks.add(task);

    /**
     * Call initCalculations() to Update our UI
     */
    initCalculations();

    // var taskModels = tasks.value;
    // taskModels[index] = task;
    // tasks.set(taskModels);

    /**
     * Clear fields and refresh Page
     */
    userName.clear();
    userEmail.clear();
    taskName.clear();
    taskBody.clear();
    taskLevel.clear();
    /**
     * Again no need for updating state
     */
    // setState(() {
    //
    // });
  }

  ActiveInt tasksLevel = ActiveInt(0, typeName: 'minimum');
  Future<void> totalTaskLevels() async {

    /**
     * Here we reset the tasksLevel value and we can choose to pass
     * notifyChange false to avoid unnecessary UI re-build
     */
    tasksLevel.reset(notifyChange: false);

    int count = 0;
    tasks.forEach((ActiveModel<Task> task) {
      count = count + task.value.level;
    });

    /**
     * Update the tasksLevel value
     */
    tasksLevel.set(count);

  }

  @override
  List<ActiveType> get activities {
    return [tasksLevel, tasks];
  }

}