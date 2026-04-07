import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen ({super.key,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

   _loadItems() async{
    final url = Uri.https(
        'flutter-prep-3b47c-default-rtdb.firebaseio.com', 'shopping-list.json'
    );
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        
      });
    }

    if (response.body =='null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listDate =
        jsonDecode(response.body);
    final List<GroceryItem> loadedItem = [];

    for (final item in listDate.entries) {
      final category = categories.entries
          .firstWhere((catItem) => catItem.value.title == item.value['category']).value;
      loadedItem.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category
        )
      );
    }
    setState(() {
      _groceryItems = loadedItem;
      _isLoading = false;
    });
  }

  void _addItem() async {
     final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
          builder: (ctx) => const NewItem()
      )
    );

     //_loadItems();

    if (newItem == null){
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem (GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutter-prep-3b47c-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json'
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Items add yet. '),);

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator(),);
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            key: ValueKey(_groceryItems[index].id),
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
              ),
            ),
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
      ),
      body: content,

      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _addItem();
          },
          label: Text(
            'أضافة عنصر',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              
            ),
          ),
         icon: Icon(Icons.add),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 10,
        //materialTapTargetSize: MaterialTapTargetSize.,
      ),
    );
  }
}