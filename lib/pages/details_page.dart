import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app_nosetstate/model/todo_model.dart';

class DetailsPage extends StatefulWidget {
  DetailsPage({required this.index});
  TodoModel index;
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextEditingController _updatecontrollere = TextEditingController();
  final CollectionReference todosRef =
      FirebaseFirestore.instance.collection('ToDos');
  @override
  void initState() {
    _updatecontrollere.text = widget.index.title;
    super.initState();
  }

  void _deleteTodo(String id) async {
    await todosRef.doc(id).delete();
  }

  void _updateTodoTitle(String id, String newTitle) async {
    await todosRef.doc(id).update({'title': newTitle});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _updatecontrollere,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.5.w, color: Colors.green),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1, color: Colors.green), //<-- SEE HERE
                  ),
                  suffixIcon: IconButton(
                      onPressed: () {
                        _deleteTodo(widget.index.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Delete Successfully"),
                        ));
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))),
            ),
          ),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                if (_updatecontrollere.text.isNotEmpty) {
                  _updateTodoTitle(widget.index.id, _updatecontrollere.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Update Successfully"),
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: Text("Update"))
        ],
      ),
    );
  }
}
