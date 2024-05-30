import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('todo_box');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HiveTodo(),
  ));
}

class HiveTodo extends StatefulWidget {
  @override
  State<HiveTodo> createState() => _HiveTodoState();
}

class _HiveTodoState extends State<HiveTodo> {
  late List<Map<String, dynamic>> tasks;
  final Box myBox = Hive.box('todo_box');

  @override
  void initState() {
    tasks = [];
    readTasksAndRefreshUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
      ),
      body: tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        itemCount: tasks.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(
              tasks[index]['time'] as int);

          return Card(
            color: Colors.primaries[index % Colors.primaries.length],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${tasks[index]['taskname']}',
                  style: GoogleFonts.habibi(fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  tasks[index]['taskdesc'],
                  overflow: TextOverflow.visible,
                  maxLines: 4,
                  style: GoogleFonts.habibi(fontSize: 15),
                ),
                Text(
                  '$date',
                  style: GoogleFonts.habibi(fontSize: 15),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () =>
                            showAlertBox(tasks[index]['id']),
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () =>
                            deleteTask(tasks[index]['id'] as int),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAlertBox(null),
        child: Icon(Icons.task),
      ),
    );
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  void showAlertBox(int? key) {
    if (key != null) {
      final existingTask =
      tasks.firstWhere((element) => element['id'] == key);
      titleController.text = existingTask['taskname'];
      descriptionController.text = existingTask['taskdesc'];
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.greenAccent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Title",
                ),
                controller: titleController,
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Content",
                ),
                controller: descriptionController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  createTask({
                    'taskname': titleController.text.trim(),
                    'taskdesc': descriptionController.text.trim(),
                    'time': DateTime.now().millisecondsSinceEpoch,
                  });
                }
                titleController.clear();
                descriptionController.clear();
                Navigator.pop(context);
              },
              child: Text('Create Task'),
            ),
            if (key != null)
              TextButton(
                onPressed: () {
                  updateTask(key, {
                    'taskname': titleController.text.trim(),
                    'taskdesc': descriptionController.text.trim(),
                    'time': DateTime.now().millisecondsSinceEpoch,
                  });
                  titleController.clear();
                  descriptionController.clear();
                  Navigator.pop(context);
                },
                child: Text('Update Task'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> createTask(Map<String, dynamic> myTask) async {
    await myBox.add(myTask);
    readTasksAndRefreshUI();
  }

  void readTasksAndRefreshUI() {
    final List<Map<String, dynamic>> tasksFromHive = [];
    for (var key in myBox.keys) {
      final value = myBox.get(key);
      tasksFromHive.add({
        'id': key,
        'taskname': value['taskname'],
        'taskdesc': value['taskdesc'],
        'time': value['time'],
      });
    }
    setState(() {
      tasks = tasksFromHive.reversed.toList();
    });
  }

  Future<void> updateTask(int key, Map<String, dynamic> updatedTask) async {
    await myBox.put(key, updatedTask);
    readTasksAndRefreshUI();
  }

  Future<void> deleteTask(int key) async {
    await myBox.delete(key);
    readTasksAndRefreshUI();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Successfully Deleted")),
    );
  }
}