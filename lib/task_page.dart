import 'package:flutter/material.dart';
import 'task_card.dart';
import 'task_details.dart';
import 'package:uuid/uuid.dart';

class TaskPage extends StatefulWidget {
  final String title;
  const TaskPage({Key? key, required this.title}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final String firstId = const Uuid().v4();
  late Map<String, TaskDetails> mapOfTasks = {
    firstId: TaskDetails(firstId, null, null, null, false)
  };

  void addNewTask() {
    final String newId = const Uuid().v4();
    setState(() {
      mapOfTasks.putIfAbsent(
          newId, () => TaskDetails(newId, null, null, null, false));
    });
  }

  void removeTask(String taskId) {
    setState(() {
      var ret = mapOfTasks.remove(taskId);
      if (ret == null) {
        throw ErrorSummary('Failed to remove taskId $taskId');
      }
      print('remaining keys = ${mapOfTasks.keys}');
    });
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: taskList(context),
        floatingActionButton: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => {addNewTask(), print('pressed')}));
  }

  Widget taskList(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ListView.builder(
          itemCount: mapOfTasks.length,
          itemBuilder: ((context, index) {
            var listOfKeys = mapOfTasks.keys;
            var key = listOfKeys.elementAt(index);
            final task = mapOfTasks[key]!;

            return TaskCard(taskDetails: task, removeTask: removeTask);
          })),
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}
