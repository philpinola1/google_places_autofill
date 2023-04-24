import 'package:flutter/material.dart';
import 'address_search.dart';
import 'place_service.dart';
import 'package:uuid/uuid.dart';

import 'task_details.dart';

class TaskCard extends StatefulWidget {
  final TaskDetails taskDetails;
  final void Function(String id) removeTask;

  const TaskCard(
      {super.key, required this.taskDetails, required this.removeTask});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late String state_id = widget.taskDetails.id;
  late String? state_title = widget.taskDetails.title;
  late String? state_location = widget.taskDetails.location;
  late TimeOfDay? state_time = widget.taskDetails.time;
  late bool state_anyTime = widget.taskDetails.anyTime;

  Suggestion? lastLocation;

  // @override
  // void initState() {
  //   super.initState();
  //   // state_title = widget.taskDetails.title;
  //   // state_location = widget.taskDetails.location;
  //   // state_taskTime = widget.taskDetails.timeOfDay;
  // }

  void onAnyTimeClicked() {
    setState(() {
      state_anyTime = !state_anyTime;
      print('state_anyTime = $state_anyTime');
      state_time = state_anyTime ? null : state_time;
    });
  }

  void updateTaskTime(TimeOfDay? taskTime) {
    setState(() {
      state_time = taskTime;
      state_anyTime = state_time == null ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var locationController = TextEditingController.fromValue(
        TextEditingValue(text: state_location ?? ''));

    var timeController = TextEditingController.fromValue(TextEditingValue(
        text: state_time == null ? '' : (state_time)!.format(context)));

    return Card(
      color: const Color.fromARGB(255, 99, 94, 94),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                  // uuid
                  width: 200,
                  child: Text('uuid = ${widget.taskDetails.id}')),
              SizedBox(
                  // Title
                  width: 200,
                  child: TextFormField(
                    initialValue: widget.taskDetails.title,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                  )),
              SizedBox(
                // Location
                width: 300,
                child: TextFormField(
                  controller: locationController,
                  readOnly: true,
                  onTap: () async {
                    // generate a new token here
                    final sessionToken = const Uuid().v4();
                    Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken, lastLocation),
                    );
                    lastLocation = result;
                    // This will change the text displayed in the TextField
                    if (result != null) {
                      print(result);
                      // setState(() {
                      locationController.text = result.description;
                      // });
                    }
                  },
                  decoration: InputDecoration(
                    icon: Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: 10,
                      height: 10,
                      child: const Icon(
                        Icons.home,
                        color: Colors.black,
                      ),
                    ),
                    hintText: "Location",
                    // border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 5.0, top: 16.0),
                  ),
                ),
              ),
              SizedBox(
                // Time
                width: 150,
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: timeController,
                    cursorWidth: 1,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                    ),
                    onTap: () async {
                      var taskTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        initialEntryMode: TimePickerEntryMode.dial,
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: false),
                            child: child!,
                          );
                        },
                      );
                      updateTaskTime(taskTime);
                      print('taskTime = $taskTime');
                    },
                  ),
                ),
              ),
              SizedBox(
                // Anyyime
                width: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Any Time:'),
                    Checkbox(
                      value: state_anyTime,
                      onChanged: (newVal) {
                        print("newVal = ${newVal!}");
                        onAnyTimeClicked();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          Column(children: [
            IconButton(
                onPressed: () => {
                      print('removing task ${widget.taskDetails.id}'),
                      widget.removeTask(state_id)
                    },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.black,
                ))
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}
