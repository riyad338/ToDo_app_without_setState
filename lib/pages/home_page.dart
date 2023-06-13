import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app_nosetstate/model/todo_model.dart';

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final CollectionReference todosRef =
      FirebaseFirestore.instance.collection('ToDos');
  late TextEditingController _textEditingController;
  late Stream<QuerySnapshot> todosStream;
  List<TodoModel> todos = [];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    todosStream = todosRef.orderBy('time', descending: true).snapshots();
  }

  void _addTodo() async {
    String title = _textEditingController.text;
    if (title.isNotEmpty) {
      await todosRef.add({
        'title': title,
        'time': DateTime.now(),
        'completed': false,
      });
      _textEditingController.clear();
    }
  }

  void _toggleTodoState(String id, bool completed) async {
    await todosRef.doc(id).update({'completed': completed});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo App'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: todosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          todos = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return TodoModel(
              id: doc.id,
              title: data['title'],
              time: data['time'],
              completed: data['completed'],
            );
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: todos.length,
            itemBuilder: (context, index) {
              TodoModel todo = todos[index];
              return Card(
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    side: BorderSide(color: Colors.redAccent),
                  ),
                  tileColor: todo.completed == true
                      ? Colors.grey
                      : Colors.grey.shade300,
                  title: Text(
                    todo.title,
                    style: todo.completed == true
                        ? TextStyle(decoration: TextDecoration.lineThrough)
                        : TextStyle(),
                  ),
                  trailing: Checkbox(
                    activeColor: Colors.green,
                    value: todo.completed,
                    onChanged: (value) {
                      _toggleTodoState(todo.id, value ?? false);
                    },
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () {
            _showDialog(context);
          },
          child: Icon(Icons.add)),
    );
  }

  _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 20,
          title: Text("Add new task"),
          content: TextFormField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.edit),
              hintText: "Add To List",
            ),
            controller: _textEditingController,
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              width: 20.w,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300),
              child: Text("Add Task"),
              onPressed: () {
                _addTodo();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Add new task Successfully"),
                ));

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
