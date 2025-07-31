import 'package:flutter/material.dart';

class NewListScreen extends StatefulWidget {
  const NewListScreen({super.key});

  @override
  State<NewListScreen> createState() => _NewListScreenState();
}

class _NewListScreenState extends State<NewListScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _taskLists = [];

  void _addNewList() {
    final newList = _controller.text.trim();
    if (newList.isNotEmpty) {
      setState(() {
        _taskLists.add(newList);
        _controller.clear();
      });
    }
  }

  void _removeList(int index) {
    setState(() {
      _taskLists.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("New Task Lists", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Enter new list name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addNewList,
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _taskLists.isEmpty
                ? const Center(
                    child: Text("No task lists yet", style: TextStyle(fontSize: 16)),
                  )
                : ListView.builder(
                    itemCount: _taskLists.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(_taskLists[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeList(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
