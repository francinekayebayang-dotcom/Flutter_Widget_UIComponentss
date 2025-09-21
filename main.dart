import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection'; // Required for UnmodifiableListView
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier

/// Data Model for managing a list of items.
/// It extends ChangeNotifier to notify listeners when the list changes.
class ItemListModel extends ChangeNotifier {
  final List<String> _items;

  /// Initializes the list with some default items or an empty list.
  /// Uses an initializer list for member initialization.
  ItemListModel({List<String>? initialItems})
      : _items = initialItems ?? ['Buy groceries', 'Walk the dog', 'Read a book'];

  /// Provides an unmodifiable view of the items list.
  /// This prevents external modification of the internal list state.
  UnmodifiableListView<String> get items => UnmodifiableListView<String>(_items);

  /// Adds a new item to the list if it's not empty or just whitespace.
  /// Notifies listeners to trigger UI updates.
  void addItem(String item) {
    final String trimmedItem = item.trim();
    if (trimmedItem.isNotEmpty) {
      _items.add(trimmedItem);
      notifyListeners();
    }
  }
}

void main() => runApp(const MyApp());

/// The root widget of the application.
/// It sets up the MaterialApp and provides the ItemListModel using ChangeNotifierProvider.
class MyApp extends StatelessWidget {
  static const header = 'Simple Item List';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemListModel>(
      // Provide an instance of ItemListModel. Initial items can be set here.
      create: (context) => ItemListModel(),
      // The builder function ensures the context for MaterialApp includes the provider.
      builder: (context, child) {
        return MaterialApp(
          title: header,
          theme: ThemeData(
            primarySwatch: Colors.green,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: header),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// The main page of the application, responsible for displaying the item list
/// and providing an interface to add new items.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The state for MyHomePage, managing the TextEditingController for new item input.
class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  /// Handles the action of adding a new item to the list.
  /// It reads text from the controller, validates it, adds it to the model,
  /// clears the input, and shows a SnackBar feedback.
  void _addItem() {
    final String newItemText = _itemController.text;
    if (newItemText.trim().isNotEmpty) {
      // Use context.read to access the ItemListModel and call its addItem method.
      context.read<ItemListModel>().addItem(newItemText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${newItemText.trim()}" to the list!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _itemController.clear(); // Clear the text field after adding
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item cannot be empty!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch listens for changes in ItemListModel and rebuilds the widget when it changes.
    final ItemListModel itemListModel = context.watch<ItemListModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: 'New Item',
                hintText: 'Enter a task or item',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _itemController.clear();
                  },
                ),
              ),
              onSubmitted: (_) => _addItem(), // Allow adding on keyboard submit
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity, // Make button full width
              child: ElevatedButton.icon(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Item',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Current Items (${itemListModel.items.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            Expanded(
              // Display the list of items.
              child: itemListModel.items.isEmpty
                  ? const Center(
                      child: Text('No items yet! Add some above.'),
                    )
                  : ListView.builder(
                      itemCount: itemListModel.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            title: Text(itemListModel.items[index]),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Example of another interaction with SnackBar feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Tapped on "${itemListModel.items[index]}"'),
                                  backgroundColor: Colors.blueAccent,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}