import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
          background: const Color(0xFFF5F5F5),
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 22),
          bodyMedium: TextStyle(fontSize: 20),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
  final TextEditingController _editController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    _prefs = await SharedPreferences.getInstance();
    final todosJson = _prefs.getString('todos');
    if (todosJson != null) {
      final List<dynamic> todosList = json.decode(todosJson);
      setState(() {
        _todos.clear();
        _todos.addAll(
          todosList.map((item) => TodoItem.fromJson(item)).toList(),
        );
      });
    }
  }

  Future<void> _saveTodos() async {
    final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
    await _prefs.setString('todos', todosJson);
  }

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _todos.add(TodoItem(title: title, isCompleted: false));
      _saveTodos();
    });
    _textController.clear();
  }

  void _editTodo(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;

    setState(() {
      _todos[index].title = newTitle;
      _saveTodos();
    });
    _editController.clear();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _saveTodos();
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
      _saveTodos();
    });
  }

  void _showAddTodoDialog() {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Nueva tarea',
          style: TextStyle(fontSize: 28),
        ),
        content: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'Ingresa una nueva tarea',
            hintStyle: TextStyle(fontSize: 20),
          ),
          style: const TextStyle(fontSize: 22),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addTodo(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _textController.clear();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                _addTodo(_textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Agregar',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    _editController.text = _todos[index].title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar tarea', style: TextStyle(fontSize: 28)),
        content: TextField(
          controller: _editController,
          decoration: const InputDecoration(
            hintText: 'Edita la tarea',
            hintStyle: TextStyle(fontSize: 20),
          ),
          style: const TextStyle(fontSize: 22),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editController.clear();
            },
            child: const Text('Cancelar', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              _editTodo(index, _editController.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea', style: TextStyle(fontSize: 28)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${_todos[index].title}"?',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              _deleteTodo(index);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas', style: TextStyle(fontSize: 28)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: _todos.isEmpty
            ? const Center(
                child: Text(
                  'No hay tareas pendientes',
                  style: TextStyle(fontSize: 24),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Transform.scale(
                        scale: 1.4,
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
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontSize: 22,
                          color: todo.isCompleted
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: Theme.of(context).colorScheme.primary,
                            iconSize: 32,
                            onPressed: () => _showEditDialog(index),
                            tooltip: 'Editar tarea',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Theme.of(context).colorScheme.error,
                            iconSize: 32,
                            onPressed: () => _showDeleteConfirmation(index),
                            tooltip: 'Eliminar tarea',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        tooltip: 'Agregar tarea',
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _editController.dispose();
    super.dispose();
  }
}

class TodoItem {
  String title;
  bool isCompleted;

  TodoItem({required this.title, required this.isCompleted});

  Map<String, dynamic> toJson() => {'title': title, 'isCompleted': isCompleted};

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      TodoItem(title: json['title'], isCompleted: json['isCompleted']);
}
