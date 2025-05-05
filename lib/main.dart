import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF4CAF50),
          error: const Color(0xFFE57373),
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<TodoItem> _todos = [];
  final TextEditingController _textController = TextEditingController();

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _todos.add(TodoItem(title: title, isCompleted: false));
    });
    _textController.clear();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nueva tarea', style: TextStyle(fontSize: 24)),
            content: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Ingresa una nueva tarea',
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 18),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _textController.clear();
                },
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () {
                  _addTodo(_textController.text);
                  Navigator.pop(context);
                },
                child: const Text('Agregar', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas', style: TextStyle(fontSize: 24)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          _todos.isEmpty
              ? const Center(
                child: Text(
                  'No hay tareas pendientes',
                  style: TextStyle(fontSize: 20),
                ),
              )
              : ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Dismissible(
                    key: Key(todo.title),
                    background: Container(
                      color: Theme.of(context).colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => _deleteTodo(index),
                    child: ListTile(
                      leading: Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (bool? value) => _toggleTodo(index),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration:
                              todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          fontSize: 18,
                          color:
                              todo.isCompleted
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                        iconSize: 28,
                        onPressed: () => _deleteTodo(index),
                        tooltip: 'Eliminar tarea',
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        tooltip: 'Agregar tarea',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class TodoItem {
  String title;
  bool isCompleted;

  TodoItem({required this.title, required this.isCompleted});
}
